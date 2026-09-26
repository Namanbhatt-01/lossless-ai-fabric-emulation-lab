#!/usr/bin/env python3
"""
Synthetic RoCEv2 (RDMA over Converged Ethernet v2) Traffic Generator
Layer 3: IPv4 with DSCP 46 (EF) & ECN ECT(0) (0b10) -> TOS 0xbA
Layer 4: UDP Destination Port 4791
Layer 5: RoCEv2 BTH (Base Transport Header) + RDMA Payload
"""

import argparse
import socket
import struct
import time

def build_rocev2_payload(qpn=0x123456, psn=0x000001, payload_len=1024):
    # RoCEv2 Base Transport Header (BTH) - 12 bytes
    bth_opcode = 0x0A # RC RDMA WRITE ONLY
    bth_flags_pkey = 0x00FFFF
    bth_qpn = qpn & 0xFFFFFF
    bth_psn = (0x80 << 24) | (psn & 0xFFFFFF)
    
    bth_header = struct.pack(">BHII", bth_opcode, bth_flags_pkey, bth_qpn, bth_psn)[1:]
    payload = b"ROCEV2_SYNTHETIC_GPU_TENSOR_DATA_" + b"X" * (payload_len - 32)
    icrc = struct.pack(">I", 0xDEADBEEF)
    return bth_header + payload + icrc

def main():
    parser = argparse.ArgumentParser(description="Synthetic RoCEv2 Traffic Generator")
    parser.add_argument("--dst", default="172.16.2.20", help="Destination IP")
    parser.add_argument("--port", type=int, default=4791, help="Destination UDP Port")
    parser.add_argument("--dscp", type=int, default=46, help="DSCP value (46 EF)")
    parser.add_argument("--ecn", type=int, default=2, help="ECN bits: 2=ECT(0)")
    parser.add_argument("--count", type=int, default=1000, help="Packet count")
    parser.add_argument("--delay", type=float, default=0.001, help="Inter-packet delay")
    args = parser.parse_args()

    tos_val = (args.dscp << 2) | (args.ecn & 0x03) # 0xBA = (46 << 2) | 2

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_TOS, tos_val)

    payload = build_rocev2_payload()
    print(f"[*] Sending {args.count} RoCEv2 packets to {args.dst}:{args.port} with TOS=0x{tos_val:02X} (DSCP={args.dscp}, ECN={args.ecn})...")

    for i in range(args.count):
        sock.sendto(payload, (args.dst, args.port))
        if args.delay > 0:
            time.sleep(args.delay)

    sock.close()
    print("[+] Transmission complete.")

if __name__ == "__main__":
    main()
