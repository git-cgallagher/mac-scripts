#!/usr/bin/env bash
# Tighten (or reset) the gap between menu bar icons so more of them fit beside
# the notch. Shows the current values, asks for new ones, writes them to the
# per-host global domain, then offers to log out (the menu bar only picks the
# change up after a fresh login).
#   NSStatusItemSpacing          gap between icons     (macOS default ~16-17)
#   NSStatusItemSelectionPadding highlight padding     (macOS default ~16)
# Enter "d" at the first prompt to delete both keys and go back to the default.
set -euo pipefail

keys=(NSStatusItemSpacing NSStatusItemSelectionPadding)

current() {
  defaults -currentHost read -globalDomain "$1" 2>/dev/null || echo "macOS default"
}

echo "Current menu bar spacing:"
for k in "${keys[@]}"; do
  printf '  %-30s %s\n' "$k" "$(current "$k")"
done
echo
echo "Smaller fits more icons. 6 is a common choice; 2 is very tight; 16 is about stock."

read -r -p "New icon spacing (0-20, or d for macOS default): " spacing
if [[ "$spacing" == "d" || "$spacing" == "D" ]]; then
  for k in "${keys[@]}"; do
    defaults -currentHost delete -globalDomain "$k" 2>/dev/null || true
  done
  echo "Reset both to the macOS default."
else
  if [[ ! "$spacing" =~ ^[0-9]+$ ]] || (( spacing > 20 )); then
    echo "Expected a whole number from 0 to 20. Nothing changed." >&2
    exit 1
  fi
  read -r -p "New selection padding (0-20) [$spacing]: " padding
  padding="${padding:-$spacing}"
  if [[ ! "$padding" =~ ^[0-9]+$ ]] || (( padding > 20 )); then
    echo "Expected a whole number from 0 to 20. Nothing changed." >&2
    exit 1
  fi
  defaults -currentHost write -globalDomain NSStatusItemSpacing -int "$spacing"
  defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int "$padding"
  echo "Set spacing to $spacing and selection padding to $padding."
fi

echo
echo "The menu bar only applies this after you log out and back in."
read -r -p "Log out now? Save your work first. [y/N]: " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  # Shows macOS's own "Are you sure you want to quit all applications and log
  # out now?" dialog, so you can still cancel there.
  osascript -e 'tell application "System Events" to log out'
else
  echo "OK. Log out later from the Apple menu (⌘⇧Q) to see the change."
fi
