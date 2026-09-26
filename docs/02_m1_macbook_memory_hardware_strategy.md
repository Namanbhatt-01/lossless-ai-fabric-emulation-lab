# SECTION 6: ₹0 / M1 8-GB Memory & Hardware Strategy Matrix
### Sequential Execution Rules & Apple Silicon (ARM64) Optimization

This matrix dictates the resource allocation and lifecycle boundaries ensuring all lab scenarios run smoothly on an **Apple Silicon M1 MacBook Air with 8 GB unified memory**, completely free of cost and without swap thrashing.

---

| Lab Project | Primary Runtime Stack | Active Memory Budget (M1 8-GB) | Host Footprint / Storage | Sequential Execution Rule | Zero-Cost & Free-Tier Mechanism | macOS Apple Silicon (ARM64) Optimization |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Lab 1: Lossless Fabric & Queue Mechanics** | FRR container + Linux network namespaces + `tc` | ~500 MB – 1.0 GB RAM | ~2 GB Disk (Alpine / Debian images) | Run isolated; tear down containerlab / namespace topology before launching next lab | 100% Free & Open Source (FRRouting OSS, Linux Kernel networking tools) | Native ARM64 Docker images for FRR and Alpine; zero Rosetta emulation overhead |
| **Lab 2: NetDevOps CI/CD Testing Pipeline** | Python 3.11 virtualenv + lightweight Docker runner | ~800 MB – 1.2 GB RAM | ~1.5 GB Disk (Python wheels + runner cache) | Execute pytest suite locally or in GitHub Actions free public runner (2,000 min/mo) | 100% Free (GitHub Actions free tier + open-source pytest / Scrapli) | Native macOS Python 3.11 ARM64 build; lightning-fast execution without VM overhead |
| **Lab 3: Open-Source SIEM & Security Pipeline** | Wazuh Manager / OpenSearch (Single-Node Dev Profile) | ~1.5 GB – 2.0 GB RAM (JVM capped at 1 GB) | ~5 GB Disk (Docker volumes) | Allocate 2.0 GB memory cap in `docker-compose.yml`; run alone, stop stack after log verification | 100% Free (Wazuh Community Edition + OpenSearch OSS) | Use ARM64 Docker images; adjust JVM heap `-Xms512m -Xmx1024m` to fit comfortably in 8 GB |
| **Lab 4: Hybrid Cloud Assurance & Synthetic Probing** | Prometheus + Blackbox Exporter + Grafana | ~600 MB – 1.0 GB RAM | ~2 GB Disk (TSDB retention set to 3 days) | Can run concurrently with host workloads; very lightweight resource profile | 100% Free (Prometheus OSS, Grafana OSS, Public AI inference APIs free tiers) | All components have official high-efficiency Apple Silicon ARM64 container builds |
| **Lab 5: Zero Trust AI RAG Security Audit** | Qdrant (Rust OSS) + Python RAG script + Bandit/Trivy | ~1.0 GB – 1.5 GB RAM | ~3 GB Disk (Local vector DB storage) | Run RAG ingestion and security assertion tests; stop containers upon test completion | 100% Free (Qdrant OSS, HuggingFace free embeddings, open-source scanners) | Qdrant compiled in native Rust ARM64 delivers ultra-low RAM footprint compared to heavy alternatives |
| **Lab 6: Streaming Telemetry & Queue Monitoring** | Telegraf + InfluxDB 2.x (OSS) + Grafana | ~800 MB – 1.2 GB RAM | ~2.5 GB Disk (Time-series data volume) | Run independently for queue burst simulation; aggregate data exports to JSON/CSV for persistent records | 100% Free (InfluxData OSS, Grafana Community Edition) | Native ARM64 binaries for Telegraf and InfluxDB; optimized memory usage with low flush buffers |

---

### Global Sequential Strategy Rule
1. **Never run multiple memory-intensive labs simultaneously** on an 8 GB workstation.
2. **Execute standardized teardowns** (`make clean-labX`) immediately following telemetry collection and test assertion capture.
3. **Preserve persistent telemetry and logs** as lightweight CSV/JSON/PCAP artifacts for cross-lab correlation.
