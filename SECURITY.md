# Security policy

## Reporting a vulnerability

Please report security issues **privately** through GitHub:
[Report a vulnerability](https://github.com/git-cgallagher/mac-scripts/security/advisories/new)
(the **Security** tab, then **Report a vulnerability**). Don't open a public issue for a security problem.

You can expect an acknowledgement within a week. This is a one-person project, so fixes are best effort.

## Supported versions

Only the latest version on `main` gets fixes.

## Scope

These are small bash scripts that you run by hand on your own Mac, with your own user's privileges.
They use only tools that ship with macOS. They open no network listeners, make no network
connections and store no credentials.

- `imessage/monitor-imessage-download.sh` opens `~/Library/Messages/chat.db` read-only
  (`sqlite3 -readonly`) and measures the Messages attachments folder. It changes nothing in Messages.
  It needs Full Disk Access for your terminal app, and it announces completion with a macOS
  notification and `say`.
