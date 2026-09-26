# Unified Enterprise AI Infrastructure Portfolio Makefile
# Optimized for Apple Silicon M1 (8 GB RAM) - Sequential Lifecycle Execution

SHELL := /bin/bash

.PHONY: help clean-all lab1 clean-lab1 lab2 clean-lab2 lab3 clean-lab3 lab4 clean-lab4 lab5 clean-lab5 lab6 clean-lab6

help:
	@echo "=================================================================================="
	@echo "  🚀 Enterprise AI Infrastructure Operations Platform Portfolio (₹0 / M1 8-GB)"
	@echo "=================================================================================="
	@echo "Usage:"
	@echo "  make lab1        - Build & Start Lab 1 (Lossless AI Fabric & tc Queues)"
	@echo "  make clean-lab1  - Teardown Lab 1"
	@echo "  make lab2        - Run Lab 2 (NetDevOps CI/CD Pipeline & pytest validation)"
	@echo "  make clean-lab2  - Teardown Lab 2"
	@echo "  make lab3        - Deploy Lab 3 (Open-Source SIEM & Security for AI Workloads)"
	@echo "  make clean-lab3  - Teardown Lab 3"
	@echo "  make lab4        - Deploy Lab 4 (Hybrid Cloud Path Assurance & Synthetic Probing)"
	@echo "  make clean-lab4  - Teardown Lab 4"
	@echo "  make lab5        - Run Lab 5 (Zero-Trust AI RAG Security Audit & SAST)"
	@echo "  make clean-lab5  - Teardown Lab 5"
	@echo "  make lab6        - Deploy Lab 6 (Streaming Telemetry & Switch Queue Monitoring)"
	@echo "  make clean-lab6  - Teardown Lab 6"
	@echo "  make clean-all   - Full environment teardown (Prunes containers and namespaces)"
	@echo "=================================================================================="

# --- Lab 1: Lossless AI Fabric Control Plane & Queue Mechanics ---
lab1:
	@echo ">>> Starting Lab 1: Lossless AI Fabric Topology..."
	@sudo bash lab1_lossless_fabric_queue_mechanics/topology/01_setup_topology.sh
	@sudo bash lab1_lossless_fabric_queue_mechanics/qos/apply_qos_tc.sh

clean-lab1:
	@echo ">>> Tearing down Lab 1..."
	@sudo bash lab1_lossless_fabric_queue_mechanics/topology/00_teardown.sh || true

# --- Lab 2: NetDevOps CI/CD Pipeline ---
lab2:
	@echo ">>> Starting Lab 2: NetDevOps CI/CD Testbed..."
	@cd lab2_netdevops_cicd_pipeline && pytest tests/ -v

clean-lab2:
	@echo ">>> Cleaning Lab 2 Artifacts..."
	@rm -rf lab2_netdevops_cicd_pipeline/.pytest_cache lab2_netdevops_cicd_pipeline/__pycache__

# --- Lab 3: SIEM & Security Pipeline for AI Workloads ---
lab3:
	@echo ">>> Deploying Lab 3: Open-Source SIEM & Security Stack..."
	@cd lab3_siem_security_ai_workloads && docker compose up -d

clean-lab3:
	@echo ">>> Tearing down Lab 3..."
	@cd lab3_siem_security_ai_workloads && docker compose down -v || true

# --- Lab 4: Hybrid Cloud Assurance & Synthetic Probing ---
lab4:
	@echo ">>> Deploying Lab 4: Hybrid Cloud Assurance Stack..."
	@cd lab4_hybrid_cloud_assurance_telemetry && docker compose up -d

clean-lab4:
	@echo ">>> Tearing down Lab 4..."
	@cd lab4_hybrid_cloud_assurance_telemetry && docker compose down -v || true

# --- Lab 5: Zero Trust AI RAG Security Audit ---
lab5:
	@echo ">>> Starting Lab 5: Zero-Trust RAG Security Audit..."
	@cd lab5_zero_trust_rag_security_audit && docker compose up -d
	@pytest lab5_zero_trust_rag_security_audit/audit_suite/ -v

clean-lab5:
	@echo ">>> Tearing down Lab 5..."
	@cd lab5_zero_trust_rag_security_audit && docker compose down -v || true

# --- Lab 6: Streaming Telemetry & Switch Queue Monitoring ---
lab6:
	@echo ">>> Deploying Lab 6: Streaming Telemetry Stack..."
	@cd lab6_streaming_telemetry_queue_monitor && docker compose up -d

clean-lab6:
	@echo ">>> Tearing down Lab 6..."
	@cd lab6_streaming_telemetry_queue_monitor && docker compose down -v || true

# --- Global Teardown ---
clean-all: clean-lab1 clean-lab2 clean-lab3 clean-lab4 clean-lab5 clean-lab6
	@echo ">>> All lab environments and temporary state cleaned up."
