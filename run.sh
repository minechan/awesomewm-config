#!/usr/bin/env zsh
Xephyr -br -ac -noreset -screen 1366x768 -dpi 96 :1 &
sleep 0.1
DISPLAY=:1 awesome --config rc.lua &
