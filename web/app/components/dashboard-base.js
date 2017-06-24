import Ember from 'ember';
import ENV from 'observer-web-ember/config/environment';
import debugLogger from 'ember-debug-logger';

import slice from 'lodash/slice';
import map from 'lodash/map';

const {get, set} = Ember;
const {later, bind} = Ember.run;

const Var = Ember.Object.extend({
    type: null,
    value: null,
    name: null
});

const Log = Ember.Object.extend({
    timestamp: null,
    message: null
});

export default Ember.Component.extend({
    debug: debugLogger(),

    websockets: Ember.inject.service(),

    // refs
    socketClient: null,

    // properties
    token: null, // /:token route

    // variables
    logs: [],
    vars: [],

    LOG_HISTORY: 200,

    didInsertElement() {
        this._super(...arguments);

        const socket = this.get('websockets').socketFor(ENV.WS.HOST);
        socket.on('open', this.openHandler, this);
        socket.on('close', this.closeHandler, this);
        socket.on('message', this.messageHandler, this);
        this.set('socketClient', socket);
    },

    willDestroyElement() {
        this._super(...arguments);

        const socket = this.get('socketClient');
        socket.off('open', this.openHandler);
        socket.off('close', this.closeHandler);
        socket.off('message', this.messageHandler);
    },

    openHandler(event) {
        const socket = this.get('socketClient');
        const message = { event: 'init', data: { key: get(this, 'token') } };
        socket.send(JSON.stringify(message));
        this.debug(event);
    },

    closeHandler() {
        const socket = this.get('socketClient');
        later(this, () => socket.reconnect(), 1000);
    },

    _processMessage(event) {
        this.debug(event);
        return JSON.parse(event);
    },

    _processVars(message) {
        let vars = message.vars.reduce((vars, v, index) => {
            // [key1, value1, key2, value2]
            if (index % 2 == 0) {
                let values = v.split(':');
                let name = values[0];
                let property = values[1];
                if (Ember.isBlank(vars[name])) {
                    vars[name] = vars[name] || {};
                    vars[name].name = name;
                }
                vars[name][property] = message.vars[index + 1];
            }
            return vars;
        }, {});

        vars = map(vars, (value, key) => Var.create(vars[key]))
        set(this, 'vars', vars);
    },

    _processLogs(message) {
        let logs = get(this, 'logs');
        logs = logs.concat(message.logs.map((log) => Log.create(log)))
        if (logs.length > this.LOG_HISTORY) {
            logs = slice(logs, logs.length - this.LOG_HISTORY);
        }
        set(this, 'logs', logs);
    },

    messageHandler(event) {
        const message = this._processMessage(event.data)

        switch(message.type) {
            case 'logs': {
                this._processLogs(message);
                break;
            }
            case 'vars': {
                this._processVars(message);
                break;
            }
            default: {
                Ember.Logger.error(`[dashboard-base] can't parse socket message: ${message}`);
            }
        }
    },

    actions: {
        sendMessage(message) {
            const socket = get(this, 'socketClient');
            debugger;
            this.debug(message);
            socket.send(JSON.stringify(message))
        }
    }
});
