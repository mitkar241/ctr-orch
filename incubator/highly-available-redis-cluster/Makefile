.DEFAULT_GOAL := help  # Set 'help' as the default target

.PHONY: add-repo install-redis uninstall-redis install-client uninstall-client delete-master exec-client watch-pods help

# Help command to list available targets
help:  
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Add Bitnami Helm Repo
add-repo:  ## Add the Bitnami Helm repository
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update

# Install Redis using Helm with custom override values
install-redis:  ## Install Redis with Helm using override.yaml
	helm install redis bitnami/redis --values override.yaml

# Uninstall Redis
uninstall-redis:  ## Uninstall Redis release
	helm uninstall redis

# Install Redis Client using Helm
install-client:  ## Install Redis Client with Helm
	helm install redis-client ./helm/

# Uninstall Redis Client
uninstall-client:  ## Uninstall Redis Client release
	helm uninstall redis-client

# Delete the current master pod (ERROR)
delete-master: ## Delete the current master pod
	kubectl delete po $(kubectl get pods --selector=isMaster=="true" --output=jsonpath="{.items[0].metadata.name}")

# Execute Redis increment script inside the client pod
exec-client:  ## Execute increment script inside Redis client pod
	kubectl exec -it redis-client -- ./client-increment.sh

# Watch Kubernetes Pods in real-time
watch-pods:  ## Stream pod status in real-time
	kubectl get po -w
