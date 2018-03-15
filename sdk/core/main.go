package core

import (
	"bufio"
	"encoding/base64"
	"fmt"
	"net"
	"os"
	"time"

	"github.com/avast/retry-go"

	"github.com/apex/log"
	"github.com/apex/log/handlers/text"

	"github.com/pkg/errors"
	"github.com/pquerna/ffjson/ffjson"
)

const defaultHost = "observer.rubyforce.co:30001"
const verifyCommand = "v"
const varCommand = "i"
const logCommand = "l"

type errConnection struct {
	err error
}

func (errConnection) RetryTime() time.Duration {
	return 2 * time.Minute
}

func (e errConnection) Error() string {
	return e.err.Error()
}

// ErrConnection should happen in case if it's impossible to connect
var ErrConnection = errConnection{err: errors.New("can't connect to the server")}

// timeoutReadErr happened in case if it's impossible to read
// data from tcp server.
var timeoutReadErr error

func init() {
	timeoutReadErr = errors.New("timeout on receiving response from tcp server")
}

// Version should be populated on running build
const Version = "0.0.1"

// LogDebug only debug messages should be sent
const LogDebug = 1

// client is globally accessible to ensure possibility to restore
// access to tcp server.
var client *ClientStr

// panicHandler should handle the situations when our client died because of
// internal issues.
func panicHandler(err interface{}) {
	log.Debugf("panic err: %v", err)
	client.reconnect()
}

func withRecover(fn func()) {
	defer func() {
		handler := panicHandler
		if handler != nil {
			if err := recover(); err != nil {
				handler(err)
			}
		}
	}()

	fn()
}

func logResponse(resp response) {
	log.Debugf("[log] response: %v\n", resp)
}

func logError(err error) {
	log.Debugf("[log] error: %v\n", err)
}

// ClientStr is tcp client for talking with observer server.
type ClientStr struct {
	conn    net.Conn
	connErr error

	conf *confStr

	errors        chan error
	errorsHandler func(err error)

	responses        chan response
	responsesHandler func(resp response)

	// requests chan collecting to buffer requests
	// and then in case of available connection
	// pushing values step by step to tcp server.
	requests     chan request
	requestsBuff []*request
}

type response struct {
	data string
}

type request struct {
	messages interface{}
}

type logStr struct {
	Message string `json:"message"`
	Level   int    `json:"level"`
}

type varStr struct {
	Name  string `json:"name"`
	Type  string `json:"type"`
	Value string `json:"value"`
}

// confStr is having tcp client settings.
type confStr struct {
	host string
	key  string

	dialTimeout time.Duration
	keepAlive   time.Duration
}

func init() {
	log.SetHandler(text.New(os.Stderr))
}

// Init should receive key for authentication to initialize the client.
// - should use default host to connect
// - should have buffer in case of reconnection to the server
// - should handle situations when it can't send the traffic to server
func Init(key string) *ClientStr {
	return newClient(key, defaultHost)
}

// InitWithHost should be acessible from library, for development
// purporse we could use separare host to connect.
//
// TODO: define way to set debug level mode
func InitWithHost(key string, host string) *ClientStr {
	return newClient(key, host)
}

func newClient(key string, host string) *ClientStr {
	client := &ClientStr{
		conf: &confStr{
			dialTimeout: 2 * time.Minute,
			keepAlive:   5 * time.Minute,
			host:        host,
			key:         key,
		},
		errors:        make(chan error),
		errorsHandler: logError,

		responses:        make(chan response),
		responsesHandler: logResponse,
	}

	go withRecover(func() {
		for err := range client.errors {
			if client.errorsHandler != nil {
				client.errorsHandler(err)
			}
		}
	})

	go withRecover(func() {
		for resp := range client.responses {
			if client.responsesHandler != nil {
				client.responsesHandler(resp)
			}
		}
	})

	client.connect()

	go withRecover(client.reconnect)

	// TODO:
	// we should have it runnable on the backgrond for checking
	// any kind of the issues on connecting to tcp server:
	// - should handle any errors and put it to the buffer
	// - should run reconnect in case of no writes allowed
	// - should have buffer for collecting messages and sending it on reconnect

	return client
}

