#!/usr/bin/env bash
# ==============================================================================
# Lab 1: 2-Tier Spine-Leaf Network Topology with Linux Network Namespaces & veth
# ==============================================================================
# Nodes:
#   - Spines: spine1, spine2
#   - Leaves: leaf1, leaf2
#   - End Hosts: host1, host2
# Underlay Interconnects (/31 P2P):
#   - leaf1 <-> spine1: 10.0.1.0/31 (leaf1: 10.0.1.1, spine1: 10.0.1.0)
#   - leaf1 <-> spine2: 10.0.1.2/31 (leaf1: 10.0.1.3, spine2: 10.0.1.2)
#   - leaf2 <-> spine1: 10.0.2.0/31 (leaf2: 10.0.2.1, spine1: 10.0.2.0)
#   - leaf2 <-> spine2: 10.0.2.2/31 (leaf2: 10.0.2.3, spine2: 10.0.2.2)
# Host Links:
#   - host1 <-> leaf1: 172.16.1.10/24 (GW: 172.16.1.1)
#   - host2 <-> leaf2: 172.16.2.20/24 (GW: 172.16.2.1)
# ==============================================================================

set -euo pipefail

echo "[*] Initializing 2-Tier Spine-Leaf Network Namespaces..."

# 1. Create network namespaces
for ns in spine1 spine2 leaf1 leaf2 host1 host2; do
    ip netns add "${ns}" 2>/dev/null || true
    ip netns exec "${ns}" ip link set lo up
    ip netns exec "${ns}" sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true
done

echo "[*] Creating Point-to-Point veth interconnects..."

create_link() {
    local ns1=$1
    local if1=$2
    local ip1=$3
    local ns2=$4
    local if2=$5
    local ip2=$6

    ip link add "${if1}" type veth peer name "${if2}"
    ip link set "${if1}" netns "${ns1}"
    ip link set "${if2}" netns "${ns2}"

    ip netns exec "${ns1}" ip link set "${if1}" mtu 9000
    ip netns exec "${ns2}" ip link set "${if2}" mtu 9000

    ip netns exec "${ns1}" ip addr add "${ip1}" dev "${if1}"
    ip netns exec "${ns2}" ip addr add "${ip2}" dev "${if2}"

    ip netns exec "${ns1}" ip link set "${if1}" up
    ip netns exec "${ns2}" ip link set "${if2}" up
}

# 2. Fabric Underlay Links
create_link leaf1 l1-s1 10.0.1.1/31 spine1 s1-l1 10.0.1.0/31
create_link leaf1 l1-s2 10.0.1.3/31 spine2 s2-l1 10.0.1.2/31
create_link leaf2 l2-s1 10.0.2.1/31 spine1 s1-l2 10.0.2.0/31
create_link leaf2 l2-s2 10.0.2.3/31 spine2 s2-l2 10.0.2.2/31

# 3. Host-to-Leaf Access Links
create_link host1 h1-eth0 172.16.1.10/24 leaf1 l1-h1 172.16.1.1/24
create_link host2 h2-eth0 172.16.2.20/24 leaf2 l2-h2 172.16.2.1/24

# Set default gateways on hosts
ip netns exec host1 ip route add default via 172.16.1.1 dev h1-eth0 || true
ip netns exec host2 ip route add default via 172.16.2.1 dev h2-eth0 || true

# 4. Loopback Addresses for BGP Underlay
ip netns exec spine1 ip addr add 10.255.0.1/32 dev lo
ip netns exec spine2 ip addr add 10.255.0.2/32 dev lo
ip netns exec leaf1  ip addr add 10.255.0.11/32 dev lo
ip netns exec leaf2  ip addr add 10.255.0.12/32 dev lo

# 5. Fabric Routes (ECMP underlay)
ip netns exec leaf1 ip route add 172.16.2.0/24 nexthop via 10.0.1.0 dev l1-s1 nexthop via 10.0.1.2 dev l1-s2 || true
ip netns exec leaf2 ip route add 172.16.1.0/24 nexthop via 10.0.2.0 dev l2-s1 nexthop via 10.0.2.2 dev l2-s2 || true
ip netns exec spine1 ip route add 172.16.1.0/24 via 10.0.1.1 dev s1-l1 || true
ip netns exec spine1 ip route add 172.16.2.0/24 via 10.0.2.1 dev s1-l2 || true
ip netns exec spine2 ip route add 172.16.1.0/24 via 10.0.1.3 dev s2-l1 || true
ip netns exec spine2 ip route add 172.16.2.0/24 via 10.0.2.3 dev s2-l2 || true

echo "[+] Spine-Leaf Network Topology established successfully."
