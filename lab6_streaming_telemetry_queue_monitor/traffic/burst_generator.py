#!/usr/bin/env python3
"""
High-Intensity Microburst Traffic Generator for Streaming Telemetry
Generates rapid, synchronized microsecond traffic spikes to exercise
sub-second InfluxDB/Telegraf telemetry push collection.
"""

import argparse
import socket
import time

def fire_microburst(target_ip, target_port, burst_packets=5000, packet_size=1024):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    payload = b"Q" * packet_size
    print(f"[*] Firing microburst of {burst_packets} packets ({packet_size} bytes each) to {target_ip}:{target_port}...")
    
    start = time.time()
    for _ in range(burst_packets):
        sock.sendto(payload, (target_ip, target_port))
    duration = time.time() - start
    
    print(f"[+] Microburst delivered in {duration:.4f}s (~{(burst_packets * packet_size * 8) / (duration * 1e6):.2f} Mbps).")
    sock.close()

def main():
    parser = argparse.ArgumentParser(description="Microburst Telemetry Generator")
    parser.add_argument("--target", default="127.0.0.1", help="Target IP")
    parser.add_argument("--port", type=int, default=4791, help="Target Port")
    parser.add_argument("--bursts", type=int, default=5, help="Number of microbursts")
    parser.add_argument("--interval", type=float, default=2.0, help="Interval between bursts (seconds)")
    args = parser.parse_args()

    for i in range(args.bursts):
        print(f"\n--- Burst Cycle {i+1}/{args.bursts} ---")
        fire_microburst(args.target, args.port)
        if i < args.bursts - 1:
            time.sleep(args.interval)

if __name__ == "__main__":
    main()
