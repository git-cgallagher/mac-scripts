# Changelog

## 2026-11-06

- `SECURITY.md`'s Scope section now covers `menubar/menu-bar-spacing.sh` too:
  which values it writes, and that its log-out step still goes through macOS's
  own confirmation dialog. The README's Contributing section now asks each new
  tool to add a Scope bullet, so the two don't drift apart again.

## 2026-11-01

- Added `menubar/menu-bar-spacing.sh`: shows the current menu bar icon
  spacing, sets a new value (or resets to the macOS default), then offers to
  log out so the change takes effect. Helps fit more icons beside the notch.

## 2026-10-29

- Added `SECURITY.md`: report security problems privately through GitHub's
  advisory form (private vulnerability reporting is now on).
- `main` is now protected by the repo ruleset "main protection" (id
  `26118889`). Changes land only through pull requests (0 approvals; there is
  no CI, so no required checks), and force-pushes and deleting `main` are
  blocked. Also turned on Dependabot security updates and
  delete-branch-on-merge.

## 2026-08-15

- Initial public release: `imessage/monitor-imessage-download.sh` — monitors
  the Messages-in-iCloud full-history download and announces completion.
- Repo scaffolding: MIT license, README with tool catalog, topic-directory
  layout for future scripts.
