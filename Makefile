IMAGE_NAME = dev-rust-java-python
CONTAINER_NAME = dev-env

.PHONY: build run exec stop run8080

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-v $(shell pwd):/workspace \
		-w /workspace \
		$(IMAGE_NAME)

exec:
	docker exec -it $(CONTAINER_NAME) bash

stop:
	docker stop $(CONTAINER_NAME) || true

run8080:
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-p 8080:8080 \
		-v $(shell pwd):/workspace \
		-w /workspace \
		$(IMAGE_NAME)
