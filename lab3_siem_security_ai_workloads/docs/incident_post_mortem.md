# Security Incident Post-Mortem: Rogue LLM Exfiltration & Prompt Injection Attempt

**Incident ID:** SEC-2026-AI-0042  
**Severity:** HIGH  
**Detection Time:** 2026-09-27T00:08:15Z  
**Time-to-Detect (TTD):** 4.2 seconds  
**Containment Status:** Isolated / Automated Webhook Dispatched  

---

## 1. Incident Overview
A compute worker (`10.244.0.45`) attempted an adversarial prompt injection payload targeting an internal AI proxy endpoint to bypass guardrails, followed by a high-volume outbound data transfer (`>1.2 MB`) from node `10.244.0.88` towards public LLM endpoints.

---

## 2. Detection Vector & Rule Trigger Analysis
* **Suricata Network Rule (SID: 2000001):** Captured TCP payload containing pattern `"Ignore all previous instructions"`.
* **Wazuh Rule 100101 (Level 12):** Matched JSON syslog entry where `http.response_body_bytes` exceeded 500 KB limit for AI inference requests.
* **OpenSearch Ingestion:** Logs indexed in `< 2` seconds; alert triggered webhook within 5 seconds.

---

## 3. Remediation & Preventive Guardrails
1. **Network Layer:** Configured egress firewall filtering blocking direct TCP outbound connections to non-whitelisted AI endpoints.
2. **Application Layer:** Deployed input sanitization middleware and token rate limiting in Lab 5.
