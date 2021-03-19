## App Service configuration
- Every app service and function app should have the same application settings as the 
corresponding services in the environment that is being copied/replicated.
- Look up the function app and the app services in Azure Portal for the environment you're copying from, and the one you're copying to:
    - Select Settings -> Configuration in the left hand menu.
    - Copy the application settings and adjust the values.
        - Clicking `Advanced edit` makes it a lot easier.
        - Make sure any ID settings have the correct value, fx the value of
        `AZURE_ANALYTICS_WORKSPACE_ID` should refer to the correct Log Analytics workspace.
    - The services are fx:
        - `monsenso-weu-prd-rest-web-service`
        - `monsenso-weu-prd-jobserver-web-service`
        - `monsenso-weu-prd-auth-web-service`
        - `monsenso-weu-prd-system-functions` (Function App)
- Note that the services require access to the key vault, this should already have been setup 
when the environment was created. If that cannot be done, or it just hasn't been done, it can 
be fixed by going to the key vault in question:
    - Access policies in left hand menu.
    - Add Access Policy.
    - Click Secret permissions -> Get.
    - Click Principal and select the function app/service in question.
- The key vault needs to allow access from all networks, and as above, it should have been 
setup from the start. If it is not:
    - Go to the key vault.
    - Networking in left hand menu.
    - Firewall and virtual networks tab.
    - Allow access from: All networks.