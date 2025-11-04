image: Dockerfile.base
	docker build . -f Dockerfile.base -t directangular/k8s-lock-action

push: image
	docker push directangular/k8s-lock-action
