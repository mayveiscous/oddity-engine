# Oddity Engine

A Roblox-inspired game engine: a Lua instance/scripting layer on top of a
custom C++ renderer, with an in-engine editor built on Dear ImGui.

> **Status:** early, active development. APIs, file formats, and
> project structure will change without warning. Not ready for usage.

## What's here

- **An instance/class system** modeled on Roblox's — `Instance.new(...)`,
  a `Workspace`, a `Parent`/`GetDescendants()` hierarchy, and a growing
  set of built-in classes (`Block`, `Model`, `Camera`, `Light`s, `Motor`, 
  `Hinge`, `Spring`, `Player`, `LuaScript`, and more).
- **A physics layer** — AABB collision with axis-by-axis resolution,
  gravity, slope handling, and a basic character controller implementation.
- **An editor**, built with Dear ImGui: an Explorer (scene tree), an
  Inspector (property editing), an Output/Log panel, and an Animation
  Editor. The editor and gameplay share the same window and the same
  `RunService.Heartbeat` loop, with an explicit **Playtest mode** that
  gates physics/character simulation so editing and running the game
  don't fight each other.
- **Scripting** — user/game code runs as Lua `LuaScript` instances,
  driven by `RunService`, `InputService`, and a small `Signal`
  (Connect/Disconnect) implementation for events. Default scripts for
  a character controller and character camera ship with the engine,
  the same way Roblox ships default scripts to developers.

## In progress

- **Bug Fixing** — Multiple systems are buggy and need to be polished, doing the boring work.
- **Save/load** — scenes aren't persistent yet; this is the next major
  piece after bug fixes, starting with a disk-based format.
- **Physics Engine** — This will literally never be done. Easily the hardest and most
  eventful part of this engine so far.

## Tech stack

- **Lua 5.4** for the scripting/instance layer and the editor UI code.
- **C++** for the renderer which uses *OpenGL* via GLAD, windowing/input via *GLFW*,
  and the editor's immediate-mode UI via *Dear ImGui* — compiled into a
  native Lua module (`graphics.dll`) that the Lua side calls into for
  drawing, raycasting, and window/input handling.

## Notes

- *Oddity Engine* is far from complete, many changes will be made and features added.
- Default modules will be wrapped in LuaScript objects once API is capable.
- TunaScript support is being reconsidered, and may not make it out of development.
- All code is implemented by me (mayveiscous) through documentation and use of AI for research *only*
- This repository will **not** include *Oddity Runtime* once it begins development.

## License

MIT — see [LICENSE](LICENSE).
