# Makefile for 3OX.BUILDER
# Quick commands for building and running

.PHONY: build run setup clean install test

build:
	@echo "Building Vec3Boot..."
	cargo build --release

build-cli:
	@echo "Building 3OX CLI..."
	cargo build --release --bin 3ox

install-cli: build-cli
	@echo "Installing 3OX CLI..."
	sudo cp target/release/3ox /usr/local/bin/
	sudo chmod +x /usr/local/bin/3ox
	@echo "✓ 3OX CLI installed. Run '3ox help' to verify."

run: build
	@echo "Running vec3-boot..."
	./target/release/vec3-boot

setup:
	@echo "Setting up 3OX cube..."
	@read -p "Target directory: " dir; \
	read -p "Agent name: " name; \
	read -p "Brain type (Citadel/Sentinel/Alchemist/Lighthouse): " type; \
	ruby 3OX.BUILD/setup-3ox.rb $$dir $$name $$type

clean:
	@echo "Cleaning build artifacts..."
	cargo clean
	rm -rf target/

install:
	@echo "Installing dependencies..."
	bun install || npm install

test:
	@echo "Running tests..."
	cargo test

dist: build
	@echo "Creating distribution..."
	@mkdir -p dist
	@cp target/release/vec3-boot dist/
	@cp target/release/3ox dist/
	@echo "Binaries: dist/vec3-boot, dist/3ox"
	@echo "Package: tar -czf 3ox-binaries-$$(cat VERSION 2>/dev/null || echo v1.0.0).tar.gz dist/"

help:
	@echo "3OX.BUILDER Makefile Commands:"
	@echo "  make build      - Build Rust workspace"
	@echo "  make build-cli  - Build 3OX CLI binary"
	@echo "  make install-cli - Build and install 3OX CLI globally"
	@echo "  make run        - Build and run vec3-boot"
	@echo "  make dist       - Build and copy binaries to dist/"
	@echo "  make setup      - Interactive 3OX cube setup"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make install   - Install NPM/Bun dependencies"
	@echo "  make test      - Run Rust tests"

