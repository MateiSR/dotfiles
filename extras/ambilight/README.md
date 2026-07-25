# Ambilight: HyperHDR to Govee

Screen-driven ambient lighting on Hyprland. HyperHDR captures the screen through
the PipeWire portal, averages it down to a handful of segments, and emits them as
UDP Raw. `goove_hyperhdr_bridge.py` translates that stream into the Govee LAN
API's Razer/DreamView packets.

Nothing here is installed by `install.sh` or linked by stow. `extras` is listed
in `.stow-local-ignore`. Set it up by hand on machines that have the hardware.

Hardware this was built against: a Govee strip supporting Razer/DreamView at a
static LAN address, 10 segments.

## Install

```sh
paru -S hyperhdr-git

cp extras/ambilight/goove_hyperhdr_bridge.py ~/Scripts/
chmod +x ~/Scripts/goove_hyperhdr_bridge.py
~/Scripts/goove_hyperhdr_bridge.py --selftest

cp -r extras/ambilight/systemd/. ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable govee-bridge.service
```

`govee-bridge.service` runs the script from `%h/Scripts/`. Put it somewhere else
and the unit needs its `ExecStart` updated to match.

Add the autostart line to `~/.config/dotfiles/machine.lua`:

```lua
autostart = {
    "systemctl --user start hyperhdr.service",
},
```

Do not `systemctl --user enable hyperhdr.service`. The packaged unit is
`WantedBy=default.target`, so enabling it starts HyperHDR at login before
Hyprland has exported `WAYLAND_DISPLAY` into the systemd user environment; its
`ExecStartPre` then fails and it retries every 10 seconds forever. Starting it
from `machine.lua` autostart runs it once the session environment exists.

`govee-bridge.service` is `enabled` and pulls itself in through
`hyperhdr.service.wants/`. Never start it directly — it is `BindsTo=` HyperHDR
and systemd stops it immediately if HyperHDR is not active.

## Configure

Set the device address if DHCP moved it, either by editing the constant or with
the environment override:

```sh
systemctl --user edit govee-bridge.service   # Environment=GOVEE_IP=192.168.1.36
```

In the HyperHDR web UI at `http://localhost:8090` (enable Advanced, top right):

- LED hardware: **UDP Raw**, host `127.0.0.1`, port `5569`, RGB order, LED count
  matching `PIXELS` in the script (10).
- Capturing: the PipeWire/Portal software grabber. Confirm the log shows
  `Using DmaBuf frame type. The hardware acceleration is ENABLED.` — without it,
  HyperHDR falls back to CPU framebuffer readback, which is expensive.
- Image processing: all brightness and dimming belongs here. The bridge sets the
  Govee's hardware brightness to 100 once at startup and leaves it alone.

The `--desktop --pipewire` flags come from `systemd/hyperhdr.service.d/override.conf`.
The packaged unit runs bare `hyperhdr`, which picks the wrong grabber on Wayland.

## Verify

```sh
systemctl --user is-active hyperhdr.service govee-bridge.service
journalctl --user -u govee-bridge.service -f
```

The bridge only logs startup and grabber bounces. Its own throughput was never
the useful number — it reads healthy through every failure mode below. Read
HyperHDR's log instead; `[LED0: FPS = 30.30, send = 1818, dropped = 0]` is
healthy, a `send` near 59 is a dead capture:

```sh
journalctl --user -u hyperhdr.service -f | grep PERFORMANCE
```

To see the raw stream, stop the bridge and take the port yourself:

```sh
systemctl --user stop govee-bridge.service
python3 -c 'import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.bind(("127.0.0.1", 5569))
for _ in range(20): print(s.recvfrom(2048)[0].hex())'
systemctl --user start govee-bridge.service
```

HyperHDR emits identical frames several times per refresh, so the bridge drops
byte-identical repeats and caps the rest at 40 FPS (`GOVEE_FPS`). Govee's Razer
mode has no backpressure — it accepts everything and lags rather than erroring —
so the cap matters. LedFx uses 40 for the same devices.

## Gotchas

