# How to publish Notesmith on CurseForge

Everything on the GitHub side is wired up. The CurseForge side needs your account because addons are tied to the author's login.

## Step 1 — Make a CurseForge author account

1. Go to <https://www.curseforge.com/> and sign up (Overwolf/Curse account).
2. Verify your email.

## Step 2 — Submit Notesmith for first-time approval

1. Go to <https://authors.curseforge.com/projects/submit/wow>.
2. Fill in:
   - **Name**: `Notesmith`
   - **Summary** (short): `Personal notes with next-login reminders.`
   - **Description** (long): paste the block below.
   - **Categories**: `Chat & Communication` + `Data Broker` (or just `Miscellaneous` if unsure).
   - **WoW versions**: Retail (The War Within) + Burning Crusade Classic.
   - **License**: MIT.
   - **Project URL**: pick whatever short slug — `notesmith` if free.
3. Upload the file from the GitHub release: <https://github.com/bandersong/Notesmith/releases/latest>
4. Submit.

First-time author approval takes **1-3 business days**. Once approved, the project becomes public on CurseForge.

## Description block to paste

```
Notesmith is a simple, clean notes addon with one trick: notes can be flagged to remind you the next time you log in.

FEATURES
- Account-wide notes (write on one character, see them on all of them)
- Per-note "Remind me on my next login" checkbox
- Reminder popup walks through each pending reminder
- Main window auto-opens shortly after login
- Movable, ESC-closes, position remembered
- Quick slash-command capture

SLASH COMMANDS
/notes - toggle the main window
/notes new [title] - create and open a new note
/notes remind <text> - one-liner reminder for next login
/notes list - print notes to chat
/notes clear - clear all pending reminders
/notes auto - toggle auto-open on login

COMPATIBILITY
- Retail (The War Within)
- Burning Crusade Classic Anniversary

Source: https://github.com/bandersong/Notesmith
License: MIT
```

## Step 3 — Auto-publishing for future releases (optional, recommended)

The GitHub Actions workflow is already set up. To turn on automatic CurseForge publishing for every new tag:

1. After CurseForge approves Notesmith, go to your project page → **Settings → API Tokens**.
2. Click **Generate Token**, copy it.
3. On GitHub: <https://github.com/bandersong/Notesmith/settings/secrets/actions>
4. Click **New repository secret**, name it `CF_API_KEY`, paste the token, save.
5. From now on, `git tag v1.0.1 && git push --tags` rebuilds and uploads the new version to both GitHub Releases and CurseForge automatically.

That's it.
