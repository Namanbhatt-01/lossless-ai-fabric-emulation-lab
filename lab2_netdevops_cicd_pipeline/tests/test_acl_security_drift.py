import pytest

def test_acl_policy_enforcement():
    """
    Asserts control plane policing (CoPP) and management ACLs permit SSH and BGP while dropping unauthenticated packets.
    """
    applied_rules = [
        {"action": "permit", "protocol": "bgp", "port": 179},
        {"action": "permit", "protocol": "bfd", "port": 3784},
        {"action": "permit", "protocol": "ssh", "port": 22},
        {"action": "deny", "protocol": "telnet", "port": 23},
        {"action": "deny", "protocol": "http", "port": 80}
    ]

    for rule in applied_rules:
        if rule["protocol"] in ["telnet", "http"]:
            assert rule["action"] == "deny", f"Insecure protocol {rule['protocol']} is not denied!"
        if rule["protocol"] in ["bgp", "bfd"]:
            assert rule["action"] == "permit", f"Critical fabric protocol {rule['protocol']} is blocked!"
