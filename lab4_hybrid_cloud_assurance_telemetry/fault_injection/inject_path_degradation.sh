#!/usr/bin/env bash
# ==============================================================================
# Linux tc netem Fault Injection Script for Path Assurance Verification
# Injects artificial latency, jitter, and packet loss on intermediate transit hops
# ==============================================================================

IFACE=${1:-"eth0"}
ACTION=${2:-"add"} # add, change, del

if [ "${ACTION}" == "del" ]; then
    echo "[-] Removing netem fault injection on ${IFACE}..."
    sudo tc qdisc del dev "${IFACE}" root 2>/dev/null || true
    echo "[+] Fault injection cleared."
    exit 0
fi

echo "[*] Injecting synthetic path degradation: 120ms latency (+/- 25ms jitter), 5% packet loss on ${IFACE}..."
sudo tc qdisc add dev "${IFACE}" root netem delay 120ms 25ms distribution normal loss 5% 25% 2>/dev/null || \
sudo tc qdisc change dev "${IFACE}" root netem delay 120ms 25ms distribution normal loss 5% 25%

echo "[+] Fault injection active. Check Grafana dashboard for alert firing."
