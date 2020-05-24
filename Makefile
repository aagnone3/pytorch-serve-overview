include ./env

.DEFAULT_GOAL := help
TAG ?= latest
DOCKER ?= docker
DOCKERFILE ?= Dockerfile
DOCKER_REPO ?= pytorch-serve-intro
DOCKER_TAG ?= latest
DOCKER_REPO_URI = ${DOCKER_USERNAME}/${DOCKER_REPO}:${DOCKER_TAG}

.PHONY: help
help: ## Print this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed -E 's/^([a-zA-Z_-]+):.*## (.*)$$/\1: \2/' | awk -F ':' '{ printf "%-10s %s\n", $$1, $$2 }'


.PHONY: download
download:  ## Download data and model checkpoint(s)
	etc/download.sh

.PHONY: login
login: ## Login to Docker
	$(DOCKER) login

.PHONY: build
build: ## Build the Docker image
	./build-image.sh
	
.PHONY: image
image: build ## Build the Docker image (alias for `build` target)

.PHONY: tag
tag: login  ## Tag the Docker image
	$(DOCKER) tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REPO_URI)

.PHONY: push
push: tag  ## Push the Docker image to the Docker repository
	$(DOCKER) push $(DOCKER_REPO_URI)

.PHONY: shell
shell: ## Run the Docker image
	$(DOCKER) run \
		--mount type=bind,source="$(shell pwd)",target=/opt \
		-ti \
		--rm \
		$(DOCKER_REPO) \
			bash

.PHONY: serve
serve: ## Run the Docker image
	$(DOCKER) run \
		--mount type=bind,source="$(shell pwd)",target=/opt \
		-p $(SERVER_PORT):8080 \
		-ti \
		--rm \
		$(DOCKER_REPO) \
			torchserve --start --ncs --model-store model-store --models densenet161.mar

.PHONY: jup
jup: ## Run a Jupyter notebook inside the Docker container
	$(DOCKER) run \
		--mount type=bind,source="$(shell pwd)",target=/opt \
		-p $(JUPYTER_PORT):$(JUPYTER_PORT) \
		-ti \
		--rm \
		$(DOCKER_REPO)
		jupyter-lab --allow-root --ip=0.0.0.0 --port=$(JUPYTER_PORT) --no-browser 2>&1 | tee jupyter-log.txt
