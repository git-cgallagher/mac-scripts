# mac-scripts

Small, self-contained macOS utility scripts. Each tool lives in its own
topic directory with no dependencies beyond what ships with macOS (bash,
sqlite3, standard BSD userland).

## Catalog

| Script | What it does |
|---|---|
| [`imessage/monitor-imessage-download.sh`](imessage/monitor-imessage-download.sh) | Watches the Messages-in-iCloud full-history download to a Mac and announces when it looks complete. |
| [`menubar/menu-bar-spacing.sh`](menubar/menu-bar-spacing.sh) | Tightens the gap between menu bar icons so more of them fit beside the notch, then offers to log out. |

---

## imessage/monitor-imessage-download.sh

### Why this exists

When **Messages in iCloud** is enabled, iCloud is the authoritative store for
your message history and each device keeps only a lazily-hydrated local
mirror in `~/Library/Messages/chat.db`. Scrolling back in the Messages app
triggers on-demand fetches — which means any offline archive taken from the
local database may silently be missing years of history.

The supported fix is to uncheck **Messages → Settings → iMessage → "Enable
Messages in iCloud"** and choose **Disable This Device**: the Mac then
downloads the complete history from iCloud before disconnecting. For a
decade of messages this can take hours, and macOS gives you no progress bar
beyond a vague status line. This script fills that gap.

### What it does

Polls four signals every 60 seconds:

- total message count in `chat.db`
- oldest message date (backfill marches backward in time)
- `chat.db` size on disk
- `~/Library/Messages/Attachments/` size and file count

The download commits in bursts, so completion is declared only after **all**
signals have been flat for 15 consecutive polls (~15 minutes). Any movement
resets the counter. On completion it:

- posts a macOS notification banner and a spoken alert (`say`)
- prints a messages-per-year table so you can sanity-check that early years
  are actually populated

It also runs `caffeinate` for its own lifetime so the Mac won't sleep
mid-download, and only ever opens the database read-only.

### Usage

```bash
./imessage/monitor-imessage-download.sh
```

Tunables (environment variables):

```bash
# stricter: 30s resolution, 15 minutes flat required
INTERVAL=30 STABLE_POLLS=30 ./imessage/monitor-imessage-download.sh
```

| Variable | Default | Meaning |
|---|---|---|
| `INTERVAL` | `60` | Seconds between polls |
| `STABLE_POLLS` | `15` | Consecutive unchanged polls before declaring complete |

### Requirements

- Your terminal app needs **Full Disk Access** (System Settings → Privacy &
  Security → Full Disk Access), or `chat.db` is unreadable. The script
  detects this and tells you.

### Caveats

- Flat-for-N-minutes is a **heuristic**: a long iCloud stall could trigger
  it early. Before trusting the result, also confirm Messages → Settings →
  iMessage no longer says "Downloading messages from iCloud", and review the
  per-year table it prints.
- Attachment hydration typically trails message text — the script accounts
  for this by requiring the attachments signals to go flat too.

## menubar/menu-bar-spacing.sh

### Why this exists

On MacBooks with a notch, menu bar icons that don't fit to the right of the
notch are silently hidden: there's no overflow menu. macOS reads two hidden
settings that control how much space each icon takes, and shrinking them
often fits several more icons without installing a menu bar manager.

### What it does

1. Shows the current values of `NSStatusItemSpacing` (gap between icons) and
   `NSStatusItemSelectionPadding` (highlight padding). macOS's default is
   about 16 for both when the keys are unset.
2. Asks for new values (0–20; padding defaults to the spacing value), or `d`
   to delete both keys and return to the macOS default.
3. Writes them with `defaults -currentHost write -globalDomain`.
4. Offers to log out, since the menu bar only applies the change at login.
   Answering `y` opens macOS's own log-out confirmation, so you can still
   cancel there.

### Usage

```bash
./menubar/menu-bar-spacing.sh
```

It's interactive, so run it in a terminal window. Try 6 first; go to 2–4 if
icons are still hidden. To undo, run it again and enter `d`.

### Caveats

- These are undocumented settings. Apple could ignore or change them in a
  future macOS release.
- If icons are still hidden at the tightest spacing, a menu bar manager such
  as [Ice](https://github.com/jordanbaird/Ice) can collapse the overflow.

## Contributing

New tools go in a topic directory (`imessage/`, `network/`, …) with a
section added to the catalog table and this README. Keep scripts
self-contained, dependency-free, and safe to read-only by default.

Changes land through pull requests: `main` is protected by the repo
ruleset "main protection", so direct pushes are rejected.

## Security

Please report security problems privately; see [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
