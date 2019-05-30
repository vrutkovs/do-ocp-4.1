PODMAN=podman
MOUNT_FLAGS=

TERRAFORM_IMAGE=hashicorp/terraform:0.12.0
PODMAN_TF=${PODMAN} run --privileged --rm \
	--user $(shell id -u):$(shell id -u) \
	--workdir=/tf \
	-v $(shell pwd)/terraform:/tf${MOUNT_FLAGS} \
	--env-file $(shell pwd)/secrets.env \
	-ti ${TERRAFORM_IMAGE}

INSTALLER_IMAGE=registry.svc.ci.openshift.org/origin/4.2:installer
PODMAN_INSTALLER=${PODMAN} run --privileged --rm \
	-v $(shell pwd)/installer:/output${MOUNT_FLAGS} \
	--user $(shell id -u):$(shell id -u) \
	-ti ${INSTALLER_IMAGE}

all: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check: ## Verify all necessary files exist
ifeq (,$(wildcard ./secrets.env))
	$(error "See secrets.env.example and create secrets.env")
endif
ifeq (,$(wildcard ./terraform/terraform.tfvars))
	$(error "See terraform/terraform.tfvars.example and create terraform/terraform.tfvars")
endif

terraform: check init plan apply

cleanup: ## Remove remaining installer bits
	rm -rf clusters/${CLUSTER} || true

ignition: check ## Generate ignition files
ifeq (,$(wildcard ./installer/install-config.yaml))
	$(error "See installer/install-config.yaml.example and create installer/install-config.yaml")
endif
	${PODMAN_INSTALLER} version
	${PODMAN_INSTALLER} create ignition-configs --dir /output

init: ## Initialize terraform
	${PODMAN_TF} init

plan: ## Plan terraform install
	${PODMAN_TF} apply -auto-approve

apply: ## Apply terraform install
	${PODMAN_TF} apply -auto-approve

destroy: ## Destroy created resources
	${PODMAN_TF} destroy -auto-approve
