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

listener: build
	@echo "Starting the listener..."
	@docker run -it -p 8081:8081 ${IMAGE} server.py
