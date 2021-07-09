# Configuration of couchbase data

## Initial and clinics data configuration via script

QA configures the system. See [Fetching/migrating Couchbase wiki ](https://dev.azure.com/monsenso/Clients/_wiki/wikis/Wiki/9/Fetching-and-migrating-documents-from-Couchbase)
Fx:

```bash
 bundle exec ruby lib/migration.rb -u heinzle -p <password> -e test2 --skip --execute 6.68.0
```

where in [clinics data](https://github.com/Monsenso/migration) in folder 6.68.0 exist

- `create admin account ruby script`
- `auth_bucket` with invitations document
- `data_bucket` with all other documents

Note: in the migration repo the `lib/migration.rb` must be adjusted to include new env:

- `def validate_args!` - add new environment name
- `def coerce_host_arg!` - add host name for new environment

Note: Add the new couchbase instance to [monsenso-ruby-library repo](https://github.com/Monsenso/monsenso-ruby-library/blob/main/lib/)monsenso/database.rb#L56

## Create the following documents on Couchbase manual in cb web ui

1. `version` (in data bucket) with value from an identical environment. (QA uses --skip in the script so it does not get updated by script. To be clarified/ TODO)
2. `id-counter` (in auth bucket) with value `1`

## system_clients configuration

The couchbase script initially deployed a [system_clients](/couchbase/auth-bucket/docs/system_clients.json) OpenId/OAuth2.0 configuration. Per environment this might need adjustment.