## Running `setup-secrets.sh`

### Prerequisites

- Log in into azure 'az login' and container registry 'az acr login -n monsenso' (requires
  docker daemon running)
- Note the required variables to be set, e.g.:
  `SERVING_REGION=eu`
  `DEPL_REGION=weu`
  `ENV=dev`
- Make sure you are using the correct subscription by setting the default one.

    ```bash
      use 'az account set --subscription <subscription id>' to change subscription
      use 'az account list --output table' to show a list of available subscriptions
    ```

  - If the desired subscription is not listed as an option, do "az login" to refresh local
    subscription list state.
  - If the subscription is not available in some create dialog on the Azure portal,
    try logging out and in again.

### Script execution

- Full command example: `SERVING_REGION=eu DEPL_REGION=weu ENV=dev ./setup-secrets.sh`.
- Any missing ResourceGroups should be created on the subscription.
- You will be prompted for the following values:
  - `currentSigningCertificatePassword`: Copy this from an existing env of same type.
  - `dataProtectionBlobUri`: URI for the storage blob file. Copy this from `appsettings.json`
    `dataProtectionBlobUri` in IdentityServer corresponding with the environment, you are
    setting up. (If unavailable environment create new [one](https://dev.azure.com/monsenso/Clients/_wiki/wikis/Wiki/88/Renew-IdentityServer-data-protection-shared-access-signature))
    - Example value:
      `https://monsensoservices.blob.core.windows.net/data-protection/keys-dev.xml?sv=2020-02-10&ss=bfqt&srt=sco&sp=rwdlacupx&se=2021-04-23T18:02:17Z&st=2021-03-23T11:02:17Z&spr=https&sig=GTog9HSkMmWO9jA1XuJYaZC9Hd4IobPxKDrvfkw4JZw%3D`
  - `fcmServiceAccountKey`: FCM service account key can be found on [console.firebase.google.com](https://console.firebase.google.com)
    -> Project Settings for the environment you're setting up (Fx `green-development` for dev environment, `monsenso-green` for test, beta, prod environment)
    -> Service Accounts -> Generate new private key.
    - This will download a .json file, and the contents should be set as the value. You will be
      asked for the path to this file, from which the contents will be read.
  - `identityServerClientSecret`: OAuth client secret. Generate a cryptographic strong secret fx
    [In Browser secret generator](https://cloud.google.com/network-connectivity/docs/vpn/how-to/generating-pre-shared-key)
  - `mailjetApiSecret`: Copy this from an existing env of same type.
  - `oldSigningCertificatePassword`: Copy this from an existing env of same type.
  - `systemFunctionsHostKey`: This might fail if the Function App has not been deployed yet.
    In this case, it will be added later in step 10 of the README guide.
  - `withingsClientSecret`: You will NOT be prompted for this key. It has to be manually added,
    either by using an existing secret value (discouraged due to 120 requests/1 minute withings limitation),
    or creating a new Withings client with corresponding secret. If a new client is needed,
    Withings sysadmin's account access is needed.
    [Follow the Withings guide](https://developer.withings.com/developer-guide/getting-started/register-to-withings-api). (Application name: "Monsenso", Contact email:
    "sysadmin+withings-${put environment fx "test-two"}-azure-test-02@monsenso.com", Callback-URL
    "https://green.monsenso.com", Environment: "Prod" for production, beta, test environments)

### Cleanup

  In order that `setup-secrets.sh` can access the key vault, the key vault needed to allow access from all networks or whitelisted IP. It is best security practice to narrow down this access after the `setup-secrets.sh` was run.

### Troubleshooting

  - The scripts assumes naming conventions. If a script is failing check the name of the requested
  Azure resource and adjust the script for this special exceptional case (e.g. due to name max 24 chars
  monsensoweutst-02sysfunc01 was named monsweutst02sysfunc01)