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

Use HyperHDR as the entry point at login. The bridge is bound to it and starts
through `hyperhdr.service.wants/`.

## Configure

```sh
systemctl --user edit govee-bridge.service   # Environment=GOVEE_IP=192.168.1.36
```

In the web UI at `http://localhost:8090` (enable Advanced, top right):

- LED hardware: **UDP Raw**, `127.0.0.1:5569`, RGB order, LED count = `PIXELS` (10).
- Capturing: PipeWire/Portal grabber. `Using DmaBuf frame type` confirms the
  DMA-BUF path; a fallback frame type is not by itself proof that capture is dead.
- Image processing: all dimming belongs here. The bridge sets hardware brightness
  to 100 once and leaves it alone.

`--desktop --pipewire` come from `systemd/hyperhdr.service.d/override.conf`; the
packaged unit runs bare `hyperhdr`, which picks the wrong grabber on Wayland.

## Verify

```sh
systemctl --user is-active hyperhdr.service govee-bridge.service
journalctl --user -u hyperhdr.service -f | grep PERFORMANCE
```

`[LED0: FPS = 30.30, send = 1818, dropped = 0]` and `send = 59, dropped =
1769` describe different LED output cadences. Either can be normal: these
counters do not measure PipeWire capture health and must not trigger recovery.

To see the raw stream, take the port yourself:

```sh
systemctl --user stop govee-bridge.service
python3 -c 'import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.bind(("127.0.0.1", 5569))
for _ in range(20): print(s.recvfrom(2048)[0].hex())'
systemctl --user start govee-bridge.service
```

The bridge coalesces byte-identical output to its keepalive cadence and caps
changed output at 40 FPS (`GOVEE_FPS`). Razer mode has no backpressure — it
accepts everything and lags rather than erroring — so the cap matters. LedFx
uses 40 too.

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

**Capture recovery is attended.** Identical LED output cannot distinguish a
frozen capture from a static screen, black side bars, unchanged sampled edges, or
an effect. The bridge therefore does not toggle the grabber or restart HyperHDR.

First check which input owns the LEDs:

```sh
curl -s -X POST http://127.0.0.1:8090/json-rpc -H 'Content-Type: application/json' \
  -d '{"command":"serverinfo"}' | jq '.info.priorities[] | select(.visible)'
```

An `EFFECT`, `COLOR`, `IMAGE`, or other visible component means the grabber is not
supposed to control the strip. Clear that input from Remote Control if the
grabber should take over. If `SYSTEMGRABBER` is visible, independently check
whether the screen changes when useful:

```sh
grim -t ppm - | sha256sum
sleep 2
grim -t ppm - | sha256sum
```

Different hashes prove the desktop changed, but identical hashes prove nothing.
If capture still appears frozen, toggle the system grabber only while present to
answer a picker. **Re-enabling it creates a new portal session and may open a
screen-share picker or disturb another active share:**

```sh
for state in false true; do
  curl -s -X POST http://127.0.0.1:8090/json-rpc -H 'Content-Type: application/json' \
    -d "{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"SYSTEMGRABBER\",\"state\":$state}}"
  sleep 1
done
```

If that fails, restart HyperHDR as a final attended step; startup and internal
PipeWire retries can create more sessions and may prompt again:

```sh
systemctl --user restart hyperhdr.service
```

Leave XDPH's `screencopy.allow_token_by_default` at its default (`false`). Setting
it to `true` only pre-ticks the picker's restore-token checkbox; it neither avoids
portal sessions nor guarantees a silent restore. It applies to every application,
and a saved window token may fall back to another window of the same class after
the original window disappears. Choose restoration explicitly in the picker.

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
