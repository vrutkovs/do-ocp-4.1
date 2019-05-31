Preparing RHCOS image
====
* Open "https://releases-rhcos.svc.ci.openshift.org/storage/releases/ootpa/builds.json"
* Find the latest RHCOS version listed there, save it to "VERSION" env var

* `curl -kLvs --compressed -o /var/lib/libvirt/images/rhcos-openstack.qcow2 https://d26v6vn1y7q7fv.cloudfront.net/releases/ootpa/${VERSION}/rhcos-${VERSION}-openstack.qcow2`

* `git clone https://github.com/coreos/coreos-assembler && ./coreos-assembler/src/gf-platformid /var/lib/libvirt/images/rhcos-openstack.qcow2 /var/lib/libvirt/images/rhcos-do.qcow2 digitalocean`

* Upload `rhcos-do.qcow2` to DO
