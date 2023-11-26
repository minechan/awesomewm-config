#!/usr/bin/env zsh
Xephyr -br -ac -noreset -screen 1920x1200 -dpi 192 :1 &
sleep 0.1
DISPLAY=:1 awesome --config rc.lua &
