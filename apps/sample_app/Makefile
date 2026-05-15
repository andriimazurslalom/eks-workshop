APP_NAME := sample-app
APP_VERSION := $(shell python3 -c 'import tomllib; print(tomllib.load(open("pyproject.toml","rb"))["project"]["version"])')
AWS_REGION ?= $(shell aws configure get region 2>/dev/null)
AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)
ECR_REPO := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APP_NAME)
LOCAL_PORT ?= 8000
K8S_SERVICE_PORT ?= 80

.PHONY: format lint test check build run build-run ecr-login tag push push-latest deploy port-forward

build:
	docker build \
	--build-arg APP_VERSION=$(APP_VERSION) \
	-t $(APP_NAME):$(APP_VERSION) .

run:
	docker run --rm \
	-p $(LOCAL_PORT):8000 \
	-e APP_VERSION=$(APP_VERSION) \
	$(APP_NAME):$(APP_VERSION)

build-run: build
	docker run --rm \
	-p $(LOCAL_PORT):8000 \
	-e APP_VERSION=$(APP_VERSION) \
	$(APP_NAME):$(APP_VERSION)

ecr-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

tag:
	docker tag $(APP_NAME):$(APP_VERSION) $(ECR_REPO):$(APP_VERSION)

push: ecr-login tag
	docker push $(ECR_REPO):$(APP_VERSION)

push-latest: ecr-login
	docker tag $(APP_NAME):$(APP_VERSION) $(ECR_REPO):latest
	docker push $(ECR_REPO):latest

deploy: build push
	cd ../../k8s/sample_app && kustomize edit set image sample-app-image=$(ECR_REPO):$(APP_VERSION)
	kubectl apply -k ../../k8s/sample_app

port-forward:
	kubectl port-forward -n sample-app svc/$(APP_NAME) $(LOCAL_PORT):$(K8S_SERVICE_PORT)

format:
	python3 -m ruff format app tests

lint:
	python3 -m ruff check app tests

test:
	python3 -m pytest tests

check: lint test