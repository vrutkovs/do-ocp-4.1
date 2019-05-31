Preparing RHCOS image
====
* Open "https://releases-rhcos.svc.ci.openshift.org/storage/releases/ootpa/builds.json"
* Find the latest RHCOS version listed there, save it to "VERSION" env var

* Make sure you don't use RHEL7 - it can't mount RHEL8 xfs partition
* `yum install -y libguestfs-xfs libguestfs-tools-c`
* `curl -kLvs --compressed -o /var/lib/libvirt/images/rhcos-openstack.qcow2 https://d26v6vn1y7q7fv.cloudfront.net/releases/ootpa/${VERSION}/rhcos-${VERSION}-openstack.qcow2`

* `git clone https://github.com/coreos/coreos-assembler && ./coreos-assembler/src/gf-platformid /var/lib/libvirt/images/rhcos-openstack.qcow2 /var/lib/libvirt/images/rhcos-do.qcow2 digitalocean`

* Upload `/var/lib/libvirt/images/rhcos-do.qcow2` to DO

Installing OpenShift v4
====
* `cp installer/install-config.yaml{.example,}`
* Edit `installer/install-config.yaml`
* Run `make ignition`
* `cp terraform/terraform.tfvars{.example,}`
* Upload `installer/bootstrap.ign` to some http pastebin (`cat installer/bootstrap.ign | curl -F 'sprunge=<-' http://sprunge.us`)
* Update `terraform/terraform.tfvars`
* `cp secrets.env{.example,}`, fill in DO token in `secrets.env`
* Run `make terraform`. Run `make destroy` to remove droplets and machines
