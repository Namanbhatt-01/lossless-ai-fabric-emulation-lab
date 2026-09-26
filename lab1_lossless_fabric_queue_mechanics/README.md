# 🔬 Lab 1: Lossless AI Fabric Control Plane & Queue Mechanics (Emulated)
### Spine–Leaf BGP EVPN, Linux `tc` Multi-Queue Scheduling, RoCEv2 (UDP 4791), RED/ECN Marking & ASIC Boundary Analysis

---

## 📌 Executive Architecture Overview

This project provides a complete, reproducible emulation of an **AI Data Center Lossless Fabric** using:
* **Control Plane:** 2-Tier Spine-Leaf topology (`spine1`, `spine2`, `leaf1`, `leaf2`) running FRRouting (FRR) BGP EVPN (RFC 7432) with Route Reflection.
* **Datapath & QoS:** Linux Traffic Control (`tc`) multi-queue `prio` scheduling, Random Early Detection (`red`) with Explicit Congestion Notification (`ecn` marking per RFC 3168), and Token Bucket Filter (`tbf`) rate pacing.
* **Traffic Injection:** Scapy synthetic RoCEv2 (UDP port `4791`, DSCP 46 / Expedited Forwarding, ECT(0) `0b10`).
* **Congestion Simulation:** Multi-flow synchronized Incast microbursts triggering queue occupancy buildup, early ECN Congestion Experienced (`CE = 0b11`) marking, and zero packet drops.
* **Hardware Boundary Documentation:** Rigorous comparative analysis distinguishing Linux kernel-space scheduling from physical Cisco Cloud Scale / Silicon One ASICs (VoQ, shared buffer pools, line-rate cut-through switching).

```mermaid
graph TD
    subgraph Spine_Tier [Spine Tier: BGP EVPN Route Reflectors]
        S1[spine1<br/>AS 65000 | 10.255.0.1]
        S2[spine2<br/>AS 65000 | 10.255.0.2]
    end

    subgraph Leaf_Tier [Leaf Tier: VTEPs & tc QoS Scheduling]
        L1[leaf1<br/>AS 65011 | 10.255.0.11<br/>tc PRIO + RED/ECN + TBF]
        L2[leaf2<br/>AS 65012 | 10.255.0.12<br/>tc PRIO + RED/ECN + TBF]
    end

    subgraph Host_Tier [AI Compute Nodes: RoCEv2 GPU All-Reduce]
        H1[host1 / GPU Node 1<br/>172.16.10.10<br/>Scapy Sender]
        H2[host2 / GPU Node 2<br/>172.16.10.20<br/>Target Receiver]
    end

    S1 <-->|10.0.1.0/31| L1
    S1 <-->|10.0.2.0/31| L2
    S2 <-->|10.0.1.2/31| L1
    S2 <-->|10.0.2.2/31| L2

    L1 <-->|172.16.10.0/24| H1
    L2 <-->|172.16.10.0/24| H2
```

---

## ⚡ One-Click Execution

To execute the entire end-to-end lab, run:

```bash
docker run --rm --privileged \
  -v $(pwd):/lab \
  lab1-testbed \
  bash /lab/lab1_lossless_fabric_queue_mechanics/run_lab1_experiment.sh
```

---

## 📊 Live Verification & Proof Telemetry

### 1. BGP EVPN Fabric Routing & Adjacencies

```
IPv4 Unicast Underlay Peerings:
Neighbor        V    AS   MsgRcvd MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd
10.0.1.1        4 65011       14      14        0    0    0 00:00:08            8
10.0.2.1        4 65012       14      14        0    0    0 00:00:08            8
```

### 2. Linux `tc` Multi-Queue Scheduler & ECN Marking

Before congestion, queue statistics show clean zero-drop baselines. During synchronized RoCEv2 All-Reduce microbursts, the RED qdisc dynamically marks packets with Congestion Experienced (CE) without dropping packets:

```
# tc -s qdisc show dev l1-s1
qdisc prio 1: root refcnt 2 bands 3 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 1177600 bytes 1100 pkt (dropped 0, overlimits 100 requeues 0) 
 backlog 0b 0p requeues 0

qdisc tbf 10: parent 1:1 rate 100Mbit burst 4Kb lat 1.72ms 
 Sent 1177600 bytes 1100 pkt (dropped 0, overlimits 100 requeues 0) 
 backlog 0b 0p requeues 0

qdisc red 100: parent 10:1 limit 200000b min 20000b max 60000b ecn 
 Sent 1177600 bytes 1100 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0
  marked 42 early 0 pdrop 0 other 0 

qdisc red 20: parent 1:2 limit 200000b min 30000b max 80000b 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0
```

> **Key Finding:** **42 packets** were marked (`marked 42`) with ECN Congestion Experienced (`0b11`) when queue occupancy crossed the minimum threshold ($20\text{ KB}$), achieving proactive congestion notification with **0 dropped packets** (`dropped 0`).

---

### 3. Wireshark / TShark Packet Validation

Decoded PCAP trace (`artifacts/pcaps/rocev2_congestion_capture.pcap`):

| Frame | Source IP | Destination IP | DSCP (TOS) | ECN Bits | Dest Port | Decoded Protocol |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 172.16.10.10 | 172.16.10.20 | **46 (EF)** | `0b10` (ECT 0) | 4791 | RoCEv2 RDMA Write |
| 2 | 172.16.10.10 | 172.16.10.20 | **46 (EF)** | `0b10` (ECT 0) | 4791 | RoCEv2 RDMA Write |
| 3 | 172.16.10.10 | 172.16.10.20 | **46 (EF)** | `0b10` (ECT 0) | 4791 | RoCEv2 RDMA Write |
| 4 | 172.16.10.10 | 172.16.10.20 | **46 (EF)** | **`0b11` (CE)** | 4791 | **RoCEv2 [Congestion Marked]** |
| 5 | 172.16.10.10 | 172.16.10.20 | **46 (EF)** | **`0b11` (CE)** | 4791 | **RoCEv2 [Congestion Marked]** |
| 6 | 172.16.10.10 | 172.16.10.20 | **46 (EF)** | **`0b11` (CE)** | 4791 | **RoCEv2 [Congestion Marked]** |
| 7 | 172.16.10.10 | 172.16.10.20 | **46 (EF)** | `0b10` (ECT 0) | 4791 | RoCEv2 RDMA Write |

---

## 🏛️ Linux Kernel Software vs. Cisco ASIC Hardware Boundary

For the full architectural analysis, read the engineering memo:  
📄 [docs/software_vs_asic_buffer_memo.md](file:///Users/namanbhatt/labdirected/lab1_lossless_fabric_queue_mechanics/docs/software_vs_asic_buffer_memo.md)

### Key Architectural Boundaries:
1. **Host Memory vs. Shared SRAM:** Linux manages queues as `sk_buff` structs linked in host DRAM subject to kernel spinlocks (`qdisc_lock`), whereas Cisco Cloud Scale ASICs buffer packets as fixed-size cells in ultra-fast monolithic on-chip SRAM ($\sim 80\ \text{MB}$).
2. **Head-of-Line (HoL) Blocking:** Linux `qdisc` suffers from Head-of-Line delays during multi-flow incast. Cisco Silicon One ASICs utilize **Virtual Output Queuing (VoQ)** with hardware credit requests/grants across the crossbar, completely eliminating HoL blocking.
3. **PFC Flow Control:** Physical switches generate sub-microsecond IEEE 802.1Qbb pause frames backed by hardware `pfc-watchdog` drop timers ($100\ \text{ms}$) to prevent deadlock loops.
