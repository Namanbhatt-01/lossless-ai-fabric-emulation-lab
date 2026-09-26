#!/usr/bin/env bash
# ==============================================================================
# Script to launch isolated FRR instances inside each network namespace
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for node in spine1 spine2 leaf1 leaf2; do
    echo "[*] Launching FRR daemons for ${node}..."
    ip netns exec "${node}" /usr/lib/frr/zebra -d -f "${SCRIPT_DIR}/${node}.conf" || true
    ip netns exec "${node}" /usr/lib/frr/bgpd -d -f "${SCRIPT_DIR}/${node}.conf" || true
done

echo "[+] All FRR instances started."
