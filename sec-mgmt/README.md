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
And helm 
```bash
brew install helm
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
REGION=$(grep region terraform.tfvars | awk -F\" '{print $2}') 
$ gcloud container clusters get-credentials ${PROJ}-gke --region ${REGION} --project ${PROJ}
# Make sure to enable workload identity
$ gcloud container clusters update ${PROJ}-gke --workload-pool=${PROJ}.svc.id.goog --region ${REGION}
```
## Using the CSI driver

---
### Create a fresh cluster
```bash
make apply
```
Make sure you connect to it
```bash
gcloud container clusters  get-credentials  <cluster> --region <region>
```
### Enable Workload identity
```bash 
PROJ=$(gcloud config get-value project)
REGION=$(grep region terraform.tfvars | awk -F\" '{print $2}')  
$ gcloud container clusters update ${PROJ}-gke --workload-pool=${PROJ}.svc.id.goog --region ${REGION}
```
https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#enable_on_existing_cluster

### Next, Install the CSI driver and the gcp plugin
https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html
https://github.com/GoogleCloudPlatform/secrets-store-csi-driver-provider-gcp
```bash
make secret-store
```

Verify 
```bash 
$ kubectl --namespace=kube-system get pods -l "app=secrets-store-csi-driver"
$ kubectl --namespace=kube-system get pods -l "app=secrets-store-csi-driver"

```

This will create namespace admin with service account admin
Setup the google `gke-workload` workload identity service account 
```bash
PROJ=$(gcloud config get-value project)
gcloud config set project ${PROJ}
# Create a workload service account that we use for binding
gcloud iam service-accounts create gke-workload
```

Allow the serviceaccounts admin and readonly to act as the new service account
```bash
PROJ=$(gcloud config get-value project)
## NOTE I had issues with this command in zsh for some reason
## Switching to bash helped 
$ bash
$ gcloud iam service-accounts add-iam-policy-binding readwrite-secrets@${PROJ}.iam.gserviceaccount.com --member=serviceAccount:"${PROJ}".svc.id.goog[admin/admin] --role='roles/iam.workloadIdentityUser'
```
Deploy a k8s application
```bash
make deploy
```

Create a secret Eg a google API key
```bash
$ gcloud alpha services api-keys create --display-name="demo secret"
# export the key from the above step into a text file called bq-readonly-key
key=<my-api-key>
$ gcloud secrets create bq-readonly-key --data-file=bq-readonly-key --ttl=360000s
```
Now bind the Google service account `gke-workload` created above with read permissions to the secrets manager ,
to the kubernetes service account that the deployment uses
```bash
PROJ=$(gcloud config get-value project)
$ gcloud secrets add-iam-policy-binding bq-readonly-key --member=serviceAccount:gke-workload@$PROJ.iam.gserviceaccount.com  --role=roles/secretmanager.secretAccessor
```




---
## Using the Google SDK 
> This methd relies on the apps in the pods utilizing GKE library to fetch the secrets  

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

$ gcloud secrets add-iam-policy-binding bq-readonly-key --member=serviceAccount:readwrite-secrets@{PROJ}.iam.gserviceaccount.com --role='roles/secretmanager.secretAccessor'
$ gcloud secrets add-iam-policy-binding bq-readonly-key --member=serviceAccount:readwrite-secrets@${PROJ}.iam.gserviceaccount.com --role='roles/secretmanager.secretVersionAdder'
```

### Install the k8s manifests
> You need helm to install the manifests

```bash
helm template kubernetes/demo-secrets
PROJ=$(gcloud config get-value project)
helm install secrets --set project_id=${PROJ} kubernetes/demo-secrets 

# or 
$ make deploy
```

And now bind the IAM service accounts to the k8s service accounts 
```bash
PROJ=$(gcloud config get-value project)

# Make sure to enable workload identity
REGION=$(grep region terraform.tfvars | awk -F\" '{print $2}') 
$ gcloud container clusters update ${PROJ}-gke --workload-pool=${PROJ}.svc.id.goog --region ${REGION}

$ gcloud iam service-accounts add-iam-policy-binding readonly-secrets@${PROJ}.iam.gserviceaccount.com --member=serviceAccount:${PROJ}.svc.id.goog[readonly/readonly] --role='roles/iam.workloadIdentityUser'
$ gcloud iam service-accounts add-iam-policy-binding readwrite-secrets@${PROJ}.iam.gserviceaccount.com --member=serviceAccount:"${PROJ}".svc.id.goog[admin/admin] --role='roles/iam.workloadIdentityUser'
```

In case of errors of insufficcient privileges
```text
Access scopes
You must stop the VM instance to edit its API access scopes

Allow default access

Allow full access to all Cloud APIs 
```

## Test the secrets

---
#### For RO 
Open a shell 
```bash
kubectl exec -it readonly --namespace=readonly -- /bin/bash
gcloud secrets versions access 1 --secret=bq-readonly-key
```
As this is a readonly secret, trying to write or overwrite it will fail
```bash
printf "my-second-api-key" | gcloud secrets versions add bq-readonly-key --data-file=-
```

#### For RW

```bash
kubectl exec -it admin-test --namespace=admin-ns -- /bin/bash
gcloud secrets versions access 1 --secret=bq-readonly-key
printf "my-second-api-key" | gcloud secrets versions add bq-readonly-key --data-file=-
## Read the new version
gcloud secrets versions access 2 --secret=bq-readonly-key
```

