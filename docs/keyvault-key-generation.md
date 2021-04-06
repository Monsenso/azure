## Create/generate keys in the key vault

- Find the key vault resource fx by searching for "key vault" under all resources.
  - Note the search filters: Make sure you're filtering for the correct environment.
- You need permissions for the key vault to create keys.
- Use the default settings for key type, size etc.
- If access to the key vault keys is blocked, it could be because your IP has not been
  whitelisted. Go to Networking and add your public IP to the Firewall section.
- This is a good opportunity to verify that the Access policies are configured correctly,
  making sure that the Function App and App Services have the necessary permissions.
  All the applications should have the `Get` Secret Permission, and the IdentityServer/Auth web
  service should in addition have the `Unwrap Key` and `Wrap Key` Cryptographic Operations
  permissions (This is necesarry to be able to use the `data-protection` key to encrypt and
  decrypt the key stored in the `monsensoservices` storage account).
  - If the applications are not added as principals, they should be (click `+ Add Access Policy`).
    This should have already been set up.
