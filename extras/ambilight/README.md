# Ambilight: HyperHDR to Govee

HyperHDR captures the screen through the PipeWire portal and emits it as UDP Raw.
`goove_hyperhdr_bridge.py` translates that into Govee LAN Razer/DreamView packets.

Not installed by `install.sh`, not stowed (`extras` is in `.stow-local-ignore`).
Set up by hand on machines with the hardware: a Govee strip supporting
Razer/DreamView at a static LAN address, 10 segments.

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

`ExecStart` points at `%h/Scripts/`; update it if the script lives elsewhere.

Autostart in `~/.config/dotfiles/machine.lua`:

```lua
autostart = {
    "systemctl --user start hyperhdr.service",
},
```

Do not `enable` hyperhdr.service. The packaged unit is `WantedBy=default.target`,
so it starts before Hyprland exports `WAYLAND_DISPLAY` into the systemd user
environment; `ExecStartPre` then fails and it retries every 10s forever.

Never start `govee-bridge.service` directly either — it is `BindsTo=` HyperHDR
and pulls itself in through `hyperhdr.service.wants/`.

## Configure

```sh
systemctl --user edit govee-bridge.service   # Environment=GOVEE_IP=192.168.1.36
```

In the web UI at `http://localhost:8090` (enable Advanced, top right):

- LED hardware: **UDP Raw**, `127.0.0.1:5569`, RGB order, LED count = `PIXELS` (10).
- Capturing: PipeWire/Portal grabber. The log must show `Using DmaBuf frame type`
  — without it HyperHDR falls back to CPU framebuffer readback.
- Image processing: all dimming belongs here. The bridge sets hardware brightness
  to 100 once and leaves it alone.

`--desktop --pipewire` come from `systemd/hyperhdr.service.d/override.conf`; the
packaged unit runs bare `hyperhdr`, which picks the wrong grabber on Wayland.

## Verify

```sh
systemctl --user is-active hyperhdr.service govee-bridge.service
journalctl --user -u hyperhdr.service -f | grep PERFORMANCE
```

`[LED0: FPS = 30.30, send = 1818, dropped = 0]` is healthy; `send = 59,
dropped = 1769` is a dead capture. The bridge's own log is useless for this — it
reads healthy through every failure mode below, and only logs bounces.

To see the raw stream, take the port yourself:

```sh
systemctl --user stop govee-bridge.service
python3 -c 'import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.bind(("127.0.0.1", 5569))
for _ in range(20): print(s.recvfrom(2048)[0].hex())'
systemctl --user start govee-bridge.service
```

HyperHDR repeats identical frames, so the bridge drops byte-identical repeats and
caps the rest at 40 FPS (`GOVEE_FPS`). Razer mode has no backpressure — it accepts
everything and lags rather than erroring — so the cap matters. LedFx uses 40 too.

## Gotchas

**The strip silently leaves Razer mode.** After a few hours it freezes on a dim
solid colour. Nothing upstream looks wrong, because Razer LED data is
fire-and-forget UDP: a device that left the mode accepts and discards it. The
trigger is device-side (Wi-Fi reconnect, Govee app or cloud activity, firmware
session expiry) and unobservable — `devStatus` and discovery answer on UDP 4002,
which firewalld drops. The bridge re-sends activate every `REARM` (30) seconds.
Only that command: `turn` and `brightness` are normal-mode commands and the
device leaves the stream to apply them, dipping the strip for a second or two.
By hand:

```sh
python3 -c 'import socket, json
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.sendto(json.dumps({"msg":{"cmd":"razer","data":{"pt":"uwABsQEK"}}}).encode(), ("192.168.1.36", 4003))'
```

**A boot effect with `duration_ms: 0` locks everything up.** Zero means infinite.
Foreground effects hold priority 0 and permanently outrank the grabber, including
the web UI you would use to undo it. Edit the database with HyperHDR stopped, so
it cannot overwrite the change on exit:

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

**No Music effect as the boot effect.** It needs an audio capture device selected;
without one it renders black while still holding priority 0 — identical to a hang.

**HyperHDR is single-instance.** A copy started by hand holds the lock and the
unit fails with `The HyperHDR Daemon is already running, abort start` in a restart
loop. Kill the stray process first.

