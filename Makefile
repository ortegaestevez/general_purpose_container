# --- Configuration ---
# Image name for your container
IMAGE_NAME := dev-environment
# Tag for the image
IMAGE_TAG := latest
# Full image name
FULL_IMAGE_NAME := $(IMAGE_NAME):$(IMAGE_TAG)
# Name for the running container instance
CONTAINER_NAME := dev-env-instance
# Path to your source code on the host system (IMPORTANT: Update this!)
# Example: HOST_SRC_DIR := $(HOME)/projects
HOST_SRC_DIR := $(PWD)/projects
# Mount point for the source code inside the container
CONTAINER_SRC_DIR := /workspace

# Get current user's UID and GID to potentially match in container (optional, for file permissions)
CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)

# --- Podman Commands ---
PODMAN ?= $(shell command -v podman 2>/dev/null || echo docker)

# --- Targets ---

.PHONY: all build run exec clean rmi help

all: build

# Build the container image
build:
	@echo "Building container image $(FULL_IMAGE_NAME)..."
	$(PODMAN) build \
		--build-arg USER_UID=$(CURRENT_UID) \
		--build-arg USER_GID=$(CURRENT_GID) \
		-t $(FULL_IMAGE_NAME) .
	@echo "Build complete."

run:
	@echo "Running container $(CONTAINER_NAME) from image $(FULL_IMAGE_NAME)..."
	@echo "Host source directory: $(HOST_SRC_DIR)"
	@echo "Mounted to: $(CONTAINER_SRC_DIR) in container"
	@if [ ! -d "$(HOST_SRC_DIR)" ]; then \
		echo "Host source directory '$(HOST_SRC_DIR)' does not exist. Creating it..."; \
		mkdir -p $(HOST_SRC_DIR); \
	fi
	# Check if the container already exists
	$(PODMAN) inspect --type=container $(CONTAINER_NAME) >/dev/null 2>&1 || \
		$(PODMAN) run -it \
			--name $(CONTAINER_NAME) \
			-p 8000:8000 \
			-v "$(HOST_SRC_DIR):$(CONTAINER_SRC_DIR):rw,z" \
			$(FULL_IMAGE_NAME)

	# If the container exists, start and attach to it
	$(PODMAN) start $(CONTAINER_NAME)
	$(PODMAN) attach $(CONTAINER_NAME)

# Execute a shell in an already running container (if you detach or run it in background)
exec:
	@echo "Executing shell in running container $(CONTAINER_NAME)..."
	$(PODMAN) exec -it $(CONTAINER_NAME) /bin/bash

# Stop and remove the running container (if any)
clean:
	@echo "Stopping and removing container $(CONTAINER_NAME)..."
	-$(PODMAN) stop $(CONTAINER_NAME) 2>/dev/null || true
	-$(PODMAN) rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "Cleanup complete."

# Remove the container image
rmi: clean
	@echo "Removing image $(FULL_IMAGE_NAME)..."
	-$(PODMAN) rmi $(FULL_IMAGE_NAME) 2>/dev/null || true
	@echo "Image removal complete."

# Display help
help:
	@echo "Available commands:"
	@echo "  make build          Build the container image."
	@echo "  make run            Run the container, mounting your source code."
	@echo "  make exec           Execute a shell in a running container (if detached)."
	@echo "  make clean          Stop and remove the running container instance."
	@echo "  make rmi            Remove the container image (includes clean)."
	@echo "  make help           Show this help message."
	@echo ""
	@echo "Configuration:"
	@echo "  IMAGE_NAME        : $(IMAGE_NAME)"
	@echo "  IMAGE_TAG         : $(IMAGE_TAG)"
	@echo "  CONTAINER_NAME    : $(CONTAINER_NAME)"
	@echo "  HOST_SRC_DIR      : $(HOST_SRC_DIR) (Update if needed!)"
	@echo "  CONTAINER_SRC_DIR : $(CONTAINER_SRC_DIR)"
