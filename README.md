# Create a new environment on Azure

1. [Have Sentia create the environment.](docs/create-environment.md)
2. [Create/generate a key](docs/keyvault-key-generation.md) named `data-protection` in the key vault.
3. [Run ./setup-secrets.](docs/setup-secrets.md)
4. [Run ./initialize-couchbase-cluster](docs/initialize-couchbase-cluster.md), with proper environment variables set (read the file for
   those available and their defaults).
5. Setup global bucket XDCR.
6. [Add a group](docs/couchbase-users-and-roles.md) to Couchbase called `services` with the 
Query CURL access role and the following
   roles on All buckets: Application Access, Data Reader, Data Writer, Data DCP Reader,
   Data Monitor, Views Reader, Query Select, Query Update, Query Insert, and Query Delete.
7. [Add a user](docs/couchbase-users-and-roles.md) to Couchbase called service-client with the 
password from the couchbasePassword secret in the key vault.
   couchbasePassword. And add the user to the services group.
8. [Modify Function app and app service Configuration sections as needed.](docs/app-service-configuration.md)
9. [Deploy AzureFunctions](docs/deploy-services.md).
10. Run ./setup-secrets; Function app secrets are not available until an app has been deployed.
11. Deploy the App Services.
12. Add TLS certificate to the key vault.
13. Setup custom domains for the IdentityServer and RestService App Services.
14. Configure TLS for the IdentityServer and RestService App Services.
15. Upload signing-cert.pfx and extra-valid-cert.pfx to the IdentityServer service. Temporarily enable ftps for the service to upload them over ftps.

# Couchbase cluster initialization
Documents that should be insterted into a new cluster must be added as JSON files in the
respective `./couchbase/*_bucket` folder. The filename, excluding the extension, will be used
as the document key.

Design documents must be added as a JSON file to `./couchbase/*_bucket/design_docs/` folder,
the name of the file, excluding the extention, will be the name of the design document.

N1QL indices must be added to the `./couchbase/*_bucket/design_docs/indexes.json`.

FTS indices must be as a JSON file in the `./couchbase/fts-indices/` folder, the name of the
file, excluding the extension, will be the name of the index.

# Secrets
To add a new secret add a file in the secrets folder, the name of the file will be the name of
the secret. The file will be executed as a bash script and its stdout is used as the secret
value.
