# Emulation Boundaries & Architectural Fidelity

This document specifies the exact boundaries of the software emulation used in this laboratory compared to physical AI fabric hardware.

---

## 1. Emulation Fidelity Matrix

| Behavior / Component | Emulated Accurately | Approximation | Not Modeled | Implementation Details / Rationale |
| :--- | :---: | :---: | :---: | :--- |
| **BGP / EVPN Control Plane** | ✓ | | | FRRouting (`bgpd`, `zebra`) running in isolated Linux network namespaces. |
| **Linux Queue Discipline (`qdisc`)** | ✓ | | | Kernel `PRIO` + `RED` (Random Early Detection) with ECN marking enabled. |
| **RoCEv2 Synthetic Traffic** | ✓ | | | UDP port 4791 encapsulation with DSCP / IP ECN bit formatting. |
| **ASIC Shared Buffer Architecture** | | ✓ | | Linux kernel socket buffer memory; does not model physical ASIC dynamic memory pools (Alpha parameter cell allocation). |
| **Switch ASIC Pipeline Scheduling** | | ✓ | | Software scheduler emulation; physical switch ASIC credit-based crossbar arbiters are not modeled. |
| **PFC Hardware Pipeline (802.1Qbb)** | | ✓ | | Emulated via software queue thresholds and signaling; lacks line-rate hardware link-level pause generation in physical PHY/MAC. |
| **NIC Hardware RDMA Offload** | | | ✓ | Physical RoCEv2 RNIC offload pipelines (ConnectX / BlueField ASICs) are not present in containerized software. |
| **GPU Collective Communication** | | | ✓ | Synthetic UDP load generators simulate incast patterns rather than physical NVIDIA CUDA All-Reduce kernels. |

---

## 2. Engineering Value of the Emulation

While software containers cannot replicate physical multi-terabit ASIC switching latency (sub-800ns) or hardware RoCEv2 state machines, this laboratory provides high-fidelity modeling of:
1. **Queue Depth Dynamics**: Observing buffer buildup during synchronized multi-sender incast.
2. **ECN Marking Mechanics**: Verifying that `min` and `max` probability thresholds apply CE (Congestion Experienced) bits without dropping packets.
3. **Control Plane Convergence**: Proving BGP route advertisement and convergence over overlay networks.
