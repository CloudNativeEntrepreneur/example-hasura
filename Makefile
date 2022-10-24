HASURA_ENDPOINT?=http://example-hasura.default.127.0.0.1.sslip.io
LOCAL_DEV_CLUSTER ?= rancher-desktop
NOW := $(shell date +%m_%d_%Y_%H_%M)
SERVICE_NAME := example-hasura
HASURA_GRAPHQL_DATABASE_URL=postgres://readmodel:$(kubectl get secret readmodel.example-readmodel-postgresql.credentials.postgresql.acid.zalan.do)@readmodel.default.cluster.svc.local:5432/readmodel

# Does what's described in Readme, runs in the background - `attach-to-tmux-session` to attach to the session where it is running
onboard: refresh-kind-image

open:
	code .

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
	helm template helm/ \
		-f helm/values.yaml \
		--set image.repository=dev.local/$(SERVICE_NAME),image.tag=$(NOW) \
		| kubectl apply -f -
	kubectl wait --for=condition=ready ksvc example-hasura --timeout=600s

delete-local-deployment:
	kubectl ctx $(LOCAL_DEV_CLUSTER)
	helm template helm/ \
		-f helm/values.yaml \
		--set image.repository=dev.local/$(SERVICE_NAME),image.tag=$(NOW) \
		| kubectl delete -f -

refresh-kind-image: build-new-local-image load-local-image-to-kind deploy-to-local-cluster
hard-refresh-kind-image: delete-local-deployment build-new-local-image load-local-image-to-kind deploy-to-local-cluster
