helm -n external-secrets uninstall external-secrets
kubectl delete pvc --all -n external-secrets
kubectl delete namespace external-secrets

helm -n vault uninstall vault
kubectl delete pvc --all -n vault
kubectl delete namespace vault
