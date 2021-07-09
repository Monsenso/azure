### Prerequisities 
- Check that your user has on the key vault all key, secret & certificate permissions

## Adding TLS certificate to key vault
> Step 1 defines the domain for which a certificate can be issued for.
> Step 2 generates via <https://letsencrypt.org/docs/client-options/>'s acme.sh a private certificate
> for the domain, which will be synched with acmesh' storage account and uploaded to the services serving https.

- Step 1: Add an A record to the monsenso.com DNS for the Couchbase server:

  - Look up the A record for the Couchbase VM in the DNS of the subscription.
    It could be something like: weu-dev-couchbase. Combine this with the name of the DNS, which
    fx could be: deveu.private.monsenso.com.
  - The above combines to: http://weu-dev-couchbase.deveu.private.monsenso.com:8091/, and if
    the private IP address of the VM hosting it is 10.7.5.5, the A record to add to the monsenso.com
    public DNS would look like:

    - | Name                            | Type | TTL  | Value    |
      | ------------------------------- | ---- | ---- | -------- |
      | weu-dev-couchbase.deveu.private | A    | 3600 | 10.7.5.5 |

- Step 2: Generate and upload a certificate:
  - The `acmesh` file share contains the certificates. It is located in the acmesh storage account in Azure Subscription 1, find it by:
    - Search for Storage account. Make sure Azure subscription 1 is selected
    - Select `acmesh`
    - In the menu on the left select File shares
    - Select `acmesh`
  - Sync the file share on your computer: Different ways to read and update the file share (NFS or SMB preferred due to automatic sync)
    1. Use above file share capabilities in the browser
    2. You can use the `Azure Storage Explorer` application to browse `acmesh` and other storage accounts,
    just connect to the Azure Subscription 1.
    3. You can use NFS on Linux
       - You need access to the `acmesh` drive via NFS on Linux:
       - Guide to mounting the file share:
      <https://docs.microsoft.com/en-us/azure/storage/files/storage-files-how-to-mount-nfs-shares#mount-an-nfs-share>
       - Note that the cifs-utils package is required on Linux.
       - Port 445 has to be open. This port can be blocked by a firewall on both your machine, by your router and/or by your ISP. If the latter is the case, the block can be circumvented by using a VPN. If the block is local to your machine or router, it should be possible to open the port to TCP traffic in the firewall configuration.
    4. You can use SMB on macOS
       - Follow instructions listed by "connect" button on `acmesh` file share:
         - `open smb://acmesh:your_secret_access_url_listed_by_connect_button` which will mount /Volumes/acmesh
    - Using NFS is preferred to just copying the files from `acmesh` to your machine, creating certificates and then uploading them, but this is also a viable approach. Using NFS ensures you're working with the correct, newest files, and helpes mitigate any issues with multiple people creating/renewing certificates at the same time.
  - Issue a new certificate. See the `readme.md` in the `acmesh` root for how to do so.
    - If you do not have acmesh mounted in ~/.acme.sh, then either symlink
      or do something similar on whatever OS you're on.
      Fx on macOS
        ```bash
          In macOS:
          ln -s /Volumes/acmesh ~
          cd ~
          mv acmesh .acme.sh
        ```

    - Example for a new couchbase domain:
      - New Couchbase on: <https://weu-dev-couchbase.deveu.private.monsenso.com:18091/>
      - Command would then be:
        `./acme.sh --issue --dns dns_azure -d weu-couchbase.eu.private.monsenso.com`
    - Example for new RestService and Auth/IdentityServer domains combined certificate on
      auth.eu.monsenso.com and rest.eu.monsenso.com respectively:
        `./acme.sh --issue --dns dns_azure -d \*.dev.monsenso.com`
    - Running the acme script creates a domain key, and should print the location of the
      key to the console.
    - The script uses the values set in `account.conf`, so check these are correct if there are any errors.
    - If you get an error about Azure Subscription not specified, double check the values in `account.conf`.
    - Make sure you're logged in to the monsenso container registry: `az acr login -n monsenso`
    - If sync to the file share does not work, you can always copy the files over locally and then upload the generated folder with all containing files to `acmesh`.
  - Adding the certificates to Key Vault and Couchbase (using azure repo scripts):
    - Add the new Subscription to `subscriptions.env`.
    - Add the environment and it's certificate to `renew-and-deploy-certificates.sh`.
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

    - Run the `renew-and-deploy-certificates.sh` script with ACMESH_HOME set to path of the
      acmesh root folder. If ACMESH_HOME is not set explicitly, the default value, `~/.acme.sh`,
      is used. Note that the NFS connect script copied from the Azure Storage page uses `/mnt/acmesh` as the default path.
      - The script utilizes SSH, so make sure you are connected to a VPN, so the couchbase server is available.
        - SSH to your Couchbase VM and verify that permissions `chmod  775 chain.pem` and `chmod  775 pkey.key` exist in /opt/couchbase/var/lib/couchbase/inbox (Couchbase Rest API admin user will access those 
        secrets copied over via scp in the script so read/execute for `other` is needed )
      - Example with the share mounted in `/mnt/acmesh`
        (note the added `/.acme.sh` compared to the default mounting folder):
        `ACMESH_HOME=/mnt/acmesh ./renew-and-deploy-certificates.sh`

      - The script will ask you for your Couchbase credentials. Note that user name is case sensitive `Administrator`.
      - mac OS Prerequisites:

        ```bash
            # get ssl-cert-check
            cd /path/to/your/repo/azure
            wget https://raw.githubusercontent.com/Matty9191/ssl-cert-check/master/ssl-cert-check
            chmod +x ./ssl-cert-check
            PATH=$PATH:/path/to/your/repo/azure ./renew-and-deploy-certificates.sh

          # get ggrep, homebrew's GNU grep version
            brew install grep            
        ```

        Comment out line 6 in [renew-and-deploy-certificates.sh](../renew-and-deploy-certificates.sh) as no secure `shred` on macOS existing(`gshred` not secure on macOS filesystem so `rm` is used)

    - Checks:
      - The Couchbase certificate should be visible in the web console -> Security -> Root
      Certificate. Note that a HTTPS connection to the web console uses port 18091, so using above
      example, a secure Couchbase connection can be made after uploading the certificate at:
      <https://weu-dev-couchbase.deveu.private.monsenso.com:18091/>
      - Check on the key vault that a certificate `web-service-cert` was created.

    - Cleanup: Make sure key vault's network access is set to private again.