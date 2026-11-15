#!/bin/bash
# Start OpenRig full screen on the Pi's own display, with audio via JACK.

CARD="USB"                      # audio interface name as shown by: aplay -l
APP_DIR="$(cd "$(dirname "$0")" && pwd)"

# Use the Pi's screen, not a display forwarded over SSH
unset DISPLAY WAYLAND_DISPLAY

# Start JACK unless it is already running
STARTED_JACK=0
if ! pgrep -x jackd > /dev/null; then
    jackd -d alsa -d "hw:$CARD" -r 48000 -p 128 -n 2 > /tmp/jackd.log 2>&1 &
    STARTED_JACK=1
    sleep 2
    if ! pgrep -x jackd > /dev/null; then
        echo "JACK failed to start, continuing without audio. See /tmp/jackd.log"
        STARTED_JACK=0
    fi
fi

cd "$APP_DIR" || exit 1
./target/release/pedalboard

# Stop JACK again if this script started it
if [ "$STARTED_JACK" = "1" ]; then
    pkill -x jackd
fi
