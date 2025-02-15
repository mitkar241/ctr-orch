.PHONY: help setup cleanup setup-k3s install-ingress uninstall-ingress install-my-app uninstall-my-app test-internal-exec test-internal-cleanup test-external-exec patch-coredns unpatch-coredns install-vault uninstall-vault install-eso uninstall-eso

.DEFAULT_GOAL := help

help: ## Available commands
	@echo "Available commands:"
	@printf "\033[36m%-30s\033[0m %s\n" "setup" "Setup the entire environment"
	@printf "\033[36m%-30s\033[0m %s\n" "cleanup" "Cleanup the entire environment"
	@grep -E '^[a-zA-Z0-9_-]+:[[:space:]]*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "} {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: install-ingress patch-coredns install-vault install-eso install-my-app ## Setup the entire environment

cleanup: uninstall-my-app uninstall-eso uninstall-vault unpatch-coredns uninstall-ingress ## Cleanup the entire environment

setup-k3s: ## Setup K3s cluster
	chmod +x k3s/setup-k3s.sh
	./k3s/setup-k3s.sh

install-ingress: ## Install Nginx Ingress Controller
	chmod +x ingress/install-nginx-ingress.sh
	./ingress/install-nginx-ingress.sh

uninstall-ingress: ## Uninstall Nginx Ingress Controller
	chmod +x ingress/uninstall-nginx-ingress.sh
	./ingress/uninstall-nginx-ingress.sh

patch-coredns: ## Patch CoreDNS for custom DNS resolution
	chmod +x coredns/setup-coredns.sh
	./coredns/setup-coredns.sh

unpatch-coredns: ## Unpatch CoreDNS to restore default DNS resolution
	chmod +x coredns/cleanup-coredns.sh
	./coredns/cleanup-coredns.sh

install-vault: ## Install HashiCorp Vault
	chmod +x vault/setup-vault.sh
	./vault/setup-vault.sh

uninstall-vault: ## Uninstall HashiCorp Vault
	@sh vault/cleanup-vault.sh

install-eso: ## Install External Secrets Operator
	@sh eso/setup-eso.sh

uninstall-eso: ## Uninstall External Secrets Operator
	@sh eso/cleanup-eso.sh

install-my-app: ## Install the application
	@sh my-app/setup-my-app.sh

uninstall-my-app: ## Uninstall the application
	@sh my-app/cleanup-my-app.sh

test: test-internal-exec test-external-exec ## Run all tests

test-internal-exec: ## Run internal tests
	@sh test/test-internal-exec.sh
	@$(MAKE) test-internal-cleanup

test-internal-cleanup: ## Cleanup after internal tests
	@sh test/test-internal-cleanup.sh

test-external-exec: ## Run external tests
	@sh test/test-external-exec.sh
