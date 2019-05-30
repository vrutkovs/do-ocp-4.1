PODMAN=podman
MOUNT_FLAGS=
TERRAFORM_IMAGE=hashicorp/terraform:0.12.0
PODMAN_TF=${PODMAN} run --privileged --rm \
	--user $(shell id -u):$(shell id -u) \
	--workdir=/tf \
	-v $(shell pwd)/terraform:/tf${MOUNT_FLAGS} \
	--env-file $(shell pwd)/secrets.env \
	-ti ${TERRAFORM_IMAGE}

all: init plan apply

init:
	${PODMAN_TF} init

plan:
	${PODMAN_TF} apply -auto-approve

apply:
	${PODMAN_TF} apply -auto-approve

destroy:
	${PODMAN_TF} destroy -auto-approve
