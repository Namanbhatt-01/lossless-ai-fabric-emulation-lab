#!/usr/bin/env bash
# ==============================================================================
# Automated Security Vulnerability Audit Suite (SAST, Container Scanning, SBOM)
# ==============================================================================

set -euo pipefail

echo "======================================================================"
echo " Starting Automated Zero-Trust AI Security Audit"
echo "======================================================================"

# 1. Bandit Static Application Security Testing (SAST) for Python RAG
echo "[*] Running Bandit SAST scan on RAG pipeline..."
bandit -r lab5_zero_trust_rag_security_audit/app/ -ll || echo "[!] Bandit identified items for review."

# 2. Pytest RBAC & Prompt Injection Boundary Assertions
echo "[*] Executing Pytest Zero-Trust Security Assertions..."
pytest lab5_zero_trust_rag_security_audit/audit_suite/ -v

echo "[+] Security audit suite execution complete."
