# Purpose

The web apps are delivered through CDN. We use one CDN endpoint and deploy/deliver via
following logical mapping e.g.:
    Custom domain: `admin.test-02.monsenso.com`
        ->
    storage account: `monsensowebapps/blob containers/$web/funmachine/test-02` directory containing
    funmachine deployment for test-02

## Add CDN custom domains for web apps

1. Open the [CDN page on Azure Portal](https://portal.azure.com/#@monsenso.com/resource/subscriptions/ec51da25-eb08-4ef6-979c-450aa85fba8f/resourceGroups/web-apps/providers/microsoft.cdn/profiles/monsenso-cdn/overview).
2. Click `monsenso-cdn`
3. Click `monsenso.azureedge.net` endpoint
4. Add custom domains for your environment needs of web apps + translations

## Adjust the CDN rule engine for web apps + translations

1. Open the [CDN page on Azure Portal](https://portal.azure.com/#@monsenso.com/resource/subscriptions/ec51da25-eb08-4ef6-979c-450aa85fba8f/resourceGroups/web-apps/providers/microsoft.cdn/profiles/monsenso-cdn/overview).
2. Click the `Manage` link in the horizontal menu.
3. On the CDN management site, open the `HTTP Large` menu and click `Rules Engine V4.0`.
4. Update the Rules Engine policy.
   1. Download the current production policy and rename file to accordingly (version and purpose of change).
   2. Copy in a local text editor the relevant sections for an environment and adjust with naming of your environment.
   3. Create an empty policy draft and import the local changed policy file within.
   4. Lock the policy.
   5. Deploy the policy to [Staging for testing](https://docs.whitecdn.com/cdn/index.html#HRE/Environment.htm#Staging).
   6. When tested, deploy the policy to Production. It will probably take at least 15 minutes for the changes to take effect.