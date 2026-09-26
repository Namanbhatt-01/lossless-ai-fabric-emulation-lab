# Makefile: Lossless AI Fabric Control Plane & Queue Mechanics Lab
SHELL := /bin/bash

.PHONY: help build run test-local clean

help:
	@echo "=========================================================================="
	@echo "  🚀 Lossless AI Fabric Control Plane & Queue Mechanics Emulation Lab"
	@echo "=========================================================================="
	@echo "Usage:"
	@echo "  make build       - Build the self-contained containerized testbed image"
	@echo "  make run         - Run full automated lab (BGP, tc QoS, RoCEv2, PCAP)"
	@echo "  make clean       - Teardown all namespaces, FRR daemons, and qdiscs"
	@echo "=========================================================================="

build:
	@docker build -t lab1-testbed .

run:
	@docker run --rm --privileged -v $$(pwd):/lab lab1-testbed bash /lab/run_lab1_experiment.sh

clean:
	@sudo bash topology/00_teardown.sh 2>/dev/null || true
