#!/usr/bin/env python3
"""Cycle keyboard RGB through the spectrum via in-process HID (vrgb library)."""

import argparse
import colorsys
import fcntl
import os
import signal
import sys
import time

import vrgb


class LampArray:
    """Persistent HID connection for fast per-frame color updates."""

    def __init__(self, brightness: int) -> None:
        self.dev = vrgb.find_device()
        vrgb.set_firmware_mode(self.dev, False)
        self._fd = os.open(self.dev["path"], os.O_RDWR | os.O_CLOEXEC)
        self._intensity = vrgb.percent_to_intensity(brightness)

    def set_rgb(self, r: int, g: int, b: int) -> None:
        payload = bytes(
            [
                0x01,
                0x00,
                0x00,
                0x00,
                0x00,
                vrgb.clamp(r, 0, 255),
                vrgb.clamp(g, 0, 255),
                vrgb.clamp(b, 0, 255),
                self._intensity,
            ]
        )
        buf = bytes([self.dev["color_report_id"]]) + payload
        fcntl.ioctl(self._fd, vrgb.HIDIOCSFEATURE(len(buf)), buf)

    def close(self) -> None:
        os.close(self._fd)


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
        default=6.0,
        help="Update rate in frames per second (default: 6)",
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

    def handle_signal(_signum, _frame) -> None:
        nonlocal stop
        stop = True

    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)

    frame_delay = 1.0 / args.fps
    lamp = LampArray(args.brightness)

    try:
        t0 = time.monotonic()
        next_frame = t0
        while not stop:
            hue = ((time.monotonic() - t0) % args.period) / args.period
            r, g, b = colorsys.hsv_to_rgb(hue, 1.0, 1.0)
            lamp.set_rgb(int(r * 255), int(g * 255), int(b * 255))

            next_frame += frame_delay
            sleep_for = next_frame - time.monotonic()
            if sleep_for > 0:
                time.sleep(sleep_for)
            else:
                next_frame = time.monotonic()
    finally:
        lamp.close()


if __name__ == "__main__":
    main()
