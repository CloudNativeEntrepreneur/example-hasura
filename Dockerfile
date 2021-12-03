# This container runs migrations - the main hasura service is hasura/graphql-engine:v2.x.x
FROM hasura/graphql-engine:v2.0.10.cli-migrations-v3

# we are managing migrations with schemahero - so let's avoid copying it here unless we go back to using Hasura for migrations.
# we still want the metadata and config though
COPY metadata metadata
# COPY migrations migrations
COPY config.yaml config.yaml
COPY apply-migrations.sh apply-migrations.sh

ENTRYPOINT [ "./apply-migrations.sh" ]
