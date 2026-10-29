# Changelog

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
