ECR_URI := $(shell aws ecr describe-repositories --repository-names stack-simple --query\
 'repositories[0].repositoryUri' --output text)
TAG ?= latest

dc-up:
	docker-compose up --watch

dc-up-build:
	docker-compose up --build --watch

doc-login:
	aws ecr get-login-password | docker login --username AWS --password-stdin $(ECR_URI)

build:
	docker build -f app.dockerfile -t $(ECR_URI):$(TAG) .

push:
	docker push $(ECR_URI):$(TAG)
