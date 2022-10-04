#!/bin/bash

echo "Applying to Hasura GraphQL Endpoint: ${HASURA_GRAPHQL_ENDPOINT}"

/bin/hasura-cli metadata apply --endpoint ${HASURA_GRAPHQL_ENDPOINT}
/bin/hasura-cli migrate apply --all-databases --endpoint ${HASURA_GRAPHQL_ENDPOINT}
/bin/hasura-cli metadata reload --endpoint ${HASURA_GRAPHQL_ENDPOINT}