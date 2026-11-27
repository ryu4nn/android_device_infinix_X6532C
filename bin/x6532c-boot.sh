#!/system/bin/sh
# X6532C boot integration.
#
# Runs once per boot from init.rc (sys.boot_completed=1) in the permissive
# phhsu_daemon domain, which is what allows writing the Transsion vendor proc
# nodes without extra sepolicy.
#
# Preference order: /data/local/tmp/x6532c.conf (written by /system/bin/x6532c,
# always writable over adb) then persist.sys.x6532c.* then the build.prop default.
#
# Nothing here is fatal: a missing node is logged and skipped.

TAG=X6532C
CONF=/data/local/tmp/x6532c.conf
PROC_GESTURE=/proc/gesture_function
PROC_GAME=/proc/game_state

say() { log -t "$TAG" "$*"; }

conf_get() {
    [ -f "$CONF" ] || return 0
    sed -n "s/^$1=//p" "$CONF" 2>/dev/null | tail -1
}

pick() { # <conf key> <property> <fallback>
    v="$(conf_get "$1")"
    [ -z "$v" ] && v="$(getprop "$2")"
    [ -z "$v" ] && v="$3"
    echo "$v"
}

say "boot integration start"

dt2w="$(pick dt2w persist.sys.x6532c.dt2w 1)"
game="$(pick game persist.sys.x6532c.game 0)"
fps="$(pick fps persist.sys.x6532c.refresh 0)"

# --- touch: wait for the Transsion adaptive-touch proc interface -------------
i=0
while [ ! -e "$PROC_GESTURE" ] && [ $i -lt 30 ]; do
    sleep 1
    i=$((i + 1))
done

if [ -e "$PROC_GESTURE" ]; then
    if [ "$dt2w" = "0" ]; then
        echo cc0 > "$PROC_GESTURE" 2>/dev/null && say "dt2w: off" \
            || say "dt2w: off FAILED"
    else
        echo cc1 > "$PROC_GESTURE" 2>/dev/null && say "dt2w: on" \
            || say "dt2w: on FAILED"
    fi

    if [ "$game" = "1" ]; then
        if [ -e "$PROC_GAME" ] && echo 1 > "$PROC_GAME" 2>/dev/null; then
            say "touch game mode: on"
        else
            say "touch game mode: requested but unavailable"
        fi
    fi
else
    say "touch: $PROC_GESTURE not present, skipping"
fi

# --- display refresh rate ---------------------------------------------------
# Settings.System.MIN_REFRESH_RATE is honoured by DisplayModeDirector and the
# panel driver exposes real 60 and 90 Hz DRM modes.
case "$fps" in
    60|90)
        settings put system min_refresh_rate "$fps" 2>/dev/null
        settings put system peak_refresh_rate "$fps" 2>/dev/null
        say "refresh rate: ${fps}Hz"
        ;;
    *)
        say "refresh rate: system default"
        ;;
esac

say "boot integration done"
