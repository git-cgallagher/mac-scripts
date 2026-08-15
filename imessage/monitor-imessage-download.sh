#!/usr/bin/env bash
# monitor-imessage-download.sh
#
# Watches the Messages-in-iCloud full-history download to this Mac
# (after unchecking "Enable Messages in iCloud" -> "Disable This Device")
# and announces when it looks complete.
#
# It polls four signals: total message count, oldest message date,
# chat.db size, and Attachments folder size/file count. The download
# commits in bursts, so completion is declared only after ALL signals
# have been flat for STABLE_POLLS consecutive polls.
#
# Usage:
#   ./monitor-imessage-download.sh
#   INTERVAL=30 STABLE_POLLS=30 ./monitor-imessage-download.sh
#
# Requires Full Disk Access for your terminal app
# (System Settings -> Privacy & Security -> Full Disk Access).

set -u

DB="$HOME/Library/Messages/chat.db"
ATTACH_DIR="$HOME/Library/Messages/Attachments"
INTERVAL="${INTERVAL:-60}"          # seconds between polls
STABLE_POLLS="${STABLE_POLLS:-15}"  # consecutive unchanged polls => complete (15 x 60s = 15 min)

msg_count() { sqlite3 -readonly "$DB" 'SELECT COUNT(*) FROM message;' 2>/dev/null; }
oldest_date() {
  sqlite3 -readonly "$DB" \
    "SELECT date(MIN(date)/1000000000 + 978307200,'unixepoch') FROM message WHERE date > 0;" 2>/dev/null
}
db_kb()     { du -sk "$DB" 2>/dev/null | cut -f1; }
attach_kb() { du -sk "$ATTACH_DIR" 2>/dev/null | cut -f1; }
attach_files() { find "$ATTACH_DIR" -type f 2>/dev/null | wc -l | tr -d ' '; }

per_year_summary() {
  sqlite3 -readonly -column -header "$DB" \
    "SELECT strftime('%Y', datetime(date/1000000000 + 978307200,'unixepoch')) AS year,
            COUNT(*) AS messages
     FROM message WHERE date > 0 GROUP BY year ORDER BY year;" 2>/dev/null
}

notify() {
  # macOS banner + spoken alert; both best-effort
  osascript -e "display notification \"$1\" with title \"iMessage download monitor\"" >/dev/null 2>&1
  say "iMessage download looks complete" >/dev/null 2>&1
}

# --- preflight -------------------------------------------------------------
if [[ ! -e "$DB" ]]; then
  echo "ERROR: $DB not found. Is this the right Mac/user?" >&2
  exit 1
fi

if [[ -z "$(msg_count)" ]]; then
  cat >&2 <<'EOF'
ERROR: could not read chat.db. Almost always this means your terminal app
lacks Full Disk Access. Fix:
  System Settings -> Privacy & Security -> Full Disk Access -> enable your
  terminal (Terminal/iTerm/etc.), then restart the terminal and rerun.
EOF
  exit 1
fi

# Keep the Mac awake while we watch (dies with this script via -w $$)
caffeinate -dims -w $$ >/dev/null 2>&1 &

echo "Polling every ${INTERVAL}s; will declare complete after ${STABLE_POLLS} unchanged polls (~$(( INTERVAL * STABLE_POLLS / 60 )) min flat)."
echo "Signals: message count | oldest message | chat.db KB | attachments KB / files"
echo "---------------------------------------------------------------------------"

streak=0
prev=""
start_ts=$(date +%s)

while true; do
  count=$(msg_count)
  old=$(oldest_date)
  dbsz=$(db_kb)
  atsz=$(attach_kb)
  atn=$(attach_files)
  now="msgs=${count} oldest=${old} db=${dbsz}KB attach=${atsz}KB files=${atn}"

  if [[ "$now" == "$prev" ]]; then
    streak=$(( streak + 1 ))
  else
    streak=0
  fi
  prev="$now"

  printf '%s  %-75s stable %d/%d\n' "$(date '+%H:%M:%S')" "$now" "$streak" "$STABLE_POLLS"

  if (( streak >= STABLE_POLLS )); then
    mins=$(( ( $(date +%s) - start_ts ) / 60 ))
    echo
    echo "=== Looks COMPLETE: no movement in any signal for the last ~$(( INTERVAL * STABLE_POLLS / 60 )) minutes (monitored ${mins} min total). ==="
    echo
    echo "Messages per year (sanity-check that early years are populated):"
    per_year_summary
    echo
    echo "Also confirm Messages -> Settings -> iMessage no longer says 'Downloading messages from iCloud'."
    notify "No movement for $(( INTERVAL * STABLE_POLLS / 60 )) min - history download looks complete. Check per-year summary in terminal."
    exit 0
  fi

  sleep "$INTERVAL"
done
