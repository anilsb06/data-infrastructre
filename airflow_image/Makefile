.PHONY: build

IMAGE := airflow-image:test
WEBSERVER := airflow_image_webserver_1

attach: build
	@echo "Spinning up Airflow and attaching..."
	@docker-compose up -d
	@sleep 10
	@docker exec -ti ${WEBSERVER} /bin/bash

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
