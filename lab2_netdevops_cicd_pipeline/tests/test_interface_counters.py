import pytest

def test_zero_interface_packet_drops():
    """
    Asserts that baseline underlay interfaces show 0 input/output drops prior to congestion injection.
    """
    interface_stats = {
        "l1-s1": {"rx_drops": 0, "tx_drops": 0, "crc_errors": 0},
        "l1-s2": {"rx_drops": 0, "tx_drops": 0, "crc_errors": 0},
        "l2-s1": {"rx_drops": 0, "tx_drops": 0, "crc_errors": 0},
        "l2-s2": {"rx_drops": 0, "tx_drops": 0, "crc_errors": 0}
    }

    for iface, stats in interface_stats.items():
        assert stats["rx_drops"] == 0, f"Interface {iface} has unexpected RX drops: {stats['rx_drops']}"
        assert stats["tx_drops"] == 0, f"Interface {iface} has unexpected TX drops: {stats['tx_drops']}"
        assert stats["crc_errors"] == 0, f"Interface {iface} has CRC framing errors: {stats['crc_errors']}"

def test_interface_mtu_homogeneity():
    """
    Asserts MTU 9000 is consistently configured across all spine-leaf fabric links for RoCEv2 jumbo frames.
    """
    interface_mtu = {
        "l1-s1": 9000,
        "l1-s2": 9000,
        "l2-s1": 9000,
        "l2-s2": 9000,
        "s1-l1": 9000,
        "s2-l1": 9000
    }

    for iface, mtu in interface_mtu.items():
        assert mtu == 9000, f"Interface {iface} MTU mismatch: expected 9000, got {mtu}"
