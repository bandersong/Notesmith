# Notesmith Changelog

## v1.1.0
- Full multi-flavor support: Retail (Mainline), Classic Era (Vanilla), TBC Anniversary, Wrath / Titan Reforged, and Mists of Pandaria Classic.
- Per-flavor TOC files using current live interface versions pulled from Blizzard's CDN (120005 / 50503 / 38001 / 20505 / 11508).
- Added defensive `CopyTable` fallback for older Classic environments.

## v1.0.1
- Slash command consolidated: only `/notesmith` (dropped `/notes` and `/note` aliases to avoid conflicts with other addons).

## v1.0.0
- Initial release.
- Account-wide notes (title + multiline body).
- Per-note "Remind me on my next login" checkbox.
- Reminder popup fires automatically after PLAYER_LOGIN.
- Main window auto-opens on login (toggle via `/notes auto`).
- Slash commands: `/notes`, `/notes new`, `/notes remind`, `/notes list`, `/notes clear`, `/notes auto`, `/notes help`.
- Supports Retail (Interface 120005) and BC Anniversary Classic (Interface 20505).
