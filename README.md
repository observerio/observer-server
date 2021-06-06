# Dev

`make build` - run required containers and simulation traffic
`make rebuild` - remove previous containers and build the new containers

# Web

TCP server should receive message using binary protocol.

TODO: Add webpack env.js config build too use environment variables
to setup host:port and other possibles options.

DEV PORT: WEB=8080, SOCKET=4000

TODO: use http://127.0.0.1:8080/


# TODO:

- [ ] add jwt.io
- [ ] add tcp client and integrate it to the unity by using native library load
- [ ] add tcp


# Routes

POST

/users
  IN:
    - { email: "admine@example.com", password: "123456" }
  OUT:
    - { auth_key: "<key>" }

# Dev

containers:
  - [x] redis
  - [x] elasticsearch
  - [x] backend(tcp, web api)
  - [x] test
  - [ ] test.watch([https://github.com/lpil/mix-test.watch](https://github.com/lpil/mix-test.watch))
  - [ ] demo tcp client(random produce data)
  - [ ] frontend
