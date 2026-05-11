#!/bin/bash

LAYOUT=$(hyprctl -j getoption general:layout | jq '.str' | sed 's/"//g')

case $LAYOUT in
"master")
	hyprctl eval 'hl.config({ general = { layout = "dwindle" } })' >/dev/null
	hyprctl keyword unbind SUPER,J
	hyprctl keyword unbind SUPER,K
	hyprctl keyword bind SUPER,J,cyclenext
	hyprctl keyword bind SUPER,K,cyclenext,prev
	hyprctl keyword bind SUPER,O,togglesplit
  notify-send "Dwindle Layout" && sleep 0.5 && swaync-client --close-latest
	;;
"dwindle")
	hyprctl eval 'hl.config({ general = { layout = "master" } })' >/dev/null
	hyprctl keyword unbind SUPER,J
	hyprctl keyword unbind SUPER,K
	hyprctl keyword unbind SUPER,O
	hyprctl keyword bind SUPER,J,layoutmsg,cyclenext
	hyprctl keyword bind SUPER,K,layoutmsg,cycleprev
  notify-send "Master Layout" && sleep 0.5 && swaync-client --close-latest
	;;
*) ;;

esac