**Brightness stacks multiplicatively.** The Govee's own brightness and HyperHDR's
compound. The device constant stays at 100 so HyperHDR owns dimming — it dithers,
whereas dimming in the RGB domain crushes colour depth. Do not dim in both.

**The capture goes stale and the strip freezes on one colour.** HyperHDR counts
repeated buffers as captured frames, so grabber FPS looks perfect and only the LED
line gives it away. Toggling the grabber renegotiates the stream in about a
second, where restarting HyperHDR also restarts the bridge and misleads:

```sh
for s in false true; do
  curl -s -X POST http://127.0.0.1:8090/json-rpc -H 'Content-Type: application/json' \
    -d "{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"SYSTEMGRABBER\",\"state\":$s}}"
  sleep 1
done
```

The bridge does this after `STALE` (60) seconds of byte-identical frames. A static
screen trips it too and nothing distinguishes the two — HyperHDR drops repeated
frames exactly as the bridge does. So the bounce is made harmless rather than
rare: HyperHDR blanks the LEDs while the grabber is down, and the bridge discards
that blank frame and the backlog behind it, holding its last colour. Upstream is
[xdg-desktop-portal-hyprland#131](https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/131).
The stream also stalls on fullscreen and screensavers — use borderless fullscreen
for games, and enable "disable on OS lock or monitor off" so PipeWire keeps the
session token instead of forcing a monitor re-selection.

**The bounce itself wedges the portal eventually.** One renegotiation never
completes: HyperHDR logs `SelectSources finished` and stops, the portal logs
nothing for that session, the grabber sits `enabled` producing nothing, and
HyperHDR powers its LED device off (`COMPONENTCTRL0: LED device: disabled`). So
the stream stops instead of repeating, which a stale check reading only arriving
frames cannot see. Only a fresh process clears it. The bridge treats `SILENT` (90)
seconds without a datagram as the escalation and restarts `hyperhdr.service`,
taking itself down and back up with it. An idle desktop still sends frames, so the
static-screen ambiguity never reaches this path.

**An effect holds the LEDs static, and that is not a stale capture.** Any effect
outranks the grabber — Cinema dim lights is a solid amber for as long as it runs,
so every frame is byte-identical and the bounce fired every minute for as long as
the film lasted. Hundreds of portal sessions in an evening; each one can pop a
picker, and a stream sharing a window at the time is collateral. So the bridge
asks who owns the LEDs before repairing anything, and stays quiet unless it is
the grabber:

```sh
curl -s -X POST http://127.0.0.1:8090/json-rpc -H 'Content-Type: application/json' \
  -d '{"command":"serverinfo"}' | jq '.info.priorities[] | select(.visible)'
```

`"componentId": "EFFECT"` there means the strip is doing what it was told. Clear
it from Remote Control to hand the grabber back.

**A restart re-prompts for the monitor; a bounce does not.** HyperHDR opens two
portal sessions at startup, spends its restore token on the first and destroys it,
so the session that captures has none:

```sh
journalctl --user -u xdg-desktop-portal-hyprland -f | grep -E "prompting|Selection"
```

Answer with the same screen (`DP-2`) and allow the restore token. That makes a
restart an attended repair, so the bridge rations it to one an hour, stamped in
`$XDG_RUNTIME_DIR/govee-bridge.restart` because the restart kills the process
holding the count. Rationed, it keeps bouncing — free and silent — instead of
stacking pickers nobody is awake to click. Re-arm it with:

```sh
rm -f "$XDG_RUNTIME_DIR/govee-bridge.restart"
```

## Music mode

The audio visualiser is a normal effect, so switching modes is the priority muxer,
not a setting: start the effect to outrank the grabber, clear it to resume. Both
on the Remote Control page.

Select an audio capture device first. HyperHDR enumerates through PulseAudio, so
PipeWire monitor sources appear — pick the monitor for the sink in use:

```sh
pactl get-default-sink
pactl list short sources | grep monitor
```

Ten segments is a coarse spectrum. LedFx has a native Govee device and drives the
strip directly with no bridge. Only one can hold Razer mode, so stop
`govee-bridge.service` first.
