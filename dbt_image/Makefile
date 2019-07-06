.PHONY: build

IMAGE := dbt-image:test

build:
	@echo "Building image..."
	@docker build -t ${IMAGE} .

run: build
	@echo "Building image and opening shell..."
	@docker run -i -t ${IMAGE} /bin/bash
