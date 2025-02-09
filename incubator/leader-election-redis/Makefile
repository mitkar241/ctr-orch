.DEFAULT_GOAL := help  # Set 'help' as the default target

.PHONY: ci cd setup cleanup docker-build docker-delete helm-install helm-uninstall pod redis log help

# Help command to list available targets
help:  
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Docker build and delete
docker-build:  ## Build the Docker image
	bash build/build.sh

docker-delete:  ## Delete the Docker image
	bash build/delete.sh

ci: docker-delete docker-build  ## Run CI: Delete + Build Docker Image

# Helm install and uninstall
helm-install:  ## Install the Helm chart
	helm install my-app helm/

helm-uninstall:  ## Uninstall the Helm chart
	helm uninstall my-app

cd: helm-uninstall helm-install  ## Run CD: Uninstall + Install Helm Chart

# Setup full CI/CD pipeline
setup: ci cd  ## Setup Full CI/CD Pipeline (CI + CD)

# Cleanup full CI/CD pipeline
cleanup: helm-uninstall docker-delete  ## Cleanup Full CI/CD Pipeline (CI + CD)

# Watch Kubernetes Pods
pod:  ## Watch pods in real-time
	kubectl get po -w

# Redis CLI access
redis:  ## Open Redis CLI inside the Redis pod
	kubectl exec -it $(kubectl get pod -l app=redis -o jsonpath="{.items[0].metadata.name}") -- redis-cli -h redis

# Tail leader logs
log:  ## Stream leadership logs in real-time
	tail -f /tmp/shared-data/leaders.log
