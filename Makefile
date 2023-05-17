TF_VAR_project_id=$(shell gcloud config get-value project)

init:
	cd terraform && terraform init

configure:
	cd terraform && terraform plan -out apply.tfplan

apply:
	cd terraform && terraform apply -auto-approve -var-file=terraform.tfvars

show:
	cd terraform && terraform show -json apply.tfplan | jq > tfplan.json



