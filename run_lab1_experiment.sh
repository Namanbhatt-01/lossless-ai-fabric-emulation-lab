#!/usr/bin/env bash
# ==============================================================================
# Comprehensive Automated Execution & Verification Script for Lab 1
# ==============================================================================

set -uo pipefail

LAB_DIR="/lab"
LOGS_DIR="${LAB_DIR}/artifacts/logs"
PCAP_DIR="${LAB_DIR}/artifacts/pcaps"

mkdir -p "${LOGS_DIR}" "${PCAP_DIR}"

echo "=============================================================================="
echo " [STEP 1/5] Setting up 2-Tier Spine-Leaf Topology & Namespaces"
echo "=============================================================================="
bash "${LAB_DIR}/topology/01_setup_topology.sh"

echo "=============================================================================="
echo " [STEP 2/5] Starting FRRouting (FRR) Zebra & BGP Daemons"
echo "=============================================================================="
bash "${LAB_DIR}/frr_configs/start_frr.sh"
sleep 4

echo "=============================================================================="
echo " [STEP 3/5] Provisioning Linux tc: Binding RED/ECN to Strict Priority Band 0 (DSCP EF)"
echo "=============================================================================="
bash "${LAB_DIR}/qos/apply_qos_tc.sh" "ecn_enabled"

echo "=============================================================================="
echo " [STEP 4/5] Capturing PCAP at Downstream Node (spine1) & Injecting RoCEv2 Bursts"
echo "=============================================================================="
rm -f "${PCAP_DIR}/rocev2_congestion_capture.pcap"
ip netns exec spine1 tcpdump -U -i s1-l1 -s 0 -w "${PCAP_DIR}/rocev2_congestion_capture.pcap" "udp port 4791" &
TCPDUMP_PID=$!
sleep 1

echo "[*] Sending steady RoCEv2 stream (1,000 packets)..."
ip netns exec host1 python3 "${LAB_DIR}/traffic/rocev2_generator.py" --dst 172.16.2.20 --count 1000 --delay 0.0005

echo "[*] Firing 8-flow synchronized Incast Microbursts to trigger queue buffer buildup..."
ip netns exec host1 python3 "${LAB_DIR}/traffic/incast_microburst.py" --flows 8 --burst-size 200 --rounds 10 --dst 172.16.2.20

sleep 2
kill -2 "${TCPDUMP_PID}" 2>/dev/null || true
sleep 1

echo "=============================================================================="
echo " [STEP 5/5] Telemetry Extraction: tc Queue Stats & PCAP TShark Inspection"
echo "=============================================================================="
echo "--- Live tc Queue Statistics on Leaf 1 (l1-s1) ---"
ip netns exec leaf1 tc -s qdisc show dev l1-s1 | tee "${LOGS_DIR}/04_tc_congested.txt"

echo ""
echo "--- PCAP Summary & First 25 Packets (TShark Decode) ---"
tshark -r "${PCAP_DIR}/rocev2_congestion_capture.pcap" -T fields \
    -e frame.number -e ip.src -e ip.dst -e ip.dsfield.dscp -e ip.dsfield.ecn -e udp.dstport \
    | head -n 35 | tee "${LOGS_DIR}/05_packet_analysis.txt"

TOTAL_PKTS=$(tshark -r "${PCAP_DIR}/rocev2_congestion_capture.pcap" 2>/dev/null | wc -l)
CE_PKTS=$(tshark -r "${PCAP_DIR}/rocev2_congestion_capture.pcap" -Y "ip.dsfield.ecn == 3" 2>/dev/null | wc -l)

echo ""
echo "=============================================================================="
echo " [✓] EXPERIMENT COMPLETE:"
echo "     - Total Packets in PCAP: ${TOTAL_PKTS}"
echo "     - Congestion Experienced (CE = 0b11) Marked Packets: ${CE_PKTS}"
echo "     - PCAP File Size: $(ls -lh ${PCAP_DIR}/rocev2_congestion_capture.pcap | awk '{print $5}')"
echo "=============================================================================="
