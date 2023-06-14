## Flux makefile
.DEFAULT_GOAL := help
TF_VAR_project_id := $(shell gcloud config get-value project)
TF_VAR_project_name = fluxcd
TF_VAR_cluster_name = $(TF_VAR_project_id)-$(TF_VAR_project_name)-gke

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



