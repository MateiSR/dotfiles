#!/usr/bin/env python3
"""Bridge HyperHDR's UDP Raw output into a Govee device's Razer/DreamView LAN mode."""

import base64
import json
import os
import signal
import socket
import sys
import time
from typing import Final


GOVEE_IP: Final = os.environ.get("GOVEE_IP", "192.168.1.36")
GOVEE_PORT: Final = 4003

LISTEN_IP: Final = "127.0.0.1"
LISTEN_PORT: Final = 5569

# Must match the LED count configured in HyperHDR's UDP Raw output.
PIXEL_COUNT: Final = 10

# Device brightness stays wide open; do all dimming in HyperHDR, which dithers
# and can be changed live. Dimming in both would multiply.
BRIGHTNESS: Final = 100

# HyperHDR streams at capture rate (often 60 FPS). Govee's Razer mode has no
# backpressure: it accepts everything over Wi-Fi and lags instead of erroring.
# LedFx defaults to 40 for the same devices. Tune down if the strip stutters.
MAX_FPS: Final = int(os.environ.get("GOVEE_FPS", "40"))
MIN_INTERVAL: Final = 1 / MAX_FPS

# Razer mode falls back to the device's previous scene after ~60s without LED
# data, so a static screen still needs a heartbeat.
KEEPALIVE_SECONDS: Final = 5.0

# Packet layout: BB 00 <variant> <command> <mode> [payload...] <xor checksum>
#   variant: 0xFA DreamView, 0x0E Chroma, 0x20 Govee (LedFx's three presets)
#   command: 0xB0 = Razer LED data
#   mode:    0x00 segments, 0x01 stretch
# Wrong colours or a dead strip on a different Govee model: change the variant.
RAZER_HEADER: Final = bytes([0xBB, 0x00, 0xFA, 0xB0, 0x00])

ACTIVATE_PACKET: Final = "uwABsQEK"  # BB 00 01 B1 01 0A
DEACTIVATE_PACKET: Final = "uwABsQAL"  # BB 00 01 B1 00 0B

# A terminal gets a live-updating progress line; under systemd that would be a
# journal entry every 2 seconds forever, so report rarely instead of not at all.
ON_TTY: Final = sys.stdout.isatty()
REPORT_INTERVAL: Final = 2.0 if ON_TTY else 300.0

running = True
send_errors = 0


def stop(_signum: int, _frame: object) -> None:
    global running
    running = False


def xor_checksum(data: bytes) -> int:
    checksum = 0
    for byte in data:
        checksum ^= byte
    return checksum


def send_json(sock: socket.socket, message: dict) -> None:
    global send_errors
    payload = json.dumps(message, separators=(",", ":")).encode()
    try:
        sock.sendto(payload, (GOVEE_IP, GOVEE_PORT))
    except OSError:
        # A Wi-Fi blip or lost route must not kill a long-running bridge.
        send_errors += 1


def set_brightness(sock: socket.socket, brightness: int) -> None:
    send_json(
        sock,
        {
            "msg": {
                "cmd": "brightness",
                "data": {"value": brightness},
            }
        },
    )


def set_power(sock: socket.socket, enabled: bool) -> None:
    send_json(
        sock,
        {
            "msg": {
                "cmd": "turn",
                "data": {"value": int(enabled)},
            }
        },
    )


def send_razer(sock: socket.socket, encoded: str) -> None:
    send_json(
        sock,
        {
            "msg": {
                "cmd": "razer",
                "data": {"pt": encoded},
            }
        },
    )


def make_razer_packet(rgb: bytes) -> str:
    packet = bytearray(RAZER_HEADER)
    packet.append(len(rgb) // 3)
    packet.extend(rgb)
    packet.append(xor_checksum(packet))
    return base64.b64encode(packet).decode()


def selftest() -> None:
    # The known-good activate constant cross-checks the checksum routine.
    activate = base64.b64decode(ACTIVATE_PACKET)
    assert activate == bytes([0xBB, 0x00, 0x01, 0xB1, 0x01, 0x0A]), activate.hex()
    assert xor_checksum(activate[:-1]) == activate[-1]

    deactivate = base64.b64decode(DEACTIVATE_PACKET)
    assert xor_checksum(deactivate[:-1]) == deactivate[-1]

    rgb = bytes(range(3 * PIXEL_COUNT))
    packet = base64.b64decode(make_razer_packet(rgb))
    assert packet[:5] == RAZER_HEADER, packet.hex()
    assert packet[5] == PIXEL_COUNT
    assert packet[6:-1] == rgb
    assert xor_checksum(packet[:-1]) == packet[-1]

    print("selftest ok")


def main() -> int:
    if "--selftest" in sys.argv:
        selftest()
        return 0

    signal.signal(signal.SIGINT, stop)
    signal.signal(signal.SIGTERM, stop)

    expected = PIXEL_COUNT * 3

    receiver = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    receiver.bind((LISTEN_IP, LISTEN_PORT))
    receiver.settimeout(0.5)

    # A socket bound to loopback cannot reach the LAN, so sending needs its own.
    sender = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    set_power(sender, True)
    time.sleep(0.1)
    set_brightness(sender, BRIGHTNESS)
    time.sleep(0.1)
    send_razer(sender, ACTIVATE_PACKET)

    print(
        f"HyperHDR UDP Raw {LISTEN_IP}:{LISTEN_PORT}"
        f" -> Govee {GOVEE_IP}:{GOVEE_PORT}"
    )
    print(f"Expecting {PIXEL_COUNT} pixels / {expected} bytes, capped at {MAX_FPS} FPS")

    frames_in = 0
    frames_out = 0
    report_started = time.monotonic()
    last_data = None
    last_send = 0.0

    try:
        while running:
            try:
                data, _address = receiver.recvfrom(2048)
            except TimeoutError:
                continue

            if len(data) != expected:
                print(
                    f"HyperHDR sent {len(data)} bytes, expected {expected}. "
                    f"Set its LED count to {PIXEL_COUNT}, or change PIXEL_COUNT here.",
                    file=sys.stderr,
                )
                return 1

            frames_in += 1
            now = time.monotonic()

            # Throttle changing frames; resend unchanged ones only to keep
            # Razer mode alive.
            unchanged = data == last_data
            if now - last_send < (KEEPALIVE_SECONDS if unchanged else MIN_INTERVAL):
                continue

            send_razer(sender, make_razer_packet(data))
            frames_out += 1
            last_data = data
            last_send = now

            elapsed = now - report_started
            if elapsed >= REPORT_INTERVAL:
                line = (
                    f"in {frames_in / elapsed:5.1f} FPS"
                    f"  out {frames_out / elapsed:5.1f} FPS"
                    f"  send errors {send_errors}"
                )
                if ON_TTY:
                    print(f"\r{line}", end="", flush=True)
                else:
                    print(line, flush=True)
                frames_in = 0
                frames_out = 0
                report_started = now

    finally:
        print("\nStopping")

        # Blank first, or the device flashes back to its previous scene.
        send_razer(sender, make_razer_packet(bytes(expected)))
        time.sleep(0.05)
        send_razer(sender, DEACTIVATE_PACKET)
        time.sleep(0.05)
        set_power(sender, False)

        receiver.close()
        sender.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
