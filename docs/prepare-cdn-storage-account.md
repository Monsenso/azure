# Purpose

The web apps delivered through the CDN needs at runtime context in which environment they run in.
This is manually delivered through files in the storage account for that environment. 

# Prerequisites

- Install `Microsoft Azure Storage Explorer` app

## Update env context for old web portal `web-portal` directory

1. Adjust [endpoints.js](../cdn-env-context/endpoints.js)
2. Upload the file to azure storage (deploy scripts don't overwrite this file later)
   1. `Azure Subscription 1` -> `Storage Accounts` -> `monsensowebapps` -> `Blob Containers` 
   -> `$web` -> `web-portal`
   2. Create new directory fx `test-02` . Note that this must match web apps release pipelines env naming for deployment.
   3. Upload the file

## Update env context for web apps' directories

1. Adjust [config.json](../cdn-env-context/endpoints.js). Note that this must match the naming done for the key in [monsenso-library' s endpoints.ts](https://github.com/Monsenso/monsenso-library/blob/main/src/model/endpoints.ts)
2. Upload the file to azure storage (deploy scripts don't overwrite this file later)
   1. `Azure Subscription 1` -> `Storage Accounts` -> `monsensowebapps` -> `Blob Containers`
   -> `$web` -> `1 out of 4 web apps`
   2. Create 2 new directories fx `test-02/assets` . Note that this must match web apps release pipelines env naming for deployment.
   3. Upload the file.