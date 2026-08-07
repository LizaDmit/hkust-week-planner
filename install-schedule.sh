#!/bin/bash
# Schedules refresh.sh to run twice a day (07:30 and 19:30) using launchd.
# Works out its own absolute paths, so it doesn't matter where the folder lives.
#
#   ./install-schedule.sh            install or update the schedule
#   ./install-schedule.sh --remove   remove it
#
# launchd catches up on a run that was missed because the Mac was asleep or
# shut down, so you don't lose a refresh overnight.

set -e

LABEL="local.weekplanner.refresh"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

unload() {
  launchctl bootout "gui/$UID/$LABEL" 2>/dev/null || launchctl unload "$PLIST" 2>/dev/null || true
}

if [ "$1" = "--remove" ]; then
  unload
  rm -f "$PLIST"
  echo "schedule removed"
  exit 0
fi

chmod +x "$DIR/refresh.sh"
mkdir -p "$HOME/Library/LaunchAgents" "$DIR/logs"

cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$DIR/refresh.sh</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$DIR</string>
  <key>StartCalendarInterval</key>
  <array>
    <dict><key>Hour</key><integer>7</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Hour</key><integer>19</integer><key>Minute</key><integer>30</integer></dict>
  </array>
  <key>StandardOutPath</key>
  <string>$DIR/logs/launchd.log</string>
  <key>StandardErrorPath</key>
  <string>$DIR/logs/launchd.log</string>
</dict>
</plist>
PLISTEOF

unload
launchctl bootstrap "gui/$UID" "$PLIST" 2>/dev/null || launchctl load "$PLIST"

echo "scheduled: $DIR/refresh.sh at 07:30 and 19:30 daily"
echo "plist:     $PLIST"
echo "logs:      $DIR/logs/refresh.log"
echo
echo "check it registered:  launchctl list | grep weekplanner"
echo "run it now:           ./refresh.sh"
echo "remove:               ./install-schedule.sh --remove"
