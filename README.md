# Create a new environment on Azure

1. [Have Sentia create the environment.](docs/create-environment.md)
2. [Create/generate a key](docs/keyvault-key-generation.md) named `data-protection` in the key vault.
3. [Run ./setup-secrets.](docs/setup-secrets.md)
4. [Run ./initialize-couchbase-cluster](docs/initialize-couchbase-cluster.md), with proper environment variables set (read the file for
   those available and their defaults).
5. [Add TLS certificate](docs/add-tls-certificate.md) to the key vault.
6. Setup global bucket XDCR.(optional if no replication is needed for environment)
7. [Add a group](docs/couchbase-users-and-roles.md) to Couchbase called `services` with the
   Query CURL access role and the following
   roles on All buckets: Application Access, Data Reader, Data Writer, Data DCP Reader,
   Data Monitor, Views Reader, Query Select, Query Update, Query Insert, and Query Delete.
8. [Add a user](docs/couchbase-users-and-roles.md) to Couchbase called `service-client` with the
   password from the couchbasePassword secret in the key vault.
   couchbasePassword. And add the user to the services group.
9. [Modify Function app and app service Configuration sections as needed.](docs/app-service-configuration.md)
10. [Deploy AzureFunctions and App Services](docs/deploy-services.md).
11. Run ./setup-secrets again with prerequisites of step 3; Skip this step if `systemFunctionsHostKey` is available in key vault already. This step is needed in case Function app secrets are not available until an app has been deployed. Remember to narrow down key vault networking access after script execution as described in step 3.
12. [Setup custom domains](docs/setup-custom-domains.md) for the IdentityServer and RestService App Services.
13. [Configure TLS](docs/configure-tls.md) for the IdentityServer and RestService App Services.
14. [Upload signing-cert.pfx and extra-valid-cert.pfx](docs/upload-identityserver-certificates.md) to the IdentityServer service. Temporarily enable ftps for the service to upload them over ftps.
15. Add new endpoints|environment to `monsenso-i18n +  monsenso-library` to be consumed by
    `Green, NWP, Funmachine, Phoenix` via npm lib dependency.
16. [Prepare CDN storage account](docs/prepare-cdn-storage-account.md)
17. [Deploy web apps to CDN](docs/deploy-web-apps-to-cdn.md)
18. [Add CDN custom domains and adjust CDN rule engine](doc/../docs/add-cdn-custom-domains-adjust-rule-engine.md)
19. QA team [configures couchbase data](docs/configure-couchbase-data.md) according to the environment

# Couchbase cluster initialization

Documents that should be insterted into a new cluster must be added as JSON files in the
respective `./couchbase/*_bucket` folder. The filename, excluding the extension, will be used
as the document key.

Design documents must be added as a JSON file to `./couchbase/*_bucket/design_docs/` folder,
the name of the file, excluding the extention, will be the name of the design document.

N1QL indices must be added to the `./couchbase/*_bucket/design_docs/indexes.json`.

FTS indices must be as a JSON file in the `./couchbase/fts-indices/` folder, the name of the
file, excluding the extension, will be the name of the index.

# Couchbase access to employees

Follow the security **principle of least privilege.** Different permissions are needed per environment.
For Dev/Test env add the groups `Developers` & `QA` & `Admin` with the according permissions.
For Prod/Beta env add the groups `Admin` and `Reporting`(to be defined // TODO) with the according permissions.

# Secrets

To add a new secret add a file in the secrets folder, the name of the file will be the name of
the secret. The file will be executed as a bash script and its stdout is used as the secret
value.

# Couchbase Sync Gateway

If the Tastro app is required for the deployment/environment, for instance for a test environment
where release testing requires Tastro, or a production environment with Tastro users, a Couchbase
Sync Gateway is required.

[Read this guide](docs/sync-gateway.md) on how to setup a Sync Gateway.

# Common tasks

# Add environment not reusing existing translations for prod|beta|test|dev

If your new environment cannot reuse the existings translations environments 
then the release pipelines must be adjusted [dev translations](https://dev.azure.com/monsenso/Clients/_release?definitionId=24&view=mine&_a=releases) [prod|beta|test](https://dev.azure.com/monsenso/Clients/_release?definitionId=24&view=mine&_a=releases)
Note that translations are served worldwide through a CDN network so latency is not a reason
to create a new environment for translation.