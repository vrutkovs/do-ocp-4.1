Preparing RHCOS image
====
* Open "https://releases-rhcos.svc.ci.openshift.org/storage/releases/ootpa/builds.json"
* Find the latest RHCOS version listed there, save it to "VERSION" env var

* Run `make prepare-rhcos`
* Upload `/var/lib/libvirt/images/rhcos-do.qcow2` to DO

If you don't feel adventurous upload https://rhcos.fra1.digitaloceanspaces.com/rhcos-do.qcow2

Installing OpenShift v4
====
* `cp installer/install-config.yaml{.example,}`
* Edit `installer/install-config.yaml`
* Run `make ignition`
* `cp terraform/terraform.tfvars{.example,}`
* Upload `installer/bootstrap.ign` to DO Spaces or some http pastebin (`cat installer/bootstrap.ign | curl -F 'sprunge=<-' http://sprunge.us`)
* Update `terraform/terraform.tfvars`
* `cp secrets.env{.example,}`, fill in DO token in `secrets.env`
* Run `make terraform`. Run `make destroy` to remove droplets and machines
