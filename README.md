Preparing FCOS image
====
* Open "https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/builds.json"
* Find the latest FCOS version listed there, save it to "FCOS_VERSION" env var

* Run `make prepare-fcos`
* Upload `/var/lib/libvirt/images/fcos-do.qcow2` to DO

Installing OKD v4
====
* `cp install-config.yaml{.example,}`
* Edit `install-config.yaml` and use `{"auths":{"fake":{"auth": "bar"}}}` as a pull secret
* Run `make ignition`
* `cp terraform/terraform.tfvars{.example,}`
* Upload `installer/bootstrap.ign` to DO Spaces or some http pastebin (`cat installer/bootstrap.ign | curl -F 'sprunge=<-' http://sprunge.us`)
* Update `terraform/terraform.tfvars`
* `cp secrets.env{.example,}`, fill in DO token in `secrets.env`
* Run `make terraform`. Run `make destroy` to remove droplets and machines
