# yuni.cc — NextGen Multi-Tool

<p align="center">
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" alt="Status">
  <img src="https://img.shields.io/badge/Version-v1.0.4-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/Platform-Roblox-red?style=for-the-badge" alt="Platform">
</p>

**yuni.cc** — is a module script-tool for Roblox. Designed as the best open-source multi-tool written on Luau.

---

## Launch

To use this, copy&paste this code into your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/unitedforklow/yuni-cc/main/main.lua"))()
```

*Show/hide menu:* **`Right Shift`**

---

## Structure

The project is fully modular, all UI render happens in main.lua, and is module-agnostic.

1. **`main.lua`** - Core of the project.
2. **`visuals.lua`** - ESP, uses Drawing API (https://docs.sunc.su/Drawing/)
3. **`lock-on.lua`** - Aimbot, a little buggy. Rivals Support.
4. **`triggerbot.lua`** - Triggerbot, just like in CS2 cheat.
5. **`misc.lua`** - Some utilities.
6. **`fakelag.lua`** - makes you fakelag.
7. **`configs.lua`** - saves your settings in your executor workspace (yuni_config.json).
8. **`desync.lua`** - rage feature makes others aimbots work badly on you.

---

## For Developers / Contributions

All modules interact with each other through a common global table of settings and events:

* `shared.YuniSettings` — Storage of current Boolean values, slider limits, and selected options.
* `shared.YuniActions` — Exporting backend functions (e.g., 'shared. YuniActions.Rejoin' and 'shared. YuniActions.ServerHop') for a secure call inside the interface buttons.
* `shared.YuniSettings.Loaded` — A logical flag that prevents heavy background loops from running until the interface is fully rendered in the game.

---

Designed for personal use. Use at your own risk.
