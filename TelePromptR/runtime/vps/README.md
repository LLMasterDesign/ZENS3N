TelePromptR VPS runtime snapshot.

Pulled from:
- `root@5.78.109.54:/root/!CMD.VPS/TelePromptR/3ox.station/vec3/bin/teleprompter.rb`
- `root@5.78.109.54:/root/!CMD.VPS/TelePromptR/STATION.ID`
- `root@5.78.109.54:/root/!CMD.VPS/TelePromptR/TELEPROMPTER.ID`
- `root@5.78.109.54:/root/!CMD.VPS/.3ox/vec3/dev/ops/RUN.TELEPROMPTER.md`

Local path for runtime entrypoint:
- `runtime/vps/3ox.station/vec3/bin/teleprompter.rb`

Notes:
- Runtime creates and uses `runtime/vps/3ox.station/vec3/var/*`.
- Keep secrets out of git; token can live in `var/telegram_token.json`.
