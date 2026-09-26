# 🚀 Enterprise AI Infrastructure & Network Operations Portfolio
### High-Performance Lossless Fabrics, NetDevOps, Cloud Observability, SIEM Security, and Zero-Trust AI (₹0 / M1 8-GB Optimized)

---

## 📑 Portfolio Overview & Architecture

This repository contains **6 production-grade, reproducible laboratory projects** designed to master and demonstrate full-stack AI data center infrastructure, lossless fabric design, CI/CD NetDevOps automation, multi-cloud assurance, threat detection, and zero-trust security.

Every lab is optimized to run with **₹0 licensing cost** on an **Apple Silicon M1 MacBook Air (8 GB RAM)** using lightweight containerization, Linux network namespaces, native ARM64 binaries, and strict memory budgeting.

---

## 📂 Repository Structure by Section / Lab

```
labdirected/
├── README.md
├── Makefile                                      # Unified lifecycle management (make lab1, make clean, etc.)
│
├── lab1_lossless_fabric_queue_mechanics/         # Lab 1: Lossless AI Fabric Control Plane & Queue Mechanics
│   ├── topology/
│   │   ├── 01_setup_topology.sh                  # 2-Tier Spine-Leaf namespace + veth orchestration
│   │   └── 00_teardown.sh                        # Clean teardown script
│   ├── frr_configs/                              # FRR BGP EVPN configs (Spine1/2 RR, Leaf1/2 VTEPs)
│   │   ├── daemons
│   │   ├── spine1.conf / spine2.conf
│   │   ├── leaf1.conf / leaf2.conf
│   │   └── start_frr.sh
│   ├── qos/
│   │   ├── apply_qos_tc.sh                       # tc multi-queue PRIO, RED/ECN marking, TBF pacing
│   │   ├── clear_qos.sh
│   │   └── monitor_queues.sh                     # High-frequency queue inspection (tc -s qdisc)
│   ├── traffic/
│   │   ├── rocev2_generator.py                   # Scapy RoCEv2 (UDP 4791, DSCP EF/CS6, BTH/RDMA)
│   │   └── incast_microburst.py                  # Synthetic N-to-1 GPU All-Reduce incast burst
│   └── docs/
│       └── software_vs_asic_buffer_memo.md      # Comprehensive Linux tc vs Cisco Cloud Scale/Silicon One Memo
│
├── lab2_netdevops_cicd_pipeline/                 # Lab 2: NetDevOps CI/CD Pipeline & Containerized Testing
│   ├── .github/workflows/netdevops_ci.yml        # Production GitHub Actions CI/CD Pipeline
│   ├── topology/docker-compose.yml               # Lightweight Alpine/FRR virtual network testbed
│   ├── tests/
│   │   ├── test_bgp_convergence.py               # Pytest asserting BGP neighbor states and prefix counts
│   │   ├── test_interface_counters.py            # Assert zero packet drops / CRC errors
│   │   └── test_acl_security_drift.py            # Automated ACL and route drift assertions
│   ├── automation/
│   │   ├── snapshot_engine.py                    # Scrapli/Netmiko state extraction engine
│   │   └── drift_remediator.py                   # Automated drift remediation bot
│   └── requirements.txt
│
├── lab3_siem_security_ai_workloads/              # Lab 3: Open-Source SIEM & Security Pipeline for AI Workloads
│   ├── docker-compose.yml                        # Wazuh Single-Node + OpenSearch + Zeek + Suricata
│   ├── rules/
│   │   ├── rogue_llm_exfiltration.xml            # Custom Wazuh detection rules for LLM data theft
│   │   └── prompt_injection_suricata.rules       # Suricata network flow detection rules
│   ├── parsers/zeek_llm_traffic.zeek             # Zeek script parsing HTTP/REST AI inference endpoints
│   ├── attack_simulation/
│   │   └── simulate_llm_exfiltration.py          # Synthetic prompt injection & bulk token exfiltration
│   └── docs/incident_post_mortem.md
│
├── lab4_hybrid_cloud_assurance_telemetry/        # Lab 4: Hybrid Cloud Assurance & Synthetic Path Telemetry
│   ├── docker-compose.yml                        # Prometheus + Blackbox Exporter + Grafana
│   ├── configs/
│   │   ├── prometheus.yml                        # High-frequency scraping & alert evaluations
│   │   ├── blackbox.yml                          # Multi-layer probes: HTTP/S, TCP handshake, DNS, ICMP
│   │   └── alertmanager_rules.yml                # Dynamic latency jitter & packet loss SLO alerts
│   ├── dashboards/
│   │   └── path_assurance_dashboard.json         # Production Grafana Path Assurance Dashboard JSON
│   ├── fault_injection/
│   │   └── inject_path_degradation.sh            # Linux tc netem hop-by-hop jitter/loss injection
│   └── docs/root_cause_analysis_memo.md
│
├── lab5_zero_trust_rag_security_audit/           # Lab 5: Zero-Trust AI Retrieval-Augmented Generation (RAG) Security Audit
│   ├── app/
│   │   ├── rag_pipeline.py                       # Hardened Python RAG engine with chunk-level RBAC
│   │   └── security_middleware.py                # Input sanitization, token limits & vector tenant isolation
│   ├── docker-compose.yml                        # Qdrant Rust Vector DB + RAG Container
│   ├── audit_suite/
│   │   ├── test_rbac_vector_isolation.py         # Pytest validating multi-tenant vector chunk boundary
│   │   ├── test_prompt_injection_evasion.py      # Automated adversarial input injection tests
│   │   └── run_security_scanners.sh              # Trivy container scanner + Bandit SAST execution
│   └── docs/executive_risk_assessment.md
│
├── lab6_streaming_telemetry_queue_monitor/       # Lab 6: Streaming Telemetry & Switch Queue Monitoring Stack
│   ├── docker-compose.yml                        # Telegraf + InfluxDB 2.x + Grafana (TIG Stack)
│   ├── configs/
│   │   ├── telegraf.conf                         # Sub-second Linux kernel queue / netstat push collector
│   │   └── influxdb_retention.sh                 # Low-memory retention & downsampling policies
│   ├── dashboards/
│   │   └── queue_telemetry_dashboard.json        # High-frequency queue depth & microburst Grafana visualizer
│   └── traffic/
│       └── burst_generator.py                    # High-intensity microburst generator triggering sub-second spikes
│
└── docs/                                         # Unified Strategic Engineering Documentation
    ├── 01_vendor_equivalent_mapping.md           # Cisco Proprietary vs ₹0 Open-Source Technical Mapping
    ├── 02_m1_macbook_memory_hardware_strategy.md # M1 8-GB Memory Budgeting & Sequential Execution Rules
    ├── 03_workstation_architecture_container_policy.md # Workstation Layering & cgroups Resource Policies
    ├── 04_strategic_execution_roadmap_weeks_1_12.md    # 12-Week Strategic Roadmap & Certifications Mapping
    ├── 05_unified_enterprise_ai_ops_platform.md  # Unified 6-Tier Architecture Capstone
    └── 06_senior_interview_scripts_resume_positioning.md # Executive Interview Talking Tracks & Resume Bullets
```

---

## ⚡ Quick Start Matrix (Sequential Execution)

Run each lab individually within its memory envelope, then clean up before switching labs:

| Lab | Name | Active RAM | Start Command | Clean Command |
| :--- | :--- | :--- | :--- | :--- |
| **Lab 1** | Lossless AI Fabric & Queue Mechanics | ~600 MB | `make lab1` | `make clean-lab1` |
| **Lab 2** | NetDevOps CI/CD Testing Pipeline | ~800 MB | `make lab2` | `make clean-lab2` |
| **Lab 3** | Open-Source SIEM & Threat Detection | ~1.8 GB | `make lab3` | `make clean-lab3` |
| **Lab 4** | Hybrid Cloud Assurance Telemetry | ~700 MB | `make lab4` | `make clean-lab4` |
| **Lab 5** | Zero Trust AI RAG Security Audit | ~1.2 GB | `make lab5` | `make clean-lab5` |
| **Lab 6** | Streaming Telemetry & Queue Monitor | ~900 MB | `make lab6` | `make clean-lab6` |
