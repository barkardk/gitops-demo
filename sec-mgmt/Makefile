## Flux makefile
.DEFAULT_GOAL := help
TF_VAR_project_id := $(shell gcloud config get-value project)
PROJ := $(shell gcloud config get-value project)
.PHONY: help
help: ## Help
	@grep -E '^[a-zA-Z\\._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: init
init: ## Initialize terraform
	terraform init

.PHONY: configure
configure: ## PLan terraform
	terraform plan -out apply.tfplan

.PHONY: run
run: ## Apply terraform
	terraform apply -auto-approve -var-file=terraform.tfvars

.PHONY: show
show: ## Show the terraform plan
	terraform show -json apply.tfplan | jq > tfplan.json

.PHONY: apply
apply: init configure run ## Initialize, plan and apply terraform

.PHONY: destroy
destroy: ## Cleanup terraform resources
	terraform destroy

.PHONY: deploy
deploy: ## Install k8s pods
	echo ${PROJ}
	helm template demo-secrets kubernetes/demo-secrets --set project_id=${PROJ} | kubectl apply -f -

.PHONY: delete
delete: ## Uninstall k8s pods
	helm template demo-secrets kubernetes/demo-secrets --set project_id=${PROJ} | kubectl delete -f -

.PHONY: secret-store
secret-store: ## Install the CSI driver and then Secret manager provider GCP secret store for CSI driver
	helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
	helm upgrade --install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
	helm upgrade --install secrets-store-csi-driver-provider-gcp kubernetes/secrets-store-csi-driver-provider-gcp
