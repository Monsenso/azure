## Sync Gateway for new environment

1.  A dedicated Sync Gateway VM should be added to the subscription, if not already created.
    - Machine specification requirements are minor: 4-8 GB of RAM and min 2 cores should be
      sufficient.
    - SSH connections should be allowed.
    - The VM should have a Public IP address.
2.  An Application Gateway should be available on the subscription to route external connections to the Sync Gateway VM. For this, the publicly available domain that the Tastro app will connect to should be determined, and a TLS certificate issued for this domain (or a wildcard domain covering it) should be available in the subscription key vault:

    - A wildcard certificate would normally already have been added to the key vault as part of the environment setup ([detailed here](docs/add-tls-certificate.md)). If the desired domain for the Sync Gateway matches this wildcard certificate, fx if the desired name is `sync.test.monsenso.com` and the wildcard ceritifcate is for `*.test.monsenso.com`, using this certificate is recommended.
    - If the Application Gateway has not already been configured:
    - Create a Backend Pool that targets the Sync Gateway VM on port 4984.
    - The Tastro app connects on the standard HTTPS port 443, so add a Listener on port 443 on Frontend public IP, HTTPS protocol, using the certificate from the key vault, and Basic listener type.
    - Add a "Request routing rule" under "Rules" that uses the Listener and targets the Backend Pool on port 4984 (Or whatever port you configure the Sync Gateway to listen to below. Note NOT the admin port.)

3.  Install Couchbase Sync Gateway Enterprise on the VM:

    - SSH to the server, using your Azure account.
    - Version requirements: Couchbase Sync Gateway 2.0, Ubuntu 18.04.
    - [Sync Gateway installation guide.](https://docs.couchbase.com/sync-gateway/2.0/getting-started.html)

      - Note the above guide installs the community version. In relevant steps, replace `community` with `enterprise`, i.e.:  
        `wget https://packages.couchbase.com/releases/couchbase-sync-gateway/2.0.0/couchbase-sync-gateway-community_2.0.0_x86_64.deb`

        Becomes:

        `wget https://packages.couchbase.com/releases/couchbase-sync-gateway/2.0.0/couchbase-sync-gateway-enterprise_2.0.0_x86_64.deb`

4.  Create shadow buckets on the Couchbase Server that the Sync Gateway will be synchronizing.

    - Shadow buckets are required for the `data` and `voice_data` buckets. Name should be `<bucketname>_shadow`, ie. `data_shadow` and `voice_data_shadow`. For the RAM quota, make them similar in size to the bucket they shadow if possible.

5.  Construct the `sync_gateway.json` configuration file by using the chef recipes in the [chef-sync-gateway repository](https://github.com/Monsenso/chef-sync-gateway):

    - Either run the scripts, or construct the JSON manually. To construct manually, do the following:
      - Start with the base template: `templates/default/sync_gateway.json.erb`
      - Replace the variables (`<% %>`) with the values produced by `recipes/default.rb`.
        This script uses the other templates to create the values inserted in the base template.
        - `.server`: Use the Azure private IP of the Couchbase Server VM,
          fx `http://10.7.5.5:8091`
        - `.username` & `.password`: Use the `service-client` user created when setting up the Couchbase Server, and use the value of the couchbasePassword secret in the key vault as the password.
        - `.sync`: Copy the contents of the corresponding `<bucketname>_bucket_sync_fn.js.erb` file, and surround it with backticks: \`.
        - Note that for the Sync Gateway, the main bucket is fx `data_shadow` and the shadow bucket would then be `data`.
        - `logFilePath`: Get the value of this from the script, and then make sure that the `sync_gateway` user is the owner of that folder (with `chown`)
    - Stop the sync_gateway service
    - Copy the configuration file over to /home/sync_gateway/sync_gateway.json
    - Start the sync_gateway service
    - See [below](##sync-gateway-config-example) for a rough example config.

6.  When users login in the Tastro app, the `idsvr4` `system_client` is used by IdentityServer. This entry should already exist in the `system_client` document in the auth bucket of the Couchbase Server.

    - Note that the `clientSecrets` array must contain the matching `identityServerClientSecret`. This value would have been added to the environment key vault when setting up secrets. The value in the `idsvr4.clientSecrets` should be the hashed (SHA256 binary) and base64 encoded value of the secret. To get this, get the value from the key vault (`secret` below) and use OpenSSL:

    ```bash
    echo -n 'secret' | openssl dgst -sha256 -binary | openssl base64
    ```

    This will give you the `value`, the full object to insert in `clientSecrets` would then be:

    ```json
    {
      "description": null,
      "expiration": null,
      "type": "SharedSecret",
      "value": "<valuehere>"
    }
    ```

7.  To route the traffic to the VM on the desired public domain via the Application Gateway, add an `A` record for the desired public domain to the `monsenso.com` public DNS. If the desired domain name is `sync.test.monsenso.com` and the Frontend public IP of the Application Gateway is `50.150.25.5`, the `A` record should look like this:

        | Name      | Type | TTL  | Value       |
        | --------- | ---- | ---- | ----------- |
        | sync.test | A    | 3600 | 50.150.25.5 |

8.  Make sure that the `appsettings` for the environment match the values for the Sync Gateway:
    - `syncGatewayPublicHostname` should be the publicly available domain added to the DNS, fx `sync.test.monsenso.com`.
    - `syncGateway` should be the resolve address of the Sync Gateway VM, and the ports it is setup to listen on. If the default values are used, the ports would be 4984 and 4985. The full object, with a private IP of 10.7.5.6 for the VM, could fx be:
    ```json
    "syncGateway": {
        "hostname": "10.7.5.6",
        "port": 4984,
        "adminPort": 4985
    }
    ```

## Sync Gateway config example

```json
{
  "adminInterface": "0.0.0.0:4985",
  "compressResponses": true,
  "databases": {
    "data": {
      "server": "http://10.7.5.5:8091",
      "bucket": "data_shadow",
      "username": "service-client",
      "password": "password",
      "sync": `function syncFn(doc, oldDoc) { ... }`,
      "feed_type": "DCP",
      "shadow": {
        "server": "http://10.7.5.5:8091",
        "bucket": "data",
        "username": "service-client",
        "password": "password",
        "feed_type": "DCP"
      }
    },
    "voice_data": {
      "server": "http://10.7.5.5:8091",
      "bucket": "voice_data_shadow",
      "username": "service-client",
      "password": "password",
      "sync": `function syncFn(doc, oldDoc) { ... }`,
      "feed_type": "DCP",
      "shadow": {
        "server": "http://10.7.5.5:8091",
        "bucket": "voice_data",
        "username": "service-client",
        "password": "password",
        "feed_type": "DCP"
      }
    }
  },
  "interface": ":4984",
  "log": ["HTTP", "Auth", "Access", "Shadow"],
  "logFilePath": "/var/log/sync-gateway/sync_gateway.log",
  "maxFileDestriptors": 5000,
  "pretty": false,
  "serverReadTimeout": 30,
  "serverWriteTimeout": 30,
  "slowServerCallWarningThreshold": 200
}
```
