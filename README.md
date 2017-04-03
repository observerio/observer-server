# Web

TCP server should receive message using binary protocol.


# Protocol:

DELIMETER: "|" in case if we are going to use batch requests.

```
session(0):
  - api key

log(1):
  [{ level, message }]

inspector(2):
  variables:
    - { type, name, value }

type: string, numeric, range
```

# Examples:

```
0:api_key
```

```
1:base64_messages_as_array_of_dictionaries
```

```
2:base64_variables_as_array_of_dictionaries
```
