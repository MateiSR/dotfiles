#!/usr/bin/env python3
"""Bridge HyperHDR's UDP Raw output into a Govee device's Razer/DreamView LAN mode."""

import base64
import json
import os
import signal
import socket
import sys
import time
import urllib.request
from functools import reduce
from operator import xor

GOVEE = (os.environ.get("GOVEE_IP", "192.168.1.36"), 4003)
LISTEN = ("127.0.0.1", 5569)
PIXELS = 10          # must match HyperHDR's UDP Raw LED count
BRIGHTNESS = 100     # dim in HyperHDR, not here: the two multiply
MIN_INTERVAL = 1 / int(os.environ.get("GOVEE_FPS", "40"))
KEEPALIVE = 5.0      # Razer mode expires ~60s after the last LED packet
REARM = 30.0         # and the device drops out on its own, silently, after hours
STALE = 60.0         # identical frames this long means HyperHDR's capture died
HYPERHDR = "http://127.0.0.1:8090/json-rpc"

# BB 00 <variant> B0 <mode> <count> <rgb...> <xor>
# variant: FA DreamView, 0E Chroma, 20 Govee. Wrong colours: try another.
HEADER = bytes([0xBB, 0x00, 0xFA, 0xB0, 0x00])
ACTIVATE = "uwABsQEK"
DEACTIVATE = "uwABsQAL"


def send(sock, cmd, data):
    try:
        sock.sendto(json.dumps({"msg": {"cmd": cmd, "data": data}}).encode(), GOVEE)
    except OSError:
        pass  # ponytail: LEDs, not data. A Wi-Fi blip must not kill the daemon.


def packet(rgb):
    p = bytearray(HEADER)
    p.append(len(rgb) // 3)
    p.extend(rgb)
    p.append(reduce(xor, p))
    return base64.b64encode(p).decode()


def bounce():
    # Renegotiate the capture: the portal repeats one frame forever after a few
    # hours (xdg-desktop-portal-hyprland#131) and HyperHDR counts the repeats.
    print("capture stale, bouncing grabber", flush=True)
    for state in (False, True):
        body = {"command": "componentstate",
                "componentstate": {"component": "SYSTEMGRABBER", "state": state}}
        try:
            urllib.request.urlopen(urllib.request.Request(
                HYPERHDR, json.dumps(body).encode(),
                {"Content-Type": "application/json"}), timeout=5).read()
        except OSError as e:
            return print(f"bounce failed: {e}", flush=True)
        time.sleep(1.0)


def flush(sock):
    sock.setblocking(False)  # drop the blank frame HyperHDR sends on grabber stop
    try:
        while True:
            sock.recv(2048)
    except BlockingIOError:
        sock.settimeout(0.5)


def arm(sock):
    send(sock, "turn", {"value": 1})
    send(sock, "razer", {"pt": ACTIVATE})
    send(sock, "brightness", {"value": BRIGHTNESS})


def selftest():
    known = base64.b64decode(ACTIVATE)
    assert reduce(xor, known[:-1]) == known[-1], known.hex()
    p = base64.b64decode(packet(bytes(range(3 * PIXELS))))
    assert p[:6] == HEADER + bytes([PIXELS]), p.hex()
    assert reduce(xor, p[:-1]) == p[-1], p.hex()

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.bind(("127.0.0.1", 0))
    s.settimeout(0.5)
    for _ in range(5):
        s.sendto(b"x", s.getsockname())
    time.sleep(0.05)
    flush(s)
    try:
        assert not s.recv(8), "flush left datagrams queued"
    except TimeoutError:
        pass
    print("selftest ok")


def main():
    if "--selftest" in sys.argv:
        return selftest()

    for sig in (signal.SIGINT, signal.SIGTERM):
        signal.signal(sig, lambda *_: sys.exit(0))  # unwinds into finally

    rx = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    rx.bind(LISTEN)
    rx.settimeout(0.5)
    # A socket bound to loopback cannot reach the LAN, so sending needs its own.
    tx = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    arm(tx)
    print(f"HyperHDR {LISTEN[0]}:{LISTEN[1]} -> Govee {GOVEE[0]}:{GOVEE[1]}, {PIXELS} pixels")

    last = None
    sent = armed = fresh = time.monotonic()
    try:
        while True:
            try:
                rgb, _ = rx.recvfrom(2048)
            except TimeoutError:
                continue
            if len(rgb) != PIXELS * 3:
                sys.exit(f"HyperHDR sent {len(rgb)} bytes, want {PIXELS * 3}: set its LED count to {PIXELS}")

            now = time.monotonic()
            if now - armed >= REARM:
                send(tx, "razer", {"pt": ACTIVATE})  # only this: turn/brightness dip the strip ~2s
                armed = now
            # Throttle changing frames; resend unchanged ones only as keepalive.
            if rgb != last:
                fresh = now
            elif now - fresh >= STALE:
                bounce()
                flush(rx)
                fresh = time.monotonic()

            if now - sent < (KEEPALIVE if rgb == last else MIN_INTERVAL):
                continue
            send(tx, "razer", {"pt": packet(rgb)})
            last, sent = rgb, now
    finally:
        # Blank first, or the device flashes back to its previous scene.
        send(tx, "razer", {"pt": packet(bytes(PIXELS * 3))})
        send(tx, "razer", {"pt": DEACTIVATE})
        send(tx, "turn", {"value": 0})


if __name__ == "__main__":
    raise SystemExit(main())
