#!/usr/bin/env bash
# ==============================================================================
# Lab 1: Linux tc Multi-Queue PRIO + RED/ECN + TBF Rate Pacing Configuration
# ==============================================================================
# Critical Design Principle:
#   When RoCEv2 is mapped to DSCP 46 (EF - Expedited Forwarding) in strict-priority
#   Band 0 (Class 1:1), ECN marking thresholds MUST be explicitly bound to Band 0.
#   If ECN is omitted or only bound to best-effort (Band 1), the strict-priority
#   queue will silently fill its buffer and drop packets (causing severe RoCEv2
#   timeouts/retransmits).
# ==============================================================================

set -euo pipefail

MODE=${1:-"ecn_enabled"} # Options: "ecn_enabled" or "ecn_disabled_failure_mode"

configure_interface_tc() {
    local ns=$1
    local iface=$2

    echo "[*] Applying tc QoS hierarchy (${MODE}) to ${ns} on interface ${iface}..."

    # Reset existing qdisc
    ip netns exec "${ns}" tc qdisc del dev "${iface}" root 2>/dev/null || true

    # 1. Attach Root PRIO Qdisc (3 bands)
    # Band 0 = Strict Priority (Class 1:1)
    # Band 1 = Standard Best Effort (Class 1:2)
    # Band 2 = Background / Scavenger (Class 1:3)
    ip netns exec "${ns}" tc qdisc add dev "${iface}" root handle 1: prio bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

    # 2. Attach TBF Rate Shaper to Band 0 (Class 1:1) to throttle egress rate to 50Mbit
    ip netns exec "${ns}" tc qdisc add dev "${iface}" parent 1:1 handle 10: tbf rate 50mbit burst 16kbit limit 100kbit

    if [ "${MODE}" == "ecn_enabled" ]; then
        # Explicitly bind RED with ECN to Strict-Priority Band 0
        # min 15KB, max 45KB threshold, ECN bit marking enabled
        ip netns exec "${ns}" tc qdisc add dev "${iface}" parent 10:1 handle 100: red limit 100000 min 15000 max 45000 avpkt 1000 burst 15 probability 0.3 ecn
    else
        # FAILURE MODE: ECN disabled on strict-priority queue (hard drop buffer)
        ip netns exec "${ns}" tc qdisc add dev "${iface}" parent 10:1 handle 100: bfifo limit 30000
    fi

    # 3. Attach Best-Effort RED to Band 1 (Class 1:2)
    ip netns exec "${ns}" tc qdisc add dev "${iface}" parent 1:2 handle 20: red limit 200000 min 30000 max 80000 avpkt 1000 burst 30 probability 0.1

    # 4. Classifier Filters: Map DSCP 46 (EF/RoCEv2) to Strict Priority Band 0 (1:1)
    # TOS 0xb8 = (DSCP 46 << 2)
    ip netns exec "${ns}" tc filter add dev "${iface}" protocol ip parent 1:0 prio 1 u32 match ip tos 0xb8 0xfc flowid 1:1

    # Map DSCP 0 (Best Effort) to Band 1 (1:2)
    ip netns exec "${ns}" tc filter add dev "${iface}" protocol ip parent 1:0 prio 2 u32 match ip tos 0x00 0xfc flowid 1:2
}

# Apply to Leaf-Spine interfaces
configure_interface_tc leaf1 l1-s1
configure_interface_tc leaf1 l1-s2
configure_interface_tc leaf2 l2-s1
configure_interface_tc leaf2 l2-s2

echo "[+] Multi-queue PRIO with DSCP EF classification applied (${MODE})."
