## Setup custom domains for App Services

- Add CNAME record to the monsenso.com DNS
  - Name should be desired domain name of service
  - Alias should be the domain name of the service
  - Example for new IdentityServer service:
    - The service's name is: monsenso-weu-prd-auth-web-service.azurewebsites.net
    - It should be hosted at auth.eu.monsenso.com
    - The CNAME record would then look like:
    - | Name    | Type  | TTL  | Value                                               |
      | ------- | ----- | ---- | --------------------------------------------------- |
      | auth.eu | CNAME | 3600 | monsenso-weu-prd-auth-web-service.azurewebsites.net |
- Add the custom domain via: App Service -> Custom domains
  - If the desired domain is eg. auth.eu.monsenso.com, simply add auth.eu.monsenso.com
  - You will get a warning about the custom domain not being secured. This will be handled in the next step.