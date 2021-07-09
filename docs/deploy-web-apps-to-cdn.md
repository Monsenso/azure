# Adjust/Create `web app` deployment

[Azure web apps clients deployments](https://dev.azure.com/monsenso/Clients/_release?_a=releases&view=all&path=%5CClients)
are delivered through release pipelines designed in an editor. They utilise the [task group](https://dev.azure.com/monsenso/Clients/_taskgroup/7e647c2a-0ceb-43b3-81be-654f24aab39e) to deploy the respective web app to the monsensowebapps storage accounts `$web blob`

You need to adjust those pipelines according to the purpose and need of your new environment.

# Adjust/Create `services` deployment

[Azure services deployments](https://dev.azure.com/monsenso/Services/_git/Services?path=%2Fbuild)
are delivered through pipelines designed in yaml-pipeline "language".

You need to adjust those pipelines according to the purpose and need of your new environment.