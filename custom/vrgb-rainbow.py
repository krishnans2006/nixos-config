#!/usr/bin/env python3
"""Cycle keyboard RGB through the spectrum by calling vrgb in a loop."""

import argparse
import colorsys
import signal
import subprocess
import sys
import time


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--period",
        type=float,
        default=12.0,
        help="Seconds for one full hue cycle (default: 12)",
    )
    parser.add_argument(
        "--brightness",
        type=int,
        default=100,
        help="Brightness percent 0-100 (default: 100)",
    )
    parser.add_argument(
        "--fps",
        type=float,
        default=30.0,
        help="Update rate in frames per second (default: 30)",
    )
    args = parser.parse_args()

    if args.period <= 0:
        print("error: --period must be positive", file=sys.stderr)
        sys.exit(1)
    if not 0 <= args.brightness <= 100:
        print("error: --brightness must be 0-100", file=sys.stderr)
        sys.exit(1)
    if args.fps <= 0:
        print("error: --fps must be positive", file=sys.stderr)
        sys.exit(1)

    stop = False

    def handle_signal(_signum, _frame):
        nonlocal stop
        stop = True

    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)

    frame_delay = 1.0 / args.fps
    t0 = time.monotonic()

    while not stop:
        hue = ((time.monotonic() - t0) % args.period) / args.period
        r, g, b = colorsys.hsv_to_rgb(hue, 1.0, 1.0)
        color = f"{int(r * 255):02x}{int(g * 255):02x}{int(b * 255):02x}"
        subprocess.run(
            ["vrgb", "set", color, str(args.brightness)],
            check=False,
        )
        time.sleep(frame_delay)


if __name__ == "__main__":
    main()
