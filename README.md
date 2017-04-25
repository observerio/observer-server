# Web

TCP server should receive message using binary protocol.


# TODO:

- [ ] add jwt.io


# Routes

POST

/users
  IN:
    - { email: "admine@example.com", password: "123456" }
  OUT:
    - { auth_key: "<key>" }

# Dev

containers:
  -[x] redis
  -[x] elasticsearch
  -[x] backend(tcp, web api)
  -[x] test
  -[] test.watch([https://github.com/lpil/mix-test.watch](https://github.com/lpil/mix-test.watch))
  -[] demo tcp client(random produce data)
  -[] frontend
