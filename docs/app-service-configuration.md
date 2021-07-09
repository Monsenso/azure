## App Service configuration

- Every app service and function app should have the same application settings as the
  corresponding services in the environment that is being copied/replicated.
- Look up the function app and the app services in Azure Portal for the environment you're copying from, and the one you're copying to:
  - Select Settings -> Configuration in the left hand menu.
  - Copy the application settings and adjust the values.
    - Clicking `Advanced edit` makes it a lot easier.
    - Make sure any ID settings have the correct value.
  - The services are fx:
    - `monsenso-weu-prd-rest-web-service`
    - `monsenso-weu-prd-jobserver-web-service`
    - `monsenso-weu-prd-auth-web-service`
    - `monsenso-weu-prd-system-functions` (Function App)
- On the Function App, remember to setup CORS:

  1. Go to API -> CORS.
  2. Tick `Enable Access-Control-Allow-Credentials`.
  3. Add our web portal URLs as allowed origins, e.g. `https://my.dev.monsenso.com` and `https://portal.dev.monsenso.com`.
  4. Press `Save`.

- Similarly, add the web portal URLs as allowed origins on the SignalR service under Settings
  -> CORS.
- Note that the services require access to the key vault, this should already have been setup
  when the environment was created. If that cannot be done, or it just hasn't been done, it can
  be fixed by going to the key vault in question: Access policies in left hand menu -> Add Access Policy -> Click Secret permissions -> Get - Click Principal and select the function app/service in question.
- Help to specific setting values:
  - `Mon_Environment`: The environment designation, fx `development-eu`. This correlates with
    the name of the appsettings.json file, so make sure they match, e.g.
    `development-eu` -> `appsettings.development-eu.json`
  - `ASPNETCORE_ENVIRONMENT`: This determines the hosting environment value, and should correspond
    to the type of environment you are setting up, i.e. `Development` for a dev env. Note that
    omitting this app setting defaults the value to `Production`; For a dev environment, this can
    lead to CORS errors in the clients.
  - `Mon_Couchbase__Password`: At the time of writing, this value will not be picked up from
    the keyvault if it's only set in appsettings.json, so we override the value with an explicit
    keyvault reference here.
  - `TaskHubName`: Follow the naming convention, i.e. if the name of the Function App is:
    `monsenso-weu-dev-system-functions` -> `weudevsystemfunctions`
  - Any other setting starting with `Mon_`: This is a appsettings.json value, and will override
    the value coming from appsettings.json. These can generally be skipped and set in appsettings.json, which exception of the above mentioned and any explicit overrides that may be desired.
  - `Mon_Serilog__AzureAnalytics__PrimaryKey`: The secret is specified in the appsettings does not seem to resolve, pushing of logs failed authentication.
  - `Mon_Withings__Secret`: There is a 120 request/minute rate-limit for Withings, and to stay
    below that limit, each client in each region needs it's own Withings client. These clients
    are created by a sysadmin account, so if a new one is required, ask someone with access to
    create one for you.
