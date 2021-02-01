# Create a new environment on Azure

1. Have Sentia create the environment.
2. Run ./setup-secrets.
3. Run ./initialize-couchbase-cluster, with proper environment variables set (read the file for
   those available and their defaults).
4. Setup global bucket XDCR.
5. Add a group to Couchbase called `services` with the Query CURL access role and the following
   roles on All buckets: Application Access, Data Reader, Data Writer, Data DCP Reader,
   Data Monitor, Views Reader, Query Select, Query Update, Query Insert, and Query Delete.
5. Add a user to Couchbase called service-client with the password from the couchbasePassword
   secret in the key vault.
   couchbasePassword. And add the user to the services group.
5. Modify Function app and app service Configuration sections as needed.
6. Deploy AzureFunctions.
7. Run ./setup-secrets; Function app secrets are not available until an app has been deployed.
8. Deploy the App Services.
9. Add TLS certificate to the key vault.
10. Setup custom domains for the IdentityServer and RestService App Sernvices.
11. Configure TLS for the IdentityServer and RestService App Sernvices.

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
