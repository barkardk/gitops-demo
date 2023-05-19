# gitops-demo-flux
Demo repo with flux cd pipelines

## Prerequisites
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

## Install 
First time install
cd terraform/flux 
```bash 
$ make apply 
```

## Connect 
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
  

