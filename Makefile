ROOT = $(shell pwd)
STAGE = $(ROOT)/stage
WEBSITE_STAGE_DIR ?= $(STAGE)/website
WEBSITE_DOCKER_TAG ?= icesat2sliderule/website:latest

all: website

website: build-jekyll build-rtd install ## make the website

build-jekyll: ## bundle
	cd jekyll; bundle exec jekyll build

build-rtd: ## change directory to /rtd/html
	make -C rtd html

install: ## install the website
	mkdir -p $(WEBSITE_STAGE_DIR)
	cp -R jekyll/_site/* $(WEBSITE_STAGE_DIR)
	cp -R rtd/build/html $(WEBSITE_STAGE_DIR)/rtd

run: ## run the website locally
	cd jekyll; bundle exec jekyll serve -d $(WEBSITE_STAGE_DIR) --skip-initial-build

prep: ## install ruby environment
	cd jekyll; bundle install

distclean: ## delete all build artifacts
	- rm -Rf $(WEBSITE_STAGE_DIR)
	- rm -Rf jekyll/_site
	- rm -Rf jekyll/.jekyll-cache
	- rm -Rf rtd/build

website-docker: distclean website ## build the website docker container
	cp docker/Dockerfile $(WEBSITE_STAGE_DIR)
	cd $(WEBSITE_STAGE_DIR); docker build -t $(WEBSITE_DOCKER_TAG) .

website-docker-run: ## run the website docker container
	docker run -it --rm --name=website -p 4000:4000 $(WEBSITE_DOCKER_TAG) jekyll serve --skip-initial-build

help: ## That's me!
	@printf "\033[37m%-30s\033[0m %s\n" "#-----------------------------------------------------------------------------------------"
	@printf "\033[37m%-30s\033[0m %s\n" "# Makefile Help                                                                          |"
	@printf "\033[37m%-30s\033[0m %s\n" "#-----------------------------------------------------------------------------------------"
	@printf "\033[37m%-30s\033[0m %s\n" "#-target-----------------------description------------------------------------------------"
	@grep -E '^[a-zA-Z_-].+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

