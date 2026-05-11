#!/bin/bash

LAYOUT=$(hyprctl -j getoption general:layout | jq -r '.str')

case $LAYOUT in
"master")
	hyprctl eval '
		hl.config({ general = { layout = "dwindle" } })
		if _G.static_jk then
			for _, b in ipairs(_G.static_jk) do b:set_enabled(false) end
		end
		if _G.layout_binds then
			for _, b in ipairs(_G.layout_binds) do b:set_enabled(false) end
		end
		_G.layout_binds = {
			hl.bind("SUPER + J", hl.dsp.window.cycle_next()),
			hl.bind("SUPER + K", hl.dsp.window.cycle_next({ prev = true })),
			hl.bind("SUPER + O", hl.dsp.layout("togglesplit")),
		}
	' >/dev/null
	notify-send "Dwindle Layout" && sleep 0.5 && swaync-client --close-latest
	;;
"dwindle")
	hyprctl eval '
		hl.config({ general = { layout = "master" } })
		if _G.static_jk then
			for _, b in ipairs(_G.static_jk) do b:set_enabled(false) end
		end
		if _G.layout_binds then
			for _, b in ipairs(_G.layout_binds) do b:set_enabled(false) end
		end
		_G.layout_binds = {
			hl.bind("SUPER + J", hl.dsp.layout("cyclenext")),
			hl.bind("SUPER + K", hl.dsp.layout("cycleprev")),
		}
	' >/dev/null
	notify-send "Master Layout" && sleep 0.5 && swaync-client --close-latest
	;;
*) ;;

esac
