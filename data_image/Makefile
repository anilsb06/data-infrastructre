.PHONY: build

IMAGE := data-image:test

build:
	@echo "Building image..."
	@docker build -t ${IMAGE} .

run: build
	@echo "Building image and opening shell..."
	@docker build -t ${IMAGE} . && docker run -i -t ${IMAGE} /bin/bash
