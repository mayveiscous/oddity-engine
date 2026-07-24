# Oddity Engine

A Roblox-inspired game engine: a Lua instance/scripting layer on top of a
custom C++ renderer, with an in-engine editor built on Dear ImGui.

> **Status:** early, active, hobby development. APIs, file formats, and
> project structure will change without warning. Not ready for anyone but
> the author to build a game in yet.

## What's here

- **An instance/class system** modeled on Roblox's — `Instance.new(...)`,
  a `Workspace`, a `Parent`/`GetDescendants()` hierarchy, and a growing
  set of built-in classes (`Block`, `Model`, `Camera`, `Light`s, `Weld`,
  `Hinge`, `Spring`, `Motor`, `Player`, `LuaScript`, and more).
- **A physics layer** — AABB collision with axis-by-axis resolution,
  gravity, slope handling, and a character controller with step-height
  and ground probing.
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

- **Gizmos** — Move is being built out first (drag one axis at a time,
  hit-tested through the same `graphics.raycast` picking used for object
  selection); Rotate and Scale will follow the same pattern.
- **Save/load** — scenes aren't persistable yet; this is the next major
  piece after gizmos, starting with a disk-based format.
- **Service classes** — `RunService`, `InputService`, and
  `SelectionService` exist; `RenderService`, `PhysicsService`,
  `AssetService`, `AudioService`, and `NetworkService` are planned but
  not yet built.

## Tech stack

- **Lua 5.4** for the scripting/instance layer and the editor UI code.
- **C++** for the renderer, *OpenGL* via GLAD, windowing/input via *GLFW*,
  and the editor's immediate-mode UI via *Dear ImGui* — compiled into a
  native Lua module (`graphics.dll`) that the Lua side calls into for
  drawing, raycasting, and window/input handling.


## Project layout

```
src/
  classes/    -- built-in Instance types (Block, Camera, Weld, etc.)
  classes.lua -- class registry
  core/       -- instance base, signals, camera controller
  editor/     -- Explorer, Inspector, Output, Animation Editor, Top Bar
  physics/    -- AABB collision, gravity, slopes, character physics
  render/     -- C++ renderer, ImGui bindings, shapes
  rig/        -- default character rig
  scripting/  -- default modules given to user scripts (camera, controller)
  types/      -- Vector2, Vector3, Color3, etc.
main.lua
```

## Notes

- *Oddity Engine* is far from complete, many changes will be made and features added.
- Default modules will be wrapped in LuaScript objects once API is capable.
- TunaScript support is being reconsidered, and may not make it out of development.
- All code is implemented by me (mayveiscous) through documentation and use of AI for research *only*
- This repository will **not** include *Oddity Runtime* once it begins development.

## License

MIT — see [LICENSE](LICENSE).
