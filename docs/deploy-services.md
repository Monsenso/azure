## Deploying Services and Function Apps to Azure
- Create `appsettings.<environment-name>.json` for each of the apps to be deployed, i.e.: 
JobServer, RestService, Auth/IdentityServer and AzureFunctions.
	- `couchbase.serverUris`: The subscription has a private DNS that handles the naming, 
	and VMs are automatically added, so if in doubt of the value of this, look up the DNS and 
	build the URI value from that. 
	- `mailJet.apiKey` is the mailJet "username". Copy this value from an existing appsettings 
	of the same environment.
	- `Withings`: Every region needs it's own Withings client in order to respect the 
	120 request/minute limit. A new Withings client needs to be created by someone with access 
	to the sysadmin account that does this:
		- Have someone create the new Withings client.
		- Put the client ID in the appsettings file as `Withings.key`.
		- Add the secret to the key vault.
	- `dataProtectionBlobUri`: 
		- Needs to be a unique file name for the environment, so update that to e.g.:
			- `.../keys-eu-prod.xml?...` for an eu prod environment.
		- The parameters after the filename include SAS token and more, copy this from an 
		existing appsettings unless otherwise instructed.
