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

Notesmith ships a TOC for every active WoW flavor — the right one auto-loads based on which client you launch.

| Flavor | Interface |
|---|---|
| Retail / Mainline (The War Within) | 120005 |
| Mists of Pandaria Classic | 50503 |
| Wrath Classic / Titan Reforged | 38001 |
| Burning Crusade Classic Anniversary | 20505 |
| Classic Era (Vanilla) | 11508 |

**Tested on:** BC Anniversary. Other flavors share the same Lua API surface that Notesmith uses, so they should work — please open an issue if anything breaks.

## Install

1. Download the latest release zip.
2. Extract into your AddOns folder:
   - Retail: `World of Warcraft/_retail_/Interface/AddOns/`
   - BC Anniversary: `World of Warcraft/_classic_/Interface/AddOns/`
3. Launch WoW, enable **Notesmith** on the AddOns list at character select.

## License

MIT — see [LICENSE](LICENSE).
