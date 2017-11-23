IMAGE_NAME=borgbackup
IMAGE_TAG=stable-v1.4
build:
	@echo 'building docker image'
	@docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	
push:
	@echo 'pushing docker image'
	@docker push $(IMAGE_NAME):$(IMAGE_TAG) 
