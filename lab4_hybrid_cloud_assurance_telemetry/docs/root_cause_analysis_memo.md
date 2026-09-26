# Root Cause Analysis (RCA): Hybrid AI Path Jitter & Packet Loss Incident

**Incident Reference:** RCA-AI-PATH-8831  
**Severity:** P2 (Latency SLO Breach)  
**Target Impacted:** Cloud AI Inference Gateway (`api.openai.com` / `huggingface.co`)  
**Mean-Time-To-Identify (MTTI):** 2.8 minutes  

---

## 1. Summary of Degradation
Synthetic multi-layer probes reported an instantaneous spike in round-trip latency from $28\ \text{ms}$ to $145\ \text{ms}$ accompanied by $5.2\%$ packet loss, violating the $350\ \text{ms}$ P99 SLO threshold.

---

## 2. Hop-by-Hop Telemetry Breakdown
* **Layer 3 / ICMP:** Transit hop 4 exhibited elevated jitter ($+25\ \text{ms}$).
* **Layer 4 / TCP Handshake:** Syn-Ack response increased from $8\ \text{ms}$ to $95\ \text{ms}$.
* **Layer 7 / HTTP TTFB:** Time-To-First-Byte delayed by $135\ \text{ms}$.

---

## 3. Corrective Action & Verification
Automated failover rerouted traffic via secondary underlay spine path, restoring baseline latency to $< 30\ \text{ms}$ within 180 seconds.
