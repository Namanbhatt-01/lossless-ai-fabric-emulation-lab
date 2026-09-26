#!/usr/bin/env python3
"""
Synthetic Multi-Flow GPU All-Reduce Incast Microburst Generator
Generates high-rate synchronized UDP traffic to induce buffer occupancy.
"""

import argparse
import concurrent.futures
import socket
import struct
import time

def send_burst(flow_id, dst_ip, dst_port, dscp, packets_per_burst):
    tos_val = (dscp << 2) | 2 # ECT(0) enabled
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_TOS, tos_val)

    payload = b"MICROBURST_INCAST_ALL_REDUCE_" + struct.pack(">I", flow_id) + b"A" * 1000

    for _ in range(packets_per_burst):
        sock.sendto(payload, (dst_ip, dst_port))

    sock.close()

def main():
    parser = argparse.ArgumentParser(description="Multi-Flow Incast Burst Generator")
    parser.add_argument("--flows", type=int, default=8, help="Concurrent sender flows")
    parser.add_argument("--burst-size", type=int, default=150, help="Packets per burst per flow")
    parser.add_argument("--rounds", type=int, default=10, help="Burst cycles")
    parser.add_argument("--dst", default="172.16.2.20", help="Target receiver IP")
    parser.add_argument("--port", type=int, default=4791, help="Target UDP port")
    args = parser.parse_args()

    print(f"[*] Launching {args.flows} concurrent flows x {args.burst_size} pkts x {args.rounds} rounds to {args.dst}:{args.port}...")

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.flows) as executor:
        for r in range(args.rounds):
            futures = [
                executor.submit(send_burst, f, args.dst, args.port, 46, args.burst_size)
                for f in range(args.flows)
            ]
            concurrent.futures.wait(futures)
            time.sleep(0.05)

    print("[+] Incast microburst generation completed.")

if __name__ == "__main__":
    main()
