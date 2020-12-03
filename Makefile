release:
	@echo "Tagging current origin/master as v1"
	git push origin :refs/tags/v1
	git tag --force v1 origin/master
	git push --tags --force origin
	git fetch --tags origin

image: Dockerfile.base
	docker build . -f Dockerfile.base -t directangular/k8s-lock-action

push: image
	docker push directangular/k8s-lock-action
