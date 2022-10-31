HASURA_ENDPOINT?=http://example-hasura.example-local-env.127.0.0.1.sslip.io
LOCAL_DEV_CLUSTER ?= rancher-desktop
NOW := $(shell date +%m_%d_%Y_%H_%M)
SERVICE_NAME := example-hasura
HASURA_GRAPHQL_DATABASE_URL=postgres://readmodel:$(kubectl get secret readmodel.example-readmodel-postgresql.credentials.postgresql.acid.zalan.do)@readmodel.example-local-env.cluster.svc.local:5432/readmodel

# Does what's described in Readme, runs in the background - `attach-to-tmux-session` to attach to the session where it is running
onboard:
	echo "Nothing to do. Deploy using gitops config."

open:
	code .

migrate:
	hasura metadata apply --endpoint $(HASURA_ENDPOINT)
	hasura migrate apply --all-databases --endpoint $(HASURA_ENDPOINT)
	hasura metadata reload --endpoint $(HASURA_ENDPOINT)
