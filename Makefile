.PHONY: help set-url update release delete-release docker docker-pull u r d s setup lint l

.DEFAULT_GOAL := help

u: update
r: release
d: docker
s: set-url
l: lint

# Show this help message
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

set-url: ## Switch remote URL to SSH for committing
	git remote set-url origin git@github.com:th2ch-g/dotfiles.git

update: ## Pull latest changes
	git pull

release: ## Create and push a dated release tag
	$(eval TAG := v$(shell date +'%Y.%m.%d'))
	git tag -a $(TAG) -m "Release $(TAG)"
	git push origin $(TAG)

docker: ## Build and run Docker image locally
	docker image build -t myenv .
	docker run --rm -it myenv

docker-pull: ## Pull and run the latest Docker image from ghcr.io
	docker pull --platform linux/amd64 ghcr.io/th2ch-g/dotfiles:latest
	docker run --platform linux/amd64 --rm -it ghcr.io/th2ch-g/dotfiles

delete-release: ## Delete a release tag locally and remotely (usage: make delete-release TAG=vYYYY.MM.DD)
	@test -n "$(TAG)" || (echo "Error: TAG is required. Usage: make delete-release TAG=vYYYY.MM.DD" && exit 1)
	git tag -d $(TAG)
	git push origin --delete $(TAG)

setup: ## Install pre-commit hooks into this repository
	pre-commit install

lint: ## Run all pre-commit hooks on every file
	pre-commit run --all-files