**The strip silently leaves Razer mode.** After a few hours it freezes on a dim
solid colour. Everything upstream looks perfect — HyperHDR still grabs at 30 FPS
with no drops, the device still pings — because Razer LED data is
fire-and-forget UDP and a device that has left the mode accepts and discards it
without an error. The strip just keeps whatever scene it fell back to. The
trigger is device-side (Wi-Fi reconnect, Govee app or cloud activity, firmware
session expiry) and there is no way to observe it: the device answers `devStatus`
and multicast discovery on UDP 4002, which firewalld drops. The bridge re-sends
the activate command every `REARM` (30) seconds to cover it. Only that command —
`turn` and `brightness` are normal-mode commands and the device leaves the stream
to apply them, dipping the strip for a second or two. To recover by hand:

```sh
python3 -c 'import socket, json
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.sendto(json.dumps({"msg":{"cmd":"razer","data":{"pt":"uwABsQEK"}}}).encode(), ("192.168.1.36", 4003))'
```

**A boot effect with `duration_ms: 0` locks the whole thing up.** Zero means
infinite, not off. Foreground effects hold priority 0, the highest, so the effect
never releases and permanently outranks the grabber — including the web UI you
would use to undo it. Recovery is editing the settings database directly with
HyperHDR stopped, so it cannot overwrite the change on exit:

```sh
systemctl --user stop hyperhdr.service
cp ~/.config/HyperHDR/db/hyperhdr.db ~/.config/HyperHDR/db/hyperhdr.db.bak
python3 - <<'EOF'
import sqlite3, json
db = "/home/matei/.config/HyperHDR/db/hyperhdr.db"
c = sqlite3.connect(db)
row = c.execute("select rowid, config from settings where type='foregroundEffect'").fetchone()
cfg = json.loads(row[1])
cfg.update({"duration_ms": 3000, "effect": "Rainbow swirl fast"})
c.execute("update settings set config=? where rowid=?", (json.dumps(cfg, sort_keys=True), row[0]))
c.commit()
EOF
systemctl --user start hyperhdr.service
```

**Do not use a Music effect as the boot effect.** It depends on an audio capture
device being selected; without one it renders black while still holding priority
0, which looks identical to a hang.

**HyperHDR is single-instance.** A copy started by hand outside systemd holds the
lock and the unit fails with `The HyperHDR Daemon is already running, abort start`
in a restart loop. Kill the stray process before starting the service.

**Brightness stacks multiplicatively.** The Govee's own brightness (the
`BRIGHTNESS` constant, sent once at startup) and HyperHDR's brightness adjustment
compound. The device constant is at 100 so HyperHDR owns dimming — it can be
changed live and its pipeline dithers, whereas dimming in the RGB domain crushes
colour depth. Do not dim in both.

**The capture goes stale after a few hours and the strip freezes on one colour.**
HyperHDR counts the repeated buffers as captured frames, so its grabber FPS looks
perfect; the LED line gives it away, reading `send = 59, dropped = 1769` where a
healthy one reads `send = 1818, dropped = 0`. Restarting HyperHDR clears it and
misleads, because that restarts the bridge too. Toggling the grabber component
renegotiates the stream in about a second and is enough:

```sh
for s in false true; do
  curl -s -X POST http://127.0.0.1:8090/json-rpc -H 'Content-Type: application/json' \
    -d "{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"SYSTEMGRABBER\",\"state\":$s}}"
  sleep 1
done
```

The bridge does this itself after `STALE` (60) seconds of byte-identical frames.
A genuinely static screen trips it too, harmlessly: the colours are unchanged
either way, so the renegotiation is invisible. Upstream is
[xdg-desktop-portal-hyprland#131](https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/131).
The same stream also stalls when an application goes fullscreen or a screensaver
activates — use borderless fullscreen for games, and enable HyperHDR's "disable
on OS lock or monitor off" so PipeWire keeps the saved session token instead of
forcing a monitor re-selection.

## Music mode

HyperHDR's audio visualiser is a normal effect, so switching modes is the
priority muxer, not a setting: starting the effect outranks the grabber, and
clearing it lets the grabber resume. Both live on the Remote Control page.

It needs an audio capture device selected first. HyperHDR enumerates through
PulseAudio, so PipeWire monitor sources appear in the dropdown — pick the monitor
matching the sink actually in use:

```sh
pactl get-default-sink
pactl list short sources | grep monitor
```

Ten segments makes for a coarse spectrum. LedFx has a native Govee device and is
better suited to audio-reactive work; it drives the strip directly with no bridge
involved. Only one of them can hold Razer mode, so stop `govee-bridge.service`
first.
