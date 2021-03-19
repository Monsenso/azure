## Running `setup-secrets.sh`
- Note the required variables to be set, e.g.:
		`SERVING_REGION=eu`
		`DEPL_REGION=weu`
		`ENV=prd`
- Full command example: `SERVING_REGION=eu DEPL_REGION=weu ENV=prd ./setup-secrets.sh`.
- If the desired subscription is not listed as an option, do "az login" 
to refresh local subscription list state.
- Any missing ResourceGroups should be created on the subscription.
- If the subscription is not available in some create dialog on the Azure portal, 
try logging out and in again.