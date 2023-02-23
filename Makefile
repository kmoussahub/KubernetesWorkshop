# set the shell to bash always
SHELL         := /bin/bash

# set make and shell flags to exit on errors
MAKEFLAGS     += --warn-undefined-variables
.SHELLFLAGS   := -euo pipefail -c

.EXPORT_ALL_VARIABLES:


DEPS := $(shell find . -type f -name "helm" -printf "%p ")
CURRENT_DIR=$(shell pwd)

KIND_CLUSTER_NAME := workshop.local
K8S_LATEST := 1.25.3

.PHONY: help

# ====================================================================================
# Colors

BLUE         := $(shell printf "\033[34m")
YELLOW       := $(shell printf "\033[33m")
RED          := $(shell printf "\033[31m")
GREEN        := $(shell printf "\033[32m")
CNone        := $(shell printf "\033[0m")

# ====================================================================================
# Logger

TIME_LONG	= `date +%Y-%m-%d' '%H:%M:%S`
TIME_SHORT	= `date +%H:%M:%S`
TIME		= $(TIME_SHORT)

INFO	= echo ${TIME} ${BLUE}[ .. ]${CNone}
WARN	= echo ${TIME} ${YELLOW}[WARN]${CNone}
ERR		= echo ${TIME} ${RED}[FAIL]${CNone}
OK		= echo ${TIME} ${GREEN}[ OK ]${CNone}
FAIL	= (echo ${TIME} ${RED}[FAIL]${CNone} && false)

# ====================================================================================
# Help

# only comments after make target name are shown as help text
help: ## Displays this help message
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s : | sort)"


# ====================================================================================
# Kind

setup_local_cluster: create_kind_cluster 
	@skaffold run -p local-cluster-core

connect_registry_to_kind_network:
	docker network connect kind kind-registry || true;

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yaml;

create_docker_registry:
	if ! docker ps | grep -q 'kind-registry'; \
	then docker run -d -p 127.0.0.1:5001:5000 --name kind-registry --restart=always registry:2; \
	else echo "---> kind-registry is already running. There's nothing to do here."; \
	fi

create_kind_cluster: create_docker_registry
	@$(INFO) "--- Create cluster --name ${KIND_CLUSTER_NAME} "
	@kind create cluster --image=kindest/node:v${K8S_LATEST} --name ${KIND_CLUSTER_NAME} --config ./kind_config.yaml || true
	@kubectl get nodes
	@$(OK)  "--- Done ---"

create_kind_cluster_with_registry:  ## Create kind cluster with registry
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind && $(MAKE) install_ingress_controller && $(MAKE) install_metallb_native
	
install_ingress_controller:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml && \
	sleep 5 && \
	kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# https://kind.sigs.k8s.io/docs/user/loadbalancer/
install_metallb_native:
	@kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml && \
	sleep 5 && \
	kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s
	@kubectl apply -f ./metallb-config.yaml

delete_kind_cluster: ## Delete kind cluster
	@$(INFO) "--- delete cluster --name ${KIND_CLUSTER_NAME} "
	@kind delete cluster --name ${KIND_CLUSTER_NAME}
	@$(OK)  "--- Done ---"

# ====================================================================================
# skaffold

skaffold_run: ## Deploy application into cluster
	@$(INFO) "--- skaffold run using context ${KIND_CLUSTER_NAME} "
	@skaffold run -p local-cluster-core
	@$(OK)  "--- Done ---"

skaffold_delete:
	@$(INFO) "--- skaffold delete using context ${KIND_CLUSTER_NAME} "
	@skaffold delete -p local-cluster-core
	@$(OK)  "--- Done ---"