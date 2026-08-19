# Oddity Engine

A Roblox-inspired game engine with a Lua instance/scripting layer on top of a
custom C++ renderer, with an in-engine editor built on Dear ImGui.

> **Status:** early, active development. APIs, file formats, and
> project structure will change without warning. **Not** ready for usage.

## In progress

- **Save/load** - scenes aren't persistent yet; this is the next major
  piece, starting with a disk-based format and eventually migrating to a Cloudflare-based server.

- **Undo/Redo** - Right now you can't use Ctrl + Y and Ctrl + Z to undo/redo actions.

## Tech stack

- **Lua 5.4** for the scripting/instance layer and the editor UI code.
- **C++** for the renderer which uses *OpenGL* via GLAD, windowing/input via *GLFW*,
  and the editor's immediate-mode UI via *Dear ImGui* — compiled into a
  native Lua module (`oddity.graphics.dll`) that the Lua side calls into for
  drawing, raycasting, and window/input handling.

## Notes

- *Oddity Engine* is far from complete, many changes will be made and features added.
- Default modules will be wrapped in LuaScript objects once API is capable.
- This repository will **not** include *Oddity Runtime* once it begins development.

## License

MIT — see [LICENSE](LICENSE).
