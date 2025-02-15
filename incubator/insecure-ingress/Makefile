.PHONY: setup setup-k3s install-ingress uninstall-ingress install-my-app uninstall-my-app test-ingress-internal test-ingress-internal-cleanup test-ingress-external patch-coredns

setup: setup-k3s install-ingress patch-coredns install-my-app

setup-k3s:
	sudo k3s-uninstall.sh || true
	sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
	mkdir -p ~/.kube
	sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
	sudo chown $(USER):$(USER) ~/.kube/config

install-ingress:
	chmod +x ingress/install-nginx-ingress.sh
	./ingress/install-nginx-ingress.sh

uninstall-ingress:
	chmod +x ingress/uninstall-nginx-ingress.sh
	./ingress/uninstall-nginx-ingress.sh

patch-coredns:
	kubectl -n kube-system patch cm coredns --type merge --patch "$$(cat coredns/corefile.yaml)"
	kubectl -n kube-system rollout restart deployment/coredns

install-my-app:
	helm install my-app my-app/

uninstall-my-app:
	helm uninstall my-app

test: test-ingress-internal test-ingress-external

test-ingress-internal:
	@sh test/test_ingress_exec.sh
	@$(MAKE) test-ingress-internal-cleanup

test-ingress-internal-cleanup:
	@sh test/test_ingress_cleanup.sh

HOST_IP := $(shell hostname -I | awk '{print $$1}')

test-ingress-external:
	curl -H "Host: my-app.local" http://$(HOST_IP)
