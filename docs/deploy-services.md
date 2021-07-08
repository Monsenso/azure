## Deploying Services and Function Apps to Azure
- Create `appsettings.<environment-name>.json` in the services repo.
	- `couchbase.serverUris`: The subscription has a private DNS that handles the naming, 
	and VMs are automatically added, so if in doubt of the value of this, look up the DNS and 
	build the URI value from that. 
	- `mailJet.apiKey` is the mailJet "username". Copy this value from an existing appsettings 
	of the same environment.
	- `Withings`: Every environment needs it's own Withings client in order to respect the 
	120 request/minute limit. A new Withings client needs to be created by someone with access 
	to the sysadmin account that does this:
		- Have someone create the new Withings client.
		- Put the client ID in the appsettings file as `Withings.key`.
		- Add the secret to the key vault under key `withingsClientSecret`
	- `dataProtectionBlobUri`: 
		- Needs to be a unique file name for the environment, so update that to e.g.:
			- `.../keys-weu-test-02.xml?...` for an weu test 02 environment.
		- Create the shared access signature as noted here <https://dev.azure.com/monsenso/Clients/_wiki/wikis/Wiki/88/Renew-IdentityServer-data-protection-shared-access-signature>

## Add Service Connection to Subscription

For the Services repo to be able to deploy to the App Services in a Subscription, a Service Connection is needed.

Follow [this guide](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) and for the selections:

- Select `Azure Resource Manager` as the connection type
- Select `Service Principal (automatic)` as the Authentication method
- Select the Subscription to connect to and give it a "good name", fx. the same name as the Subscription in question.

## Adjust pipelines

### Step 1: Enable deployment of app services + function app & deploy them.

- In the `Services` repo pipelines/templates are to be modified for the environment's need.
The minimal change is in `deploy.yaml` and `pipeline.pr.yaml` (for test env) | `pipeline.build.yaml` (for dev env)
| `pipeline.release.yaml` (for prod env) to add region/environment values.
Consult the git files history for examples of changes done previously.

- Push the changes to a branch and open a PR. For test env that PR must be approved by QA | for dev env that PR must
be merged | for prod a release must be triggered  
in order to trigger the deployment to Azure. You can verify that deployment happened inside the pipeline
steps as first indication and on appending `/health` endpoint to the http rest|auth service urls.
Note: it might be needed to restart manually all deployed services and function app once after first deployment.

### Step 2: Redeploy with added expandDataFunctionKey
As Step 1 did first (non-functional) deployment it is not possible to extract the value of `expandDataFunctionKey`
- `expandDataFunctionKey` : Get the function url of the ExpandData Function App in the subscription and extract the code param's
value: e.g.:
<https://monsenso-weu-dev-system-functions.azurewebsites.net/ExpandData?code=RKWqqF8WWHOuoIDK5Spa77D9hAMsjBD9YP6aaO6obvvFV2naQLqTdg==>
Add the code to the `invoke-expand-data.yaml` in the `Services` repo for the respective environment.
- `expandDataUrl` : Adjust the variable in same `invoke-expand-data.yaml` for the respective environment.