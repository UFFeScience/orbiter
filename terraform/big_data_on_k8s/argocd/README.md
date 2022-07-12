# Deploy ArgoCD
The deployment of ArgoCD was made through terraform with Helm Chart
## Commands to access ArgoCD UI
* Get auto generated admin password:  
```kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" -n cicd | base64 -d```