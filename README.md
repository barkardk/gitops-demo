# Gitops demo repository
## To setup Argocd demo 
```bash 
cd terraform/argocd
make apply
```

## To setup Fluxcd demo 

```bash 
cd terraform/flux
make apply
```
> Remember to cleanup using `make destroy`

## To create a VM instance for testing 
```bash
cd terraform/vm
make apply
```

> Remember to cleanup using `make destroy`
