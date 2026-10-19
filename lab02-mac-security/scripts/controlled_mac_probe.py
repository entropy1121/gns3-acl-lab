#!/usr/bin/env python3
"""GNS3 isolated TAP: send exactly 12 low-rate MAC-learning test frames.

No arbitrary interface, count, rate or MAC-prefix knobs by design.
Use only with a verified Cloud connected exclusively to lab TAP/CHR ether3.
"""
import argparse
import sys
import time


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--phase', choices=('before', 'after'), required=True)
    args = parser.parse_args()
    try:
        from scapy.all import Ether, Raw, sendp
    except ImportError:
        print('Install Scapy into an isolated Python venv first.', file=sys.stderr)
        return 2
    group = '00' if args.phase == 'before' else '01'
    for i in range(1, 13):
        src = f'02:AA:BB:CC:{group}:{i:02X}'
        packet = Ether(src=src, dst='ff:ff:ff:ff:ff:ff', type=0x88B5) / Raw(
            load=b'GNS3-MAC-LAB' + b'X' * 40
        )
        sendp(packet, iface='tap-maclab', verbose=False)
        print(f'Sent {src}')
        time.sleep(0.1)
    print('Sent exactly 12 isolated MAC-learning test frames. Inspect CHR FDB now.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
