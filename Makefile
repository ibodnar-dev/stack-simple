ECR_URI := $(shell aws ecr describe-repositories --repository-names stack-simple --query\
 'repositories[0].repositoryUri' --output text)
TAG ?= latest
PROD_DOCKERFILE := infra/production/app.production.dockerfile

dc-up:
	docker-compose up --watch

dc-up-build:
	docker-compose up --build --watch

doc-login:
	aws ecr get-login-password | docker login --username AWS --password-stdin $(ECR_URI)

build:
	docker build --no-cache -f $(PROD_DOCKERFILE) -t $(ECR_URI):$(TAG) .

push:
	docker push $(ECR_URI):$(TAG)
