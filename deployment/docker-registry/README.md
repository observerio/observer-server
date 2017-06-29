Deploy a Docker Registry on DigitalOcean with Terraform
=======================================================

*Note:* This has not been tested for production use; it is recommended that you review any relevant security best practices before deploying this outside of a Development
environment.

Requirements
------------

The automation in the script requires `docker` and `openssl` (in addition to, of course, `terraform`) to be installed on the client machine.

If you prefer to provide/generate your own `htpasswd` and/or SSL certificates, these are not required, and will not impede the Terraform run.

Importing Certificates, Users
-----------------------------

*This is optional: a default run will generate certs and randomly generated users, but the following will work for users with commercial SSLs, pre-existing users for basic auth, etc.*

If you have an existing SSL certificate and key for your registry FQDN, you can place them in the `certs` directory, and they will be picked up by Terraform.

If you wish to import Users from an existing htpasswd file, place that file in `auth/htpasswd`.

If you do not have an `htpasswd` but wish to generate one from a manually populated list of usernames and passwords (these will only be stored locally for your use; the htpasswd file that will
be generated will be the only credential file uploaded to the server), populate the `registry_auth` file in the project root, using this format:

```bash
user1 password1
user2 password2
...
```

*This is optional, and only required if you do not wish for the script to generate random accounts for you* This must be done *before* running `terraform apply`, or else it will generate
all of the above for you.

Usage
-----

If you do not require the above customizations, simply proceed to run

```bash
terraform apply
```

Migrating Data
---------------

This process creates a Droplet and a Block Storage volume. If, for whatever reason, the droplet needs to be destroyed, this setup allows you to create a new droplet, and re-attach the
existing data volume to a new registry droplet (provided you do not, first, destroy the droplet with the volume attached) and preserve your data on future runs of this script.
