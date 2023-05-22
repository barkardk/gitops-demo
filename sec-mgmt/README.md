# gitops-demo-flux
Demo repo  

## Prerequisites
___
### You must have logged in to gcloud first 
```bash
gcloud auth application-default login
```
You also need the gke-gcloud-auth-plugin see [here](https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke)
```bash
gcloud components install gke-gcloud-auth-plugin
```

### Google apis must be enabled  
Go here [API]( https://console.developers.google.com/apis/api/compute.googleapis.com/overview?) to enable  
* Compute engine API   
* Kubernetes engine API   
* Secret manager API

TO install the container and secrets apis you can run this
```bash 
gcloud services enable container.googleapis.com secretmanager.googleapis.com
```


### Setup a  K8s cluster
First time install

```bash 
$ make apply 
```

### Connect 
To connect to the cluster authenticate with google  
You can find your cluster here  
```bash 
gcloud container clusters list
```
And note the name and region or
```bash
gcloud container clusters get-credentials <project-name>-gke --region <region> --project <project-name>
# Eg
PROJ=$(gcloud config get-value project)
REGION=$(grep region terraform/terraform.tfvars | awk -F\" '{print $2}') 
$ gcloud container clusters get-credentials ${PROJ}-gke --region ${REGION} --project ${PROJ}
```

## Components
___
We are going to use 
* GKE Autopilot 
* Secret manager

### Grant the roles needed to your google account
```bash
PROJ=$(gcloud config get-value project)
EMAIL=$(gcloud config get-value account)
$ gcloud projects add-iam-policy-binding ${PROJ} --member="user:${EMAIL}" --role=roles/secretmanager.admin
$ gcloud projects add-iam-policy-binding ${PROJ} --member="user:${EMAIL}" --role=roles/container.clusterAdmin
$ gcloud projects add-iam-policy-binding ${PROJ} --member="user:${EMAIL}" --role=roles/iam.serviceAccountAdmin
```

### Create a secret 
You need to generate an API key 
```bash 
# Eg gcloud alpha services api-keys create --display-name=<display name> --allowed-ips=<2620:15c:2c4:203:2776:1f90:6b3b:217,104.133.8.78>
$ gcloud alpha services api-keys create --display-name="demo secret" 
```

This creates a new secret manager secret with a bogs api key and sets the secret to expire 100 hours after the command has been run .

```bash
# export the key from the above step into a text file called bq-readonly-key
key=<my-api-key>

$ gcloud secrets create bq-readonly-key --data-file=bq-readonly-key --ttl=360000s
Do you want to continue (Y/n)?  Y
API [secretmanager.googleapis.com] not enabled on project [781365677071]. Would you like to enable and retry (this will take a few minutes)? (y/N)?  y
Enabling service [secretmanager.googleapis.com] on project [781365677071]...
Operation "operations/acat.p2-781365677071-20be4e9e-80bc-4948-ada5-9e1718285fc2" finished successfully.
Created version [1] of the secret [bq-readonly-key].
```

### Create IAM service accounts 
And grant proper access
```bash 
PROJ=$(gcloud config get-value project)
$ gcloud iam service-accounts create readonly-secrets --display-name="Read secrets"
$ gcloud iam service-accounts create readwrite-secrets --display-name="Read write secrets"

$ gcloud secrets add-iam-policy-binding bq-readonly-key --member=serviceAccount:readonly-secrets@${PROJ}.iam.gserviceaccount.com --role='roles/secretmanager.secretAccessor'
```
