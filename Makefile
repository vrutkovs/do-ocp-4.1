PODMAN=podman
MOUNT_FLAGS=

TERRAFORM_IMAGE=hashicorp/terraform:0.11.14
PODMAN_TF=${PODMAN} run --privileged --rm \
	--user $(shell id -u):$(shell id -u) \
	--workdir=/tf \
	-v $(shell pwd)/terraform:/tf${MOUNT_FLAGS} \
	-v $(shell pwd)/installer:/installer${MOUNT_FLAGS} \
	--env-file $(shell pwd)/secrets.env \
	-ti ${TERRAFORM_IMAGE}

INSTALLER_IMAGE=quay.io/openshift/origin-installer:4.3
INSTALLER_LOG_LEVEL=info
#INSTALLER_IMAGE=quay.io/origin/4.1:installer
RELEASE_IMAGE=registry.svc.ci.openshift.org/ci-op-9c7973f7/release:latest
ifneq ("$(RELEASE_IMAGE)","")
	INSTALLER_PARAMS=-e OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=${RELEASE_IMAGE}
endif

PODMAN_INSTALLER=${PODMAN} run --privileged --rm \
	-v $(shell pwd)/installer:/output${MOUNT_FLAGS} \
	--user $(shell id -u):$(shell id -u) \
	${INSTALLER_PARAMS} \
	-ti ${INSTALLER_IMAGE}

ifeq ("$(FCOS_VERSION)","")
	# curl -sSL https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/builds.json | jq -r '.builds[0].id'
	FCOS_VERSION=31.20191217.2.0
endif

all: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

prepare-fcos: ## Generate DO-compatible image
	yum install -y libguestfs-xfs libguestfs-tools-c
	curl -kLvs \
		 https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-openstack.x86_64.qcow2.xz | xz -d --stdout > /var/lib/libvirt/images/fcos-openstack.qcow2
	./cosa/gf-platformid \
	   /var/lib/libvirt/images/fcos-openstack.qcow2 \
	   /var/lib/libvirt/images/fcos-do.qcow2

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
	sudo rm -rf installer/metadata.json || true

ignition: check installer-cleanup ## Generate ignition files
ifeq (,$(wildcard ./install-config.yaml))
	$(error "See installer/install-config.yaml.example and create installer/install-config.yaml")
endif
	${PODMAN} pull ${INSTALLER_IMAGE}
	${PODMAN_INSTALLER} version
	cp install-config.yaml installer/
	${PODMAN_INSTALLER} create ignition-configs --dir /output --log-level ${INSTALLER_LOG_LEVEL}
	echo "Please upload installer/bootstrap.ign and run 'make terraform'"

terraform: check ## Initialize terraform
	${PODMAN_TF} init
	${PODMAN_TF} apply -auto-approve
	${PODMAN_INSTALLER} wait-for bootstrap-complete --dir /output
	${PODMAN_TF} apply -auto-approve -var 'bootstrap_complete=true'
	${PODMAN_INSTALLER} wait-for install-complete --dir /output

destroy: check ##Destroy resources via Terraform
	${PODMAN_TF} destroy -auto-approve