func encode(attributes interface{}) (string, error) {
	buf, err := ffjson.Marshal(attributes)
	defer ffjson.Pool(buf)
	if err != nil {
		return "", err
	}

	return base64.StdEncoding.EncodeToString(buf), nil
}

// Log should send log message directly to client depends on logging level.
func (client *ClientStr) Log(level int, message string) {
	message, err := encode([]logStr{
		{Level: level, Message: message},
	})
	if err != nil {
		client.errors <- errors.Wrap(err, "encode error")
	} else {
		go client.sendMessage(logCommand, message)
	}
}

// Var writes variables directly to server.
func (client *ClientStr) Var(typename string, name string, value string) {
	message, err := encode([]varStr{
		{Name: name, Type: typename, Value: value},
	})
	if err != nil {
		client.errors <- errors.Wrap(err, "encode error")
	} else {
		go client.sendMessage(varCommand, message)
	}
}

func (client *ClientStr) isConnected() bool {
	// TODO: we should have aliveness check by write/read message from server.
	return true
}

func (client *ClientStr) sendMessage(command string, message string) {
	if message == "" {
		client.send(fmt.Sprintf("%s:%s\n", command, client.conf.key))
	} else {
		client.send(fmt.Sprintf("%s:%s:%s\n", command, client.conf.key, message))
	}
}

func (client *ClientStr) send(message string) error {
	var err error

	log.Debugf("[client.send] begin write connection: %v, message: '%s'\n", client.conn, message)
	_, err = client.conn.Write([]byte(message))
	if err != nil {
		client.errors <- errors.Wrap(err, "conn can't write message via socket")
		return err
	}
	log.Debugf("[client.send] done write message: '%s'\n", message)

	responsesChan := make(chan response, 1)
	errorsChan := make(chan error, 1)

	go func() {
		log.Debugf("[client.send] begin running reader from tcp server message: '%s'\n", message)
		buf := bufio.NewReader(client.conn)
		for {
			str, err := buf.ReadString('\n')
			if len(str) > 0 {
				responsesChan <- response{data: str}
				break
			}
			if err != nil {
				errorsChan <- errors.Wrap(err, "conn can't write message via socket")
				break
			}
		}
		log.Debugf("[client.send] done running reader from tcp server message: '%s'\n", message)
	}()

	select {
	case res := <-responsesChan:
		client.responses <- res
	case err := <-errorsChan:
		client.errors <- err
	case <-time.After(time.Second * 5):
		client.errors <- timeoutReadErr
	}

	return err
}
func (client *ClientStr) auth() {
	client.sendMessage(verifyCommand, "")
}

func (client *ClientStr) connect() {
	if client.conn == nil {
		log.Debugf("[client.connect] begin connect to tcp server: '%s'\n", client.conf.host)
		dialer := net.Dialer{
			Timeout:   client.conf.dialTimeout,
			KeepAlive: client.conf.keepAlive,
		}

		client.conn, client.connErr = dialer.Dial("tcp", client.conf.host)
		if client.connErr != nil {
			client.errors <- errors.Wrap(client.connErr, "issue on connecting to host")
			// TODO:
			// - should reconnect to client and collect to buffer the messages to
			// send before the connection
			// - should have number of retries on connecting to host.
			panic(client.connErr)
		}
		log.Debugf("[client.connect] done connect to tcp server: '%s'\n", client.conf.host)

		log.Debugf("[client.connect] begin auth: '%s'\n", client.conf.host)
		client.auth()
		log.Debugf("[client.connect] done auth: '%s'\n", client.conf.host)
	}
}

// We should always giving a try to reconnect to the server
// otherwise we can loose the data.
func (client *ClientStr) reconnect() {
	err := retry.Do(
		func() error {
			client.connect()

			if !client.isConnected() {
				return ErrConnection
			}

			return nil
		},
	)

	if err != nil {
		_, ok := err.(errConnection)
		if ok {
			<-time.After(err.(errConnection).RetryTime())
			client.reconnect()
		}
	}
}
