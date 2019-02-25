.PHONY: build

IMAGE := airflow-image:test

build:
	@echo "Building image..."
	@docker build -t ${IMAGE} .

run: build
	@echo "Building image and opening shell..."
	@docker run -i -t ${IMAGE} /bin/bash

compose: build
	@echo "Composing airflow..."
	@docker-compose up

cleanup:
	@echo "Cleaning things up..."
	@docker system prune -f

watcher: build
	@echo "Starting the watcher..."
	@docker run -it ${IMAGE} repo_watcher.py
