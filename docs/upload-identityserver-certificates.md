## Upload `signing-cert.pfx` and `extra-valid-cert.pfx`

- To enable FTPS, go to App Service -> Configuration -> General Settings and set FTP state to
  FTPS only.
- Find the certificates in `IdentityServer/src`.
- To connect to the App Service via FTPS, go to App Service -> Deployment Center ->
  Deployment/FTPS Credentials. A sidebar will open with the info you need to connect.
  - The path to copy the certificates to should match the path set in the value of
    Configuration -> Application Settings -> `SIGNING_CERT_PATH` and `EXTRA_VALID_CERT_PATH`.
    This value could fx be `/home/certificates/extra-valid-cert.pfx`.
    Note: On the app service file system uploading via FTPS to `/certificates` maps to
    `/home/certificates` directory (can be verified via SSH on the app service vm )
  - On macOS e.g. FileZilla app supports FTPS

## Cleanup

- Disable FTPS again.