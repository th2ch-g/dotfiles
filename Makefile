.PHONY: set-url update release delete-release docker docker-pull u r d s

u: update
r: release
d: docker
s: set-url

# Switch remote URL to SSH for committing
set-url:
	git remote set-url origin git@github.com:th2ch-g/dotfiles.git

# Pull latest changes
update:
	git pull

# Create and push a dated release tag
release:
	$(eval TAG := v$(shell date +'%Y.%m.%d'))
	git tag -a $(TAG) -m "Release $(TAG)"
	git push origin $(TAG)

# Build and run Docker image locally
docker:
	docker image build -t myenv .
	docker run --rm -it myenv

# Pull and run the latest Docker image from ghcr.io
docker-pull:
	docker pull --platform linux/amd64 ghcr.io/th2ch-g/dotfiles:latest
	docker run --platform linux/amd64 --rm -it ghcr.io/th2ch-g/dotfiles

# Delete a release tag locally and remotely (usage: make delete-release TAG=vYYYY.MM.DD)
delete-release:
	@test -n "$(TAG)" || (echo "Error: TAG is required. Usage: make delete-release TAG=vYYYY.MM.DD" && exit 1)
	git tag -d $(TAG)
	git push origin --delete $(TAG)
