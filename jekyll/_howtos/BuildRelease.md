---
layout: single
title: "Building and Releasing SlideRule"
date: 2022-01-20 10:45:14 -0500
excerpt: "How to deploy a released version of sliderule to AWS"
toc: true
toc_sticky: true
category: developer
---

The ICESat-2 SlideRule project consists of the following git repositories:
* `sliderule` - server _(open source, public)_
* `sliderule-icesat2` - server plugin for icesat2 _(open source, public)_
* `sliderule-python` - python client _(open source, public)_
* `sliderule-cluster` - infrastructure, docker files, resources _(private)_
* `sliderule-docs` - website _(open source, public)_

Releasing and deploying SlideRule consists of the following steps:
1. [Pre-release testing](#i-pre-release-testing)
2. [Release notes](#ii-release-notes)
3. [Tag release](#iii-tag-release)
4. [Build Docker images](#iv-build-docker-images)
5. [Build AMI](#v-build-ami)
6. [Deploy cluster](#vi-deploy-cluster)
7. [Post-release checkout](#vii-post-release-checkout)
8. [Final steps](#viii-final-steps)

### I. Pre-Release Testing

1. SlideRule Self-Test
```bash
$ cd {root}/sliderule
$ make distclean
$ make development-config
$ make
$ sudo make install
$ sliderule scripts/tests/test_runner.lua
```

2. ICESat-2 Plugin Self-Test
```bash
$ cd {root}/sliderule-icesat2
$ make distclean
$ make config
$ make
$ sudo make install
$ sliderule tests/test_runner.lua
```

3. Python pytests locally (requires ATL03/06/08 files at /data)
```bash
$ cd {root}/sliderule-cluster
$ make monitor-docker
$ make monitor-docker-run # leave running
$ make sliderule-docker
$ make sliderule-docker-run # leave running
$ cd {root}/sliderule-python
$ conda activate sliderule # created from  {root}/sliderule-python/environment.yml
$ pytest --server="127.0.0.1" --asset="atlas-local"
```

4. Python system tests locally (requires ATL03/06/08 files at /data)
```bash
$ cd {root}/sliderule-cluster
$ make sliderule-docker
$ make sliderule-docker-run # leave running
$ conda activate sliderule # created from  {root}/sliderule-python/environment.yml
$ python tests/algorithm.py
$ python tests/atl06gs.py
$ python tests/atl08class.py
```

5. Deploy test cluster and run example workflows
```bash
$ cd {root}/sliderule-cluster
$ make sliderule-docker
$ docker push icesat2sliderule/sliderule:latest
#
# Log into AWS console and start a cloud shell
#
# create sliderule-node-latest AMI
# if it exists then delete ("deregister") AMI first via console
$ cd {root}/sliderule-cluster/packer
$ packer build sliderule-base.pkr.hcl
# wait until process completes and AMI image created
$ cd {root}/sliderule-cluster/terraform
$ terraform apply -var cluster_name=test
# type 'yes' at prompt after verifying that resources are prefixed with 'test'
# wait until process completes and nodes finish initializing
#
# Run Region of Interest on your local machine
#
$ cd {root}/sliderule-python
$ conda activate sliderule # created from  {root}/sliderule-python/environment.yml
$ python utils/region_of_interest.py examples/grandmesa.geojson {test-node-manager ip address}
#
# Start jupyter notebook and run through examples
#
#  - api_widgets_demo
#  - boulder_watershed_demo
#  - grand_mesa_demo
#  - single_track_demo
#
#
# Log into AWS console and start cloud shell
#
# delete test cluster
$ cd {root}/sliderule-cluster/terraform
$ terraform workspace select test
$ terraform destroy
# type 'yes' at prompt after verifying that resources are prefixed with 'test'
# wait until process completes and all resources are destroyed
```

6. Run memory tests
```bash
#
# Run with Valigrind
#
$ cd {root}/sliderule-cluster
$ make distclean
$ make sliderule-config-valgrind
$ make sliderule
$ make sliderule-run-valgrind # leave running
$ cd {root}/sliderule-python
$ conda activate sliderule # created from  {root}/sliderule-python/environment.yml
$ python utils/region_of_interest.py examples/grandmesa.geojson
# there will be lots of timeouts; this is okay and tests error paths
# likely will have to stop the test early because it is taking too long (hours...)
#
# Run with Address Sanitizer
#
$ cd {root}/sliderule-cluster
$ make distclean
$ make sliderule-config-asan
$ make sliderule
$ make sliderule-run # leave running
$ cd {root}/sliderule-python
$ conda activate sliderule # created from  {root}/sliderule-python/environment.yml
$ python utils/region_of_interest.py examples/grandmesa.geojson
```

7. Run H5Coro performance test
```bash
$ cd {root}/sliderule
$ make distclean
$ make python-config
$ make
$ cd build
$ cp {root}/sliderule-icesat2/tests/perftest.py .
$ conda activate sliderule # created from  {root}/sliderule-python/environment.yml
$ python perftest.py
```

8. Run static code analysis (scan-build)
```bash
$ cd {root}/sliderule
$ make distclean
$ make scan
```

### II. Release Notes

Create a release note for the build in the `sliderule-docs` repository, under ***jekyll/release_notes/***, named ***release-v{x-y-z}.md***.


### III. Tag Release

1. Tag the release in the git repositories
```bash
$ cd {root}/sliderule-cluster
$ make VERSION=x.y.z release-tag
```

2. Publish the release on GitHub
```bash
# assumes that the github python environment exists, see release-prep target for details
$ cd {root}/sliderule-cluster
$ make VERSION=x.y.z release-github
```


### IV. Build Docker Images

```bash
$ cd {root}/sliderule-cluster
$ make VERSION=x.y.z release-docker
```


### V. Build AMI

```bash
#
# Log into AWS console and start a cloud shell
#
$ cd {root}/sliderule-cluster
$ make VERSION=x.y.z release-packer
```


### VI. Deploy Cluster

```bash
#
# Log into AWS console and start a cloud shell
#
$ cd {root}/sliderule-cluster
$ make VERSION=x.y.z release-terraform
```


### VII. Post-Release Checkout

1. Run example workflows in python
```bash
$ cd {root}/sliderule-python
$ conda activate sliderule # created from  {root}/sliderule-python/environment.yml
$ python utils/query_version.py {vX.Y.Z-node-manager ip address}
$ python utils/query_services.py {vX.Y.Z-node-manager ip address}
$ python utils/region_of_interest.py examples/grandmesa.geojson {vX.Y.Z-node-manager ip address}
```

2. Run pytest
```bash
$ cd {root}/sliderule-python
$ conda activate sliderule # created from  {root}/sliderule-python/environment.yml
$ pytest --server="{vX.Y.Z-node-manager ip address}"
```

3. Check monitoring system at `http://{vX.Y.Z-node-manager ip address}:3000/`
* View system metrics
* View logs
* View application metrics

4. Check static website at `http://{vX.Y.Z-node-manager ip address}/`

### VIII. Final Steps

1. Route traffic from `icesat2sliderule.org` to the public IP address of the {vX.Y.Z-node-manager}
* Go to "Route 53" in the AWS web console
* Click on the "Hosted Zone" link under "DNS Management"
* Click the icesat2sliderule.org domain link
* Select the simple routing rule (type A) record
* Click the button to "Edit record"
* Change the Value of the IP address to the new IP address
* Save changes

2. Tear down previous deployment
```bash
#
# Log into AWS console and start a cloud shell
#
$ cd {root}/sliderule-cluster/terraform
$ terraform workspace select {previous release workspace}
$ terraform destroy
```

3. Check CodeQL analysis (Actions --> CodeQL) on GitHub

4. Check Conda-Forge deployment of Python client
