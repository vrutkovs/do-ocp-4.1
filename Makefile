PODMAN=podman
MOUNT_FLAGS=

TERRAFORM_IMAGE=hashicorp/terraform:0.11.14
PODMAN_TF=${PODMAN} run --privileged --rm \
	--user $(shell id -u):$(shell id -u) \
	--workdir=/tf \
	-v $(shell pwd)/terraform:/tf${MOUNT_FLAGS} \
	--env-file $(shell pwd)/secrets.env \
	-ti ${TERRAFORM_IMAGE}

INSTALLER_IMAGE=quay.io/openshift/origin-installer:4.1
INSTALLER_LOG_LEVEL=info
#INSTALLER_IMAGE=quay.io/origin/4.1:installer
#RELEASE_IMAGE=quay.io/origin/release:4.1
ifneq ("$(RELEASE_IMAGE)","")
	INSTALLER_PARAMS=-e OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=${RELEASE_IMAGE}
endif

PODMAN_INSTALLER=${PODMAN} run --privileged --rm \
	-v $(shell pwd)/installer:/output${MOUNT_FLAGS} \
	--user $(shell id -u):$(shell id -u) \
	${INSTALLER_PARAMS} \
	-ti ${INSTALLER_IMAGE}

RHCOS_VERSION=420.8.20190530.0

all: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

prepare-rhcos: ## Generate DO-compatible image
	yum install -y libguestfs-xfs libguestfs-tools-c
	curl -kLvs --compressed \
	   -o /var/lib/libvirt/images/rhcos-openstack.qcow2 \
	   "https://d26v6vn1y7q7fv.cloudfront.net/releases/ootpa/${RHCOS_VERSION}/rhcos-${RHCOS_VERSION}-openstack.qcow2"
	./cosa/gf-platformid \
	   /var/lib/libvirt/images/rhcos-openstack.qcow2 \
	   /var/lib/libvirt/images/rhcos-do.qcow2

check: ## Verify all necessary files exist
ifeq (,$(wildcard ./secrets.env))
	$(error "See secrets.env.example and create secrets.env")
endif
ifeq (,$(wildcard ./terraform/terraform.tfvars))
	$(error "See terraform/terraform.tfvars.example and create terraform/terraform.tfvars")
endif

installer-cleanup: ## Remove remaining installer bits
	sudo rm -rf installer/*.ign || true
	sudo rm -rf installer/auth || true
	sudo rm -rf installer/.openshift* || true
	sudo rm -rf installer/metadata || true

ignition: check installer-cleanup ## Generate ignition files
ifeq (,$(wildcard ./installer/install-config.yaml))
	$(error "See installer/install-config.yaml.example and create installer/install-config.yaml")
endif
	${PODMAN} pull ${INSTALLER_IMAGE}
	${PODMAN_INSTALLER} version
	cp installer/install-config.yaml{,.backup}
	${PODMAN_INSTALLER} create ignition-configs --dir /output --log-level ${INSTALLER_LOG_LEVEL}

terraform: check ## Initialize terraform
	${PODMAN_TF} init
	${PODMAN_TF} apply -auto-approve
	${PODMAN_INSTALLER} wait-for bootstrap-complete --dir /output
	${PODMAN_TF} apply -auto-approve -var 'bootstrap_complete=true'
	${PODMAN_INSTALLER} wait-for install-complete --dir /output

destroy: check ##Destroy resources via Terraform
	${PODMAN_TF} destroy -auto-approve
