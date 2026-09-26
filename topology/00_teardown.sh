#!/usr/bin/env bash
# ==============================================================================
# Lab 1: Clean Teardown Script
# ==============================================================================

set -euo pipefail

echo "[*] Tearing down Lab 1 namespaces and FRR instances..."

# Kill any running FRR daemons for these namespaces
pkill -f "zebra.*(spine|leaf)" || true
pkill -f "bgpd.*(spine|leaf)" || true

# Remove network namespaces (this automatically deletes attached veth pairs)
for ns in spine1 spine2 leaf1 leaf2 host1 host2; do
    if ip netns list | grep -qw "${ns}"; then
        echo "[-] Removing namespace: ${ns}"
        ip netns del "${ns}" 2>/dev/null || true
    fi
done

echo "[+] Lab 1 teardown complete."
