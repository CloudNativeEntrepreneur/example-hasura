HASURA_ENDPOINT?=http://example-hasura.default.127.0.0.1.sslip.io
LOCAL_DEV_CLUSTER ?= kind-local-dev-cluster
NOW := $(shell date +%m_%d_%Y_%H_%M)
SERVICE_NAME := example-hasura
HASURA_GRAPHQL_DATABASE_URL=postgres://readmodel:$(kubectl get secret readmodel.example-readmodel-postgresql.credentials.postgresql.acid.zalan.do)@readmodel.default.cluster.svc.local:5432/readmodel

# Does what's described in Readme, runs in the background - `attach-to-tmux-session` to attach to the session where it is running
dev:
	tmux new-session -d -s web3auth-example
	tmux send-keys -t web3auth-example 'tmux new-window -n psql-port-forward ' ENTER
	tmux send-keys -t web3auth-example 'tmux new-window -n hasura ' ENTER
	tmux send-keys -t web3auth-example "tmux send-keys -t psql-port-forward 'kubectl port-forward example-readmodel-postgresql-0 5433:5432' ENTER" ENTER
	tmux send-keys -t web3auth-example "tmux send-keys -t hasura 'make up' ENTER" ENTER

attach-to-tmux-session:
	tmux attach -t web3auth-example

onboard: dev

migrate:
	hasura metadata apply --endpoint $(HASURA_ENDPOINT)
	hasura migrate apply --all-databases --endpoint $(HASURA_ENDPOINT)
	hasura metadata reload --endpoint $(HASURA_ENDPOINT)

build-new-local-image:
	kubectl ctx $(LOCAL_DEV_CLUSTER)
	docker build -t $(SERVICE_NAME) .
	docker tag $(SERVICE_NAME):latest dev.local/$(SERVICE_NAME):$(NOW)

load-local-image-to-kind:
	kubectl ctx $(LOCAL_DEV_CLUSTER)
	kind --name local-dev-cluster load docker-image dev.local/$(SERVICE_NAME):$(NOW)

deploy-to-local-cluster:
	kubectl ctx $(LOCAL_DEV_CLUSTER)
	helm template ./charts/$(SERVICE_NAME)/ \
		-f ./charts/$(SERVICE_NAME)/values.yaml \
		--set image.repository=dev.local/$(SERVICE_NAME),image.tag=$(NOW) \
		| kubectl apply -f -
	kubectl wait --for=condition=ready ksvc example-hasura

delete-local-deployment:
	kubectl ctx $(LOCAL_DEV_CLUSTER)
	helm template ./charts/$(SERVICE_NAME)/ \
		-f ./charts/$(SERVICE_NAME)/values.yaml \
		--set image.repository=dev.local/$(SERVICE_NAME),image.tag=$(NOW) \
		| kubectl delete -f -

refresh-kind-image: build-new-local-image load-local-image-to-kind deploy-to-local-cluster
hard-refresh-kind-image: delete-local-deployment build-new-local-image load-local-image-to-kind deploy-to-local-cluster

localizer:
	localizer expose default/$(SERVICE_NAME) --map 80:3000

stop-localizer:
	localizer expose default/$(SERVICE_NAME) --stop

up:
	./scripts/run-using-local-dev-cluster-db.sh

down:
	docker-compose down --remove-orphans