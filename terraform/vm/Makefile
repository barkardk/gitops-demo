# VM Makefile
.DEFAULT_GOAL := help
SA?=sa-kba
export TF_VAR_project_id=$(shell gcloud config get-value project)
export TF_VAR_service_account_id=$(shell gcloud iam service-accounts list --filter="email ~ sa-kba*" --format=json |jq -r '.[].email')
export TF_VAR_service_account_name=${SA}
.PHONY: help
help: ## Help
	@grep -E '^[a-zA-Z\\._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: init
init: ## Initialize terraform
	terraform init

.PHONY: configure
configure: ## Plan terraform
	terraform plan -out apply.tfplan
.PHONY: run

run: ## Apply terraform
	terraform apply -auto-approve -var-file=terraform.tfvars

.PHONY: show
show: ## Show the compiled terraform plan
	terraform show -json apply.tfplan | jq > tfplan.json

apply: init configure run ## Init, plan and apply terraform

.PHONY: destroy
destroy: ## Cleanup terraform resources
	terraform destroy

.PHONY: ssh
ssh: ## Get the public ip address of the VM
	terraform output public_ip

IP := $(shell terraform output public_ip)
USER := sa-kba
.PHONY: ssh-login
ssh-login:
	ssh -i .ssh/google_compute_engine ${SA}@${IP}
