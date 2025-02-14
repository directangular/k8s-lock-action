release:
	@echo "Tagging current origin/master as v2"
	git push origin :refs/tags/v2
	git tag --force v2 origin/master
	git push --tags --force origin
	git fetch --tags origin

image: Dockerfile.base
	docker build . -f Dockerfile.base -t directangular/k8s-lock-action

push: image
	docker push directangular/k8s-lock-action
