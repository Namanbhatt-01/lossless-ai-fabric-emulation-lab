# LAB 01: Lossless AI Fabric Emulation

[![CI/CD Pipeline](https://github.com/Namanbhatt-01/lossless-ai-fabric-emulation-lab/actions/workflows/lab1_ci.yml/badge.svg)](https://github.com/Namanbhatt-01/lossless-ai-fabric-emulation-lab/actions/workflows/lab1_ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![FRRouting](https://img.shields.io/badge/Control_Plane-FRRouting_v9.1-orange)](https://frrouting.org/)

A reproducible laboratory for evaluating queue pressure, buffer occupancy dynamics, and ECN (Explicit Congestion Notification) marking in a Linux-based approximation of an AI training fabric.

---

## 1. Problem Statement

Distributed AI training frameworks (e.g., PyTorch FSDP, DeepSpeed) execute synchronized collective communication patterns (All-Reduce, All-to-All) where multiple compute nodes transmit simultaneously to a single receiver. This generates severe incast traffic that rapidly fills switch egress buffer queues.

Without proactive congestion management:
- Queues overflow, triggering packet drops.
- Dropped packets cause RoCEv2 go-back-N retransmissions and throughput collapse.
- If Priority Flow Control (PFC) triggers excessively, it can cause PFC deadlocks and head-of-line blocking.

This lab configures strict priority queueing (`tc PRIO`) combined with Random Early Detection / ECN (`tc RED`) to evaluate proactive congestion marking before buffer overflow occurs.

---

## 2. Emulation Fidelity & Boundaries

This repository is a software emulation running in Linux network namespaces within Docker. The table below details what is emulated vs what is approximated:

| Behavior | Emulated Accurately | Approximation | Not Modeled |
| :--- | :---: | :---: | :---: |
| **BGP Control Plane (FRR)** | ✓ | | |
| **Linux `tc` qdisc & RED/ECN** | ✓ | | |
| **Synthetic RoCEv2 Traffic (UDP 4791)** | ✓ | | |
| **Switch ASIC Shared Buffer Pools** | | ✓ | |
| **Switch Hardware Arbiters** | | ✓ | |
| **Hardware PFC Pause Frame Generation** | | ✓ | |
| **NIC Hardware RDMA Offload (RNIC)** | | | ✓ |
| **GPU CUDA Collective Kernels** | | | ✓ |

For detailed analysis, see [docs/emulation-boundaries.md](docs/emulation-boundaries.md) and [docs/software_vs_asic_buffer_memo.md](docs/software_vs_asic_buffer_memo.md).

---

## 3. Topology & Experiment Workflow

```
[ host1 (172.16.1.10) ] ─── [ leaf1 ] ─── [ spine1 (Monitor) ] ─── [ leaf2 ] ─── [ host2 (172.16.2.20) ]
```

1. **Topology Setup**: Creates isolated network namespaces and veth pairs for `host1`, `leaf1`, `spine1`, `leaf2`, and `host2`.
2. **Control Plane**: Starts FRR daemons (`zebra`, `bgpd`) to establish eBGP routing across the 2-tier spine-leaf fabric.
3. **QoS Configuration**: Attaches `tc PRIO` + `RED` with ECN marking on leaf egress interfaces for DSCP EF traffic.
4. **Traffic Injection**: Injects background RoCEv2 UDP packets followed by multi-flow synchronized incast bursts.
5. **Telemetry & Verification**: Extracts `tc` queue stats, captures packet traces, and asserts that ECN CE bits (0b11) are marked without packet loss.

---

## 4. Evidence Envelope Output

The verification script generates a canonical JSON evidence record at `poc/evidence.json`:

```json
{
  "schema_version": "1.0",
  "experiment": {
    "id": "fabric-lossless-001",
    "name": "RoCEv2 Incast Microburst and ECN Congestion Marking Emulation"
  },
  "execution": {
    "run_id": "fabric-20260929-150000",
    "timestamp": "2026-09-29T15:00:00Z",
    "environment": "docker-container",
    "platform": "linux-arm64"
  },
  "measurements": [
    { "metric": "total_rocev2_packets_captured", "value": 2600, "mode": "measured" },
    { "metric": "ecn_ce_marked_packets", "value": 148, "mode": "measured" },
    { "metric": "uncontrolled_packet_drops", "value": 0, "mode": "measured" }
  ],
  "assertions": [
    { "id": "FABRIC-ASSERT-001", "name": "BGP Overlay Convergence", "passed": true },
    { "id": "FABRIC-ASSERT-002", "name": "Proactive ECN Congestion Marking Active", "passed": true }
  ],
  "result": "passed"
}
```

---

## 5. Quickstart & Local Reproduction

### Run via Docker
```bash
# 1. Build and execute automated testbed in privileged container
make run

# 2. View generated packet captures and queue stats
ls -l artifacts/logs/ artifacts/pcaps/
```

---

## 6. Known Limitations

1. **Software Timers**: Packet generation and scheduling rely on Linux kernel software timers rather than hardware clock oscillators found in physical switch ASICs.
2. **Traffic Payload**: Synthetic RoCEv2 generator emits UDP packets on port 4791 with appropriate DSCP/ECN headers, but does not implement the complete InfiniBand BTH/AETH transport protocol state machine.

---

## 7. License

MIT License. See [LICENSE](LICENSE) for details.
