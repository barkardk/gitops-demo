# Create a VM   
Creates a simple e2-medium GCP vm for various usages and tool testing 

## Prerequisites 
jq 
```bash
brew install jq
```

Be authenticated with gcloud
```bash
gcloud auth application-default login
```
You can create a service account to run this and then set the service account to create the VM instead
Google gcp service account set into a local file. This file will not be provided but must be generated.
```bash
gcloud iam service-accounts create "sa-kba" --display-name="K Barkardottir service account "
EMAIL=$(gcloud iam service-accounts list | grep sa-kba | awk '{print $5}')
PROJECT=$(gcloud config get-value project)
gcloud projects add-iam-policy-binding "${PROJECT}" --member=serviceAccount:"${EMAIL}" --role='roles/editor' 
gcloud projects add-iam-policy-binding "${PROJECT}" --member=serviceAccount:"${EMAIL}" --role='roles/iam.serviceAccountUser' 

gcloud iam service-accounts list

gcloud iam service-accounts keys create compute-instance.json --iam-account ${EMAIL}  
created key [<REDACTED>] of type [json] as [compute-instance.json] for [sa-kba@<REDACTED>]
```
### Google apis must be enabled
Go here [API]( https://console.developers.google.com/apis/api/compute.googleapis.com/overview?) to enable
* Cloud Resource Manager API   


## Run 
```bash 

make apply <SA=service-account> 
# Eg using the default sa-kba 
make apply  
# or custom service account 
make apply SA=your-sa
```

## Connect 

```bash
make ssh
## Take the public ip and ssh
IP=$(make ssh)
ssh -i .ssh/google_compute_engine $USER@$IP

```
