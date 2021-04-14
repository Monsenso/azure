## Adding TLS certificate to key vault

- First, add an A record to the monsenso.com DNS for the Couchbase server:

  - Look up the A record for the Couchbase VM in the private DNS of the subscription.
    It could be something like: weu-dev-couchbase. Combine this with the name of the DNS, which
    fx could be: deveu.private.monsenso.com.
  - The above combines to: http://weu-dev-couchbase.deveu.private.monsenso.com:8091/, and if
    the private IP address of the VM hosting it is 10.7.5.5, the A record to add to the monsenso.com
    public DNS would look like:

    - | Name                            | Type | TTL  | Value    |
      | ------------------------------- | ---- | ---- | -------- |
      | weu-dev-couchbase.deveu.private | A    | 3600 | 10.7.5.5 |

  - Next the new certificates should be generated and uploaded:
    - The `acmesh` file share contains the certificates, `acmesh` can be found [here](https://portal.azure.com/#blade/Microsoft_Azure_FileStorage/FileShareMenuBlade/overview/storageAccountId/%2Fsubscriptions%2Fec51da25-eb08-4ef6-979c-450aa85fba8f%2Fresourcegroups%2FDevOps%2Fproviders%2FMicrosoft.Storage%2FstorageAccounts%2Facmesh/path/acmesh/protocol/SMB).
    - You can use the Azure Storage Explorer application to browse `acmesh` and other storage accounts,
      just connect to the Azure Subscription.
  - You need access to the `acmesh` drive via NFS on Linux:
    - Guide to mounting the file share:
      https://docs.microsoft.com/en-us/azure/storage/files/storage-files-how-to-mount-nfs-shares#mount-an-nfs-share
    - Note that the cifs-utils package is required on Linux.
    - Port 445 has to be open. This port can be blocked by a firewall on both your machine, by your router and/or by your ISP. If the latter is the case, the block can be circumvented by using a VPN. If the block is local to your machine or router, it should be possible to open the port to TCP traffic in the firewall configuration.
    - Using NFS is preferred to just copying the files from `acmesh` to your machine, creating certificates and then uploading them, but this is also a viable approach. Using NFS ensures you're working with the correct, newest files, and helpes mitigate any issues with multiple people creating/renewing certificates at the same time.
  - See the `readme.md` in the `acmesh` root for how to issue a new certificate
    https://acmesh.file.core.windows.net/acmesh/readme.md
    - Example for a new couchbase domain:
      - New Couchbase on: http://weu-couchbase.eu.private.monsenso.com:8091/
      - Command would then be:
        `./acme.sh --issue --dns dns_azure -d weu-couchbase.eu.private.monsenso.com`
    - Example for new RestService and Auth/IdentityServer domains combined certificate on
      auth.eu.monsenso.com and rest.eu.monsenso.com respectively:
      `./acme.sh --issue --dns dns_azure -d \*.eu.monsenso.com`
    - Running the acme script creates a domain key, and should print the location of the
      key to the console.
    - Copy the files over locally if you get an error about Azure Subscription not specified,
      and then upload the generated folder with all containing files to acmesh.
  - Adding the certificates to Key Vault and Couchbase (using azure repo scripts):
    - Add the new Subscription to `subscriptions.env`.
    - Add the environment and it's certificate to `renew-and-deplay-certificates.sh`.
      - for services use `renew_web_service_cert`
      - for couchbase use `renew_couchbase_certificate`
      - Examples:
        - web services certificate:
          ```bash
          renew_web_service_cert monsenso-eu-prd-kv "\*.eu.monsenso.com" $SUB_PRD02
          ```
        - couchbase certificate:
          ```bash
          renew_couchbase_certificate \
          'EU PRD' \
          weu-couchbase.eu.private.monsenso.com \
          weu-couchbase.eu.private.monsenso.com
          ```
    - Make sure you're logged in to the monsenso container registry:
      - az acr login -n monsenso
    - Run the `renew-and-deplay-certificates.sh` script with ACMESH_HOME set to path of the
      acmesh root folder. If ACMESH_HOME is not set explicitly, the default value, `~/.acme.sh`,
      is used. Note that the NFS connect script copied from the Azure Storage page uses `/mnt/acmesh` as the default path.
      - The script utilizes SSH, so make sure you are connected to a VPN, so the couchbase server is available.
      - Example with the share mounted in `/mnt/acmesh`
        (note the added `/.acme.sh` compared to the default mounting folder):
        `ACMESH_HOME=/mnt/acmesh ./renew-and-deplay-certificates.sh`
    - The Couchbase certificate should be visible in the web console -> Security -> Root
      Certificate. Note that a HTTPS connection to the web console uses port 18091, so using above
      example, a secure Couchbase connection can be made after uploading the certificate at:
      https://weu-dev-couchbase.deveu.private.monsenso.com:18091/
