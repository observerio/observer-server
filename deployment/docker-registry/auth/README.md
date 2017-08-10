Usage
-----

If you wish to have the script generate users for you, run `terraform apply` without a populated registry_auth file.

Importing users
---------------

If you have an existing htpasswd file, place it in `auth/htpasswd` and it will
be passed to the server, if you wish to generate one from a new set of credentials,
save a new file, `registry_auth` in the project root, using the format:

```bash
user1 password1
user2 password2
...
```
and the script will create an htpasswd file for you. *Only the htpasswd file, not the plaintext registry_auth, is copied to the server*
