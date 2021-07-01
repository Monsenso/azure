## Configure TLS for App Services

- Use certificate from step 5, it should have been added to the key vault by the script.
  - Go to: App Service -> TSL/SSL Settings -> Private Key Certificates -> Import Key Vault Certificate
  - Add the binding to the app services that need to use it:
    - Go to: App Service -> Custom domains -> Add binding
      - For TLS/SSL Type, select `SNI SSL`
