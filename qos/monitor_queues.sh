#!/usr/bin/env bash
# ==============================================================================
# Sample queue statistics (tc -s qdisc show) in real-time
# ==============================================================================

NS=${1:-"leaf1"}
IFACE=${2:-"l1-s1"}

echo "======================================================================"
echo " Real-Time tc Queue Statistics: Namespace=${NS}, Interface=${IFACE}"
echo "======================================================================"

while true; do
    clear
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Live Queue Inspection for ${NS} -> ${IFACE}:"
    echo "----------------------------------------------------------------------"
    ip netns exec "${NS}" tc -s qdisc show dev "${IFACE}"
    echo "----------------------------------------------------------------------"
    echo "[*] Press Ctrl+C to exit monitor."
    sleep 1
done
