ROOT = $(shell pwd)
BUILD = $(ROOT)/build
STAGE = $(ROOT)/stage
RUNTIME = /usr/local/etc/sliderule
SERVER_SOURCE_DIR = $(ROOT)/../sliderule
PLUGIN_SOURCE_DIR = $(ROOT)/../sliderule-icesat2
CLIENT_SOURCE_DIR = $(ROOT)/../sliderule-python
SERVER_BUILD_DIR = $(BUILD)/sliderule
PLUGIN_BUILD_DIR = $(BUILD)/plugin
SERVER_STAGE_DIR = $(STAGE)/sliderule
WEBSITE_STAGE_DIR = $(STAGE)/website
PYTHON_STAGE_DIR = $(STAGE)/python
MONITOR_STAGE_DIR = $(STAGE)/monitor
DEV_STAGE_DIR = $(STAGE)/dev

# for a MacOSX host to have this ip command you must install homebrew(see https://brew.sh/) then run 'brew install iproute2mac' on your mac host
MYIP ?= $(shell (ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$$/\1/p'))

SLIDERULE_DOCKER_TAG ?= icesat2sliderule/sliderule:latest
MONITOR_DOCKER_TAG ?= icesat2sliderule/monitor:latest
WEBSITE_DOCKER_TAG ?= icesat2sliderule/website:latest
PYTHON_DOCKER_TAG ?= icesat2sliderule/python:latest
DEV_DOCKER_TAG ?= icesat2sliderule/sliderule-dev:latest

CLANG_OPT = -DCMAKE_USER_MAKE_RULES_OVERRIDE=$(SERVER_SOURCE_DIR)/platforms/linux/ClangOverrides.txt -D_CMAKE_TOOLCHAIN_PREFIX=llvm-

SLIDERULECFG := -DMAX_FREE_STACK_SIZE=1
SLIDERULECFG += -DUSE_AWS_PACKAGE=ON
SLIDERULECFG += -DUSE_H5_PACKAGE=ON
SLIDERULECFG += -DUSE_NETSVC_PACKAGE=ON
SLIDERULECFG += -DUSE_GEOTIFF_PACKAGE=ON
SLIDERULECFG += -DUSE_LEGACY_PACKAGE=OFF
SLIDERULECFG += -DUSE_CCSDS_PACKAGE=OFF

all: sliderule

####################
# Dev Targets
####################

dev-docker: dev-distclean                   ## Build a development container
	mkdir -p $(DEV_STAGE_DIR)
	cp docker/dev/* $(DEV_STAGE_DIR)
	cd $(DEV_STAGE_DIR); docker build -f Dockerfile . -t $(DEV_DOCKER_TAG)

dev-docker-run: dev-docker                  ## Start a detached development container
	cd $(DEV_STAGE_DIR); docker run --hostname sliderule-dev-docker --name sliderule-dev -it --rm  -e IPV4=$(MYIP) -v ~/:/home/develop/host -v $(DEV_STAGE_DIR):/home/develop/SlideRule $(DEV_DOCKER_TAG)

dev-distclean:                              ## clean dev dist
	- rm -Rf $(DEV_STAGE_DIR)

####################
# SlideRule Targets
####################

sliderule:                                  ## build the server using the local configuration
	make -j4 -C $(SERVER_BUILD_DIR)
	make -C $(SERVER_BUILD_DIR) install
	make -j4 -C $(PLUGIN_BUILD_DIR)
	make -C $(PLUGIN_BUILD_DIR) install
	cp docker/sliderule/asset_directory.csv $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/empty.index $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/plugins.conf $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/earth_data_auth.lua $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/service_registry.lua $(SERVER_STAGE_DIR)/etc/sliderule

sliderule-config:                           ## configure the server for running locally
	mkdir -p $(SERVER_BUILD_DIR)
	mkdir -p $(PLUGIN_BUILD_DIR)
	cd $(SERVER_BUILD_DIR); cmake -DCMAKE_BUILD_TYPE=Debug $(SLIDERULECFG) -DINSTALLDIR=$(SERVER_STAGE_DIR) $(SERVER_SOURCE_DIR)
	cd $(PLUGIN_BUILD_DIR); cmake -DCMAKE_BUILD_TYPE=Debug -DINSTALLDIR=$(SERVER_STAGE_DIR) $(PLUGIN_SOURCE_DIR)

sliderule-config-valgrind:                  ## configre server with valgrind
	mkdir -p $(SERVER_BUILD_DIR)
	mkdir -p $(PLUGIN_BUILD_DIR)
	cd $(SERVER_BUILD_DIR); cmake -DCMAKE_BUILD_TYPE=Release $(SLIDERULECFG) -DINSTALLDIR=$(SERVER_STAGE_DIR) $(SERVER_SOURCE_DIR)
	cd $(PLUGIN_BUILD_DIR); cmake -DCMAKE_BUILD_TYPE=Release -DINSTALLDIR=$(SERVER_STAGE_DIR) $(PLUGIN_SOURCE_DIR)

sliderule-config-asan:
	mkdir -p $(SERVER_BUILD_DIR)
	mkdir -p $(PLUGIN_BUILD_DIR)
	cd $(SERVER_BUILD_DIR); export CC=clang; export CXX=clang++; cmake -DCMAKE_BUILD_TYPE=Debug $(CLANG_OPT) -DENABLE_ADDRESS_SANITIZER=ON $(SLIDERULECFG) -DINSTALLDIR=$(SERVER_STAGE_DIR) $(SERVER_SOURCE_DIR)
	cd $(PLUGIN_BUILD_DIR); export CC=clang; export CXX=clang++; cmake -DCMAKE_BUILD_TYPE=Debug $(CLANG_OPT) -DENABLE_ADDRESS_SANITIZER=ON -DINSTALLDIR=$(SERVER_STAGE_DIR) $(PLUGIN_SOURCE_DIR)

sliderule-docker: sliderule-distclean       ## build the server docker container
	# build and install sliderule into staging
	mkdir -p $(SERVER_BUILD_DIR)
	cd $(SERVER_BUILD_DIR); cmake -DCMAKE_BUILD_TYPE=Release $(SLIDERULECFG) -DINSTALLDIR=$(SERVER_STAGE_DIR) -DRUNTIMEDIR=$(RUNTIME) $(SERVER_SOURCE_DIR)
	make -j4 $(SERVER_BUILD_DIR)
	make -C $(SERVER_BUILD_DIR) install
	# build and install plugin into staging
	mkdir -p $(PLUGIN_BUILD_DIR)
	cd $(PLUGIN_BUILD_DIR); cmake -DCMAKE_BUILD_TYPE=Release -DINSTALLDIR=$(SERVER_STAGE_DIR) $(PLUGIN_SOURCE_DIR)
	make -j4 $(PLUGIN_BUILD_DIR)
	make -C $(PLUGIN_BUILD_DIR) install
	# copy over dockerfile
	cp docker/sliderule/Dockerfile $(SERVER_STAGE_DIR)
	# copy over sliderule configuration
	cp docker/sliderule/plugins.conf $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/config-production.json $(SERVER_STAGE_DIR)/etc/sliderule/config.json
	cp docker/sliderule/asset_directory.csv $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/empty.index $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/server.lua $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/earth_data_auth.lua $(SERVER_STAGE_DIR)/etc/sliderule
	cp docker/sliderule/service_registry.lua $(SERVER_STAGE_DIR)/etc/sliderule
	# copy over entry point
	mkdir -p $(SERVER_STAGE_DIR)/scripts
	cp docker/sliderule/docker-entrypoint.sh $(SERVER_STAGE_DIR)/scripts
	chmod +x $(SERVER_STAGE_DIR)/scripts/docker-entrypoint.sh
	# build image
	cd $(SERVER_STAGE_DIR); docker build -t $(SLIDERULE_DOCKER_TAG) .

sliderule-run:                              ## run the server locally
	IPV4=$(MYIP) $(SERVER_STAGE_DIR)/bin/sliderule docker/sliderule/server.lua docker/sliderule/config-development.json

sliderule-run-valgrind:                     ## run the server in valgrind
	IPV4=$(MYIP) valgrind --leak-check=full --track-origins=yes --track-fds=yes $(SERVER_STAGE_DIR)/bin/sliderule docker/sliderule/server.lua docker/sliderule/config-development.json

sliderule-docker-run:                       ## run the server in a docker container
	docker run -it --rm --name=sliderule-app -e IPV4=$(MYIP) -v /etc/ssl/certs:/etc/ssl/certs -v /data:/data -p 9081:9081 --entrypoint /usr/local/scripts/docker-entrypoint.sh $(SLIDERULE_DOCKER_TAG)

sliderule-test:                             ## run test
	$(SERVER_STAGE_DIR)/bin/sliderule apps/test_runner.lua

sliderule-clean:                            ## clean server
	make -C build clean
	- rm aws_sdk_*.log

sliderule-distclean:                        ## clean server dist
	- rm -Rf $(SERVER_BUILD_DIR)
	- rm -Rf $(PLUGIN_BUILD_DIR)
	- rm -Rf $(SERVER_STAGE_DIR)
	- rm -Rf $(BUILD)

####################
# Monitor Targets
####################

monitor-docker: monitor-distclean
	mkdir -p $(MONITOR_STAGE_DIR)
	cp docker/monitor/* $(MONITOR_STAGE_DIR)
	chmod +x $(MONITOR_STAGE_DIR)/docker-entrypoint.sh
	cd $(MONITOR_STAGE_DIR); docker build -t $(MONITOR_DOCKER_TAG) .

monitor-docker-run:
	docker run -it --rm --name=monitor -p 3000:3000 -p 3100:3100 -p 9090:9090 -p 8050:8050 -p 8051:8051 -p 8052:8052 --entrypoint /usr/local/etc/docker-entrypoint.sh $(MONITOR_DOCKER_TAG)

monitor-distclean:
	- rm -Rf $(MONITOR_STAGE_DIR)

####################
# Website Targets
####################

website: website-jekyll website-rtd website-install ## make the website

website-jekyll:                             ## bundle
	cd jekyll; bundle exec jekyll build

website-rtd:                                ## change directory to /rtd/html
	make -C rtd html

website-install:                            ## install the website
	mkdir -p $(WEBSITE_STAGE_DIR)
	cp -R jekyll/_site/* $(WEBSITE_STAGE_DIR)
	cp -R rtd/build/html $(WEBSITE_STAGE_DIR)/rtd

website-docker: website-distclean website   ## build the website docker container
	cp docker/website/Dockerfile $(WEBSITE_STAGE_DIR)
	cd $(WEBSITE_STAGE_DIR); docker build -t $(WEBSITE_DOCKER_TAG) .

website-run:                                ## run the website locally
	cd jekyll; bundle exec jekyll serve -d $(WEBSITE_STAGE_DIR) --skip-initial-build

website-docker-run:                         ## run the website docker container
	docker run -it --rm --name=website -p 80:4000 $(WEBSITE_DOCKER_TAG) jekyll serve --skip-initial-build

website-distclean:                          ## clean website dist
	- rm -Rf $(WEBSITE_STAGE_DIR)
	- rm -Rf jekyll/_site
	- rm -Rf jekyll/.jekyll-cache
	- rm -Rf rtd/build

####################
# Python Targets
####################

python: python-docker

python-docker: python-distclean             ## build python docker container
	mkdir -p $(PYTHON_STAGE_DIR)
	cp docker/python/* $(PYTHON_STAGE_DIR)
	chmod +x $(PYTHON_STAGE_DIR)/docker-entrypoint.sh
	cd $(PYTHON_STAGE_DIR); docker build -t $(PYTHON_DOCKER_TAG) .

python-docker-run:                          ## run the python docker container
	docker run -it --rm --name=python-app -p 8866:8866 -v /data:/data --entrypoint /usr/local/etc/docker-entrypoint.sh $(PYTHON_DOCKER_TAG)
#	docker run -it --rm --name=python-app -p 8866:8866 -p 8888:8888 -v /data:/data $(PYTHON_DOCKER_TAG)

python-distclean:
	- rm -Rf $(PYTHON_STAGE_DIR)

####################
# Release Targets
####################

# Example usage: make VERSION=1.4.2 release

VERSION=

release-tag: ## tag the release
	# tag sliderule-project
	./RELEASE.sh $(VERSION)
	git push --tags; git push
	# tag sliderule
	cd $(SERVER_SOURCE_DIR); ./RELEASE.sh $(VERSION)
	cd $(SERVER_SOURCE_DIR); git push --tags; git push
	# tag sliderule-icesat2
	cd $(PLUGIN_SOURCE_DIR); ./RELEASE.sh $(VERSION)
	cd $(PLUGIN_SOURCE_DIR); git push --tags; git push
	# tag sliderule-python
	cd $(CLIENT_SOURCE_DIR); ./RELEASE.sh $(VERSION)
	cd $(CLIENT_SOURCE_DIR); git push --tags; git push

release-docker: sliderule-docker monitor-docker website-docker python-docker ## build docker containers for release
	# docker sliderule
	docker tag $(SLIDERULE_DOCKER_TAG) icesat2sliderule/sliderule:v$(VERSION)
	docker push icesat2sliderule/sliderule:v$(VERSION)
	# docker monitor
	docker tag $(MONITOR_DOCKER_TAG) icesat2sliderule/monitor:v$(VERSION)
	docker push icesat2sliderule/monitor:v$(VERSION)
	# docker website
	docker tag $(WEBSITE_DOCKER_TAG) icesat2sliderule/website:v$(VERSION)
	docker push icesat2sliderule/website:v$(VERSION)
	# docker python
	docker tag $(PYTHON_DOCKER_TAG) icesat2sliderule/python:v$(VERSION)
	docker push icesat2sliderule/python:v$(VERSION)

release-github: ## create GitHub releases (requires active conda environment with gh installed)
	gh release create v$(VERSION) -t v$(VERSION) --notes "see http://icesat2sliderule.org/release_notes/"
	cd $(SERVER_SOURCE_DIR); gh release create v$(VERSION) -t v$(VERSION) --notes "see http://icesat2sliderule.org/release_notes/"
	cd $(PLUGIN_SOURCE_DIR); gh release create v$(VERSION) -t v$(VERSION) --notes "see http://icesat2sliderule.org/release_notes/"
	cd $(CLIENT_SOURCE_DIR); gh release create v$(VERSION) -t v$(VERSION) --notes "see http://icesat2sliderule.org/release_notes/"

release-packer: ## build Amazon Machine Image (AMI) for release
	cd packer; packer build -var version=v$(VERSION) sliderule-base.pkr.hcl

release-terraform: ## deploy cluster
	cd terraform; terraform workspace new v$(VERSION)
	cd terraform; terraform apply -var cluster_name=v$(VERSION) -var sliderule_image=icesat2sliderule/sliderule:v$(VERSION) -var website_image=icesat2sliderule/website:v$(VERSION) -var python_image=icesat2sliderule/python:v$(VERSION) -var monitor_image=icesat2sliderule/monitor:v$(VERSION) -var ami_name=sliderule-node-v$(VERSION)
	# Steps remaining:
	#  - verifying functionality
	#  - update route 53 record
	#  - destroy previous deployment

release: release-tag release-docker release-github release-packer release-terraform ## release software

release-prep: ## create conda environment for running GitHub cli (only needs to be run once)
	conda create -n github
	conda install -n github gh --channel conda-forge

####################
# Global Targets
####################

clean: sliderule-clean website-clean

distclean: sliderule-distclean monitor-distclean website-distclean python-distclean ## clean dist
	- rm -Rf $(BUILD)
	- rm -Rf $(STAGE)

help: ## That's me!
	@printf "\033[37m%-30s\033[0m %s\n" "#-----------------------------------------------------------------------------------------"
	@printf "\033[37m%-30s\033[0m %s\n" "# Makefile Help                                                                          |"
	@printf "\033[37m%-30s\033[0m %s\n" "#-----------------------------------------------------------------------------------------"
	@printf "\033[37m%-30s\033[0m %s\n" "#-target-----------------------description------------------------------------------------"
	@grep -E '^[a-zA-Z_-].+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

