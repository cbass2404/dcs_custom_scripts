# Custom Scripting Library

Lua Library for custom dcs mission generation

## Load Order

1. main.lua
2. config.lua
3. Library Files
4. Event Listener

## Compiling

`./compile.ps1` (or `./compile.ps1 <mission>`) compiles each mission into `compiled/<mission>.lua` for a single DO SCRIPT FILE upload, using the "Script Load Order" block in `mission/<mission>/README.md`.

Every `.lua` file must be in the load order except `*.model.lua` files and other missions' directories, or the mission won't compile. Files the mission editor calls should register a function on `MagnusDCSScripting` rather than run top-level code, so they load once and the mission editor calls the function.

## Kneeboards

low def = 768 × 1024 pixels
high def = 1536 × 2048 pixels

## Dev/Prod Mode

Go to DCS World/Scripts/MissionScripting.lua and un/comment:

```lua
    -- sanitizeModule('os')
    -- sanitizeModule('io')
    -- sanitizeModule('lfs')
```
