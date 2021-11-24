# example-hasura

Auth Example's Hasura instance, configs, migrations, and job to run migrations.

## Environment Variabls

### `HASURA_GRAPHQL_ENDPOINT`

Using this env when running Hasura console will override the value in `config.yaml`.

```
HASURA_GRAPHQL_ENDPOINT=http://some-endpoint hasura console
```

To get the Hasura url, run `kubectl get ksvc` in the namespace.

```
NAME                           URL                                                                LATESTCREATED                        LATESTREADY                          READY   REASON
example-hasura                https://example-hasura.jx-staging.cloudnativeentrepreneur.com                 example-hasura-00008                example-hasura-00008                True   
```

### Model services

To add a new model service as an available env variable for Hasura actions, edit `charts/example-hasura/templates/ksvc.yaml`

## What the Chart creates

This chart provisions a PSQL cluster with two databases, `hasura` owned by the user `hasura`, and `sourced` owned by the user `sourced`, as well as a knative serving service that runs the hasura-graphql-engine.
