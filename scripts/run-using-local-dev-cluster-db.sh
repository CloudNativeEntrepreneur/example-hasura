#!/bin/sh

PG_PASS=$(kubectl get secret readmodel.example-readmodel-postgresql.credentials.postgresql.acid.zalan.do -o jsonpath={.data.password} | base64 -D)
export HASURA_GRAPHQL_DATABASE_URL=postgres://readmodel:${PG_PASS}@host.docker.internal:5433/readmodel 

echo $HASURA_GRAPHQL_DATABASE_URL

docker-compose up