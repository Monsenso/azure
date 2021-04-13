## Running `setup-secrets.sh`

- Note the required variables to be set, e.g.:
  `SERVING_REGION=eu`
  `DEPL_REGION=weu`
  `ENV=dev`
- Full command example: `SERVING_REGION=eu DEPL_REGION=weu ENV=dev ./setup-secrets.sh`.
- Make sure you are using the correct subscription.
  - If the desired subscription is not listed as an option, do "az login" to refresh local
    subscription list state.
  - If the subscription is not available in some create dialog on the Azure portal,
    try logging out and in again.
- Any missing ResourceGroups should be created on the subscription.
- You will be prompted for the following values:
  - `currentSigningCertificatePassword`: Copy this from an existing env of same type.
  - `dataProtectionBlobUri`: URI for the storage blob file. Copy this from `appsettings.json`
    `dataProtectionBlobUri` in IdentityServer corresponding with the environment, you are
    setting up.
    - Example value:
      `https://monsensoservices.blob.core.windows.net/data-protection/keys-dev.xml?sv=2020-02-10&ss=bfqt&srt=sco&sp=rwdlacupx&se=2021-04-23T18:02:17Z&st=2021-03-23T11:02:17Z&spr=https&sig=GTog9HSkMmWO9jA1XuJYaZC9Hd4IobPxKDrvfkw4JZw%3D`
  - `fcmServiceAccountKey`: FCM service account key can be found on `console.firebase.google.com`
    -> Project Settings for the environment you're setting up (Fx `Green Development` for dev env)
    -> Service Accounts -> Generate new private key. (ATTOW the Test env is the same as the
    prod, i.e. `Green`)
    - This will download a .json file, and the contents should be set as the value. To get a
      one line input fit for pasting in terminal, use fx `jq`:
      `jq -c . <downloaded-file.json>`
  - `identityServerClientSecret`: OAuth client secret. Copy this from an existing env of same type.
  - `mailjetApiSecret`: Copy this from an existing env of same type.
  - `oldSigningCertificatePassword`: Copy this from an existing env of same type.
  - `systemFunctionsHostKey`: This might fail if the Function App has not been deployed yet.
    In this case, do step 10 of the README guide.
