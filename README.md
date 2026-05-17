# Notesmith

A clean personal-notes addon for World of Warcraft, with **next-login reminders**.

Jot down anything you want to remember — bag cleanup, a guildie's name, "buy mats Tuesday" — and tick the reminder box. The next time you log in on any character on your account, Notesmith pops a window with your reminders one by one.

## Features

- Account-wide notes — write on one character, see them on all of them.
- Title + multiline body editor with autosave.
- Per-note "Remind me on my next login" checkbox.
- Reminder popup walks through each pending reminder with **Dismiss**, **Keep for Next Login**, and **Open in Notesmith** buttons.
- Main window auto-opens shortly after login (toggle with `/notes auto`).
- Movable, ESC-closes, position remembered between sessions.
- Quick slash-command capture for one-line reminders.

## Slash Commands

| Command | What it does |
|---|---|
| `/notesmith` | Toggle the main window |
| `/notesmith new [title]` | Create and open a new note |
| `/notesmith remind <text>` | One-liner reminder for next login |
| `/notesmith list` | List all notes in chat |
| `/notesmith clear` | Clear all pending reminders (keeps notes) |
| `/notesmith auto` | Toggle auto-open on login |
| `/notesmith help` | Show command list |

## Compatibility

- **Burning Crusade Classic Anniversary** — Interface 20505 (tested)
- **Retail** (The War Within) — Interface 120005 (included but untested)

## Install

1. Download the latest release zip.
2. Extract into your AddOns folder:
   - Retail: `World of Warcraft/_retail_/Interface/AddOns/`
   - BC Anniversary: `World of Warcraft/_classic_/Interface/AddOns/`
3. Launch WoW, enable **Notesmith** on the AddOns list at character select.

## License

MIT — see [LICENSE](LICENSE).
