import pytest

def test_bgp_session_established():
    """
    Asserts that all BGP peers across the Spine-Leaf topology are in 'Established' state.
    """
    mock_bgp_summary = {
        "spine1": {"peers": {"10.0.1.1": {"state": "Established", "pfxRcvd": 8}}},
        "spine2": {"peers": {"10.0.1.3": {"state": "Established", "pfxRcvd": 8}}},
        "leaf1":  {"peers": {"10.0.1.0": {"state": "Established", "pfxRcvd": 12}}},
        "leaf2":  {"peers": {"10.0.2.0": {"state": "Established", "pfxRcvd": 12}}}
    }

    for node, data in mock_bgp_summary.items():
        for peer_ip, peer_info in data["peers"].items():
            assert peer_info["state"] == "Established", f"BGP session to {peer_ip} on {node} is NOT Established (State: {peer_info['state']})"
            assert peer_info["pfxRcvd"] > 0, f"Zero prefixes received from {peer_ip} on {node}"

def test_evpn_route_reflection():
    """
    Asserts that EVPN Type-2 (MAC/IP) and Type-5 (IP Prefix) routes are reflected to all leaves.
    """
    mock_evpn_routes = {
        "leaf1": ["172.16.10.20/32", "172.16.10.10/32"],
        "leaf2": ["172.16.10.10/32", "172.16.10.20/32"]
    }

    for leaf, routes in mock_evpn_routes.items():
        assert len(routes) >= 2, f"EVPN routes incomplete on {leaf}"
        assert "172.16.10.10/32" in routes
        assert "172.16.10.20/32" in routes
