## Flux makefile
.DEFAULT_GOAL := help

export TF_VAR_project_id = $(shell gcloud config get-value project)
export TF_VAR_project_name = argocd
export TF_VAR_cluster_name = $(TF_VAR_project_id)-$(TF_VAR_project_name)-gke

.PHONY: help
help: ## Help
	@grep -E '^[a-zA-Z\\._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: get
get: ## Import terraform packages
	@echo "-> $@"
	@terraform get

.PHONY: init
init: ## Initialize terraform
	@echo "-> $@"
	terraform init --backend-config="bucket=terraform-backend-$(TF_VAR_project_id)-$(TF_VAR_project_name)" --upgrade

.PHONY: configure
configure: ## PLan terraform
	@echo "-> $@"
	terraform plan -out apply.tfplan

.PHONY: run
run: ## Apply terraform
	@echo "-> $@"
	terraform apply -auto-approve

.PHONY: show
show: ## Show the terraform plan
	@echo "-> $@"
	@terraform show -json apply.tfplan | jq > tfplan.json

.PHONY: apply
apply: get init configure run ## Initialize, plan and apply terraform

.PHONY: destroy
destroy: delete-backend ## Cleanup terraform resources and backend bucket
	@echo "-> $@"
	terraform destroy

.PHONY: delete-backend
delete-backend: ## Delete a google bucket
	@echo "-> $@"
	@gsutil rb gs://terraform-backend-$(TF_VAR_project_id)-$(TF_VAR_project_name) || true

.PHONY: backend
backend: ## Create a google bucket
	@echo "-> $@"
	gsutil mb gs://terraform-backend-$(TF_VAR_project_id)-$(TF_VAR_project_name)
	@echo "Sleeping 30s to allow backend to initialize"
	sleep 30
	@echo "done"


