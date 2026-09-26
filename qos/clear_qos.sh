#!/usr/bin/env bash
# ==============================================================================
# Reset all qdiscs to default fq_codel / pfifo_fast
# ==============================================================================

set -euo pipefail

for ns in leaf1 leaf2 spine1 spine2; do
    echo "[-] Clearing qdiscs for ${ns}..."
    for iface in $(ip netns exec "${ns}" ip -o link show | awk -F': ' '{print $2}' | grep -v 'lo'); do
        ip netns exec "${ns}" tc qdisc del dev "${iface}" root 2>/dev/null || true
    done
done

echo "[+] All QoS qdiscs cleared."
