# Godot Card Game Framework (CGF) — Project Analysis & Migration Context

## Goal

Convert this project from **Godot 3.x** to **Godot 4.7**. The current codebase is version **2.2** of the Card Game Framework ([Github](https://github.com/db0/godot-card-framework)). It uses Godot 3.x-specific APIs throughout: GDScript 1.x syntax (`yield`, `export`, `onready`, `tool`, `setget`, `PoolStringArray`, `BUTTON_LEFT`, `scancode`, etc.), `format=2` scene/resource files, the old `Tween` node, and string-based signal connections.

## Available Tools

| Tool | Path |
|------|------|
| Godot 4.7 binary | `/home/velteyn/.local/bin/godot47` |
| Godot source (4.8-dev) | `/home/velteyn/projects/godot` |
| Godot 4.7 docs | https://docs.godotengine.org/en/4.7/ |

## Project Overview

This is a full-featured 2D card game framework providing:

- **Card system** — 16-state FSM (`Area2D`-based), face-up/down, drag/drop, focus/selection, rotation, attachments, ghost cards, manipulation buttons, token drawer, targeting arrow
- **Containers** — Hand (with excess-card handling), Pile (with shuffle animations), Board (with placement grids & slots)
- **Scripting Engine** — Task-based card automation with subjects, filters, alters, per-counters, costs, popups, nested scripts, conditional execution, alterant runtime modifiers
- **UI systems** — Card viewer (grid/list), Deck builder with save/load/serialize, card library, card info panels, selection windows, integer input dialogs, optional confirmation dialogs, card choices popups
- **Utilities** — Card filter engine, overridable game hooks, RNG seed management, counters/tokens system, highlight system, viewport card focus, game stats HTTP submission, singleton autoload (`cfc`)
- **Testing** — Full GUT (v7.3.0) test suite (40+ test files, unit + integration), plugin-based CLI runner

## Architecture

```
project.godot           ← config_version=4 (Godot 3 format), autoload cfc→CFControl.gd
src/
├── core/               ← Framework base (DO NOT MODIFY for upgrades)
│   ├── CFControl.gd    ← Autoload singleton (cfc): NMAP node map, settings, engine references
│   ├── Card/
│   │   ├── CardBack.gd / CardBackGlow.gd / CardBackTexture.gd
│   │   ├── CardFront.gd
│   │   ├── TargetingArrow.gd
│   │   ├── ManipulationButtons.gd
│   │   └── TokenDrawer.gd
│   ├── CardTemplate.gd / CardTemplate.tscn  ← Main card class (extends Area2D)
│   ├── CardContainer.gd                     ← Base container
│   ├── Hand.gd / Hand.tscn
│   ├── Pile.gd / Pile.tscn
│   ├── BoardTemplate.gd                     ← Board class (extends Control)
│   ├── BoardPlacementGrid.gd / BoardPlacementSlot.gd
│   ├── MousePointer.gd
│   ├── Counters.gd / Token.gd
│   ├── Highlight.gd
│   ├── ViewportCardFocus.gd
│   ├── ScriptingEngine/                     ← 9 files (engine, tasks, alters, props, utils)
│   ├── CardViewer/                          ← Viewer + Library + DeckBuilder subsystems
│   ├── CFUtils.gd / CFInt.gd / CFConst.gd
│   ├── OverridableUtils.gd / GameStats.gd
│   └── UI Dialogs (SelectionWindow, OptionalConfirmation, AskInteger, CardChoices, DetailPanels, IntegerLineEdit)
├── custom/             ← Game-specific implementations extending core
│   ├── CFConst.gd, SP.gd, MainMenu.gd
│   ├── CGFBoard.gd, CGFHand.gd, CGFDeck.gd, CGFDiscard.gd
│   ├── CGFCardTemplate.gd, CGFCardFront.gd, CGFCardBack.gd
│   ├── CGFCounters.gd, CGFManipulationButtons.gd
│   ├── CGFDeckbuilder/ (extends CardViewer/DeckBuilder)
│   └── cards/ (CardConfig, CustomScripts, SetPreload, SetDefinition/SetScript demo sets)
addons/gut/             ← GUT v7.3.0 (Godot 3 version) test framework
tests/                  ← 40+ test files (unit + integration + common helpers)
assets/                 ← card_backs/, icons/, tokens/
fonts/                  ← Xolonium, Comfortaa
themes/                 ← Dark theme
```

## Godot 3.x → 4.7 Key Breaking Changes

### GDScript Language
| Godot 3 | Godot 4 |
|---------|---------|
| `yield(x, "completed")` | `await x` |
| `GDScriptFunctionState` | Removed (use `await`) |
| `.instance()` | `.instantiate()` |
| `tool` | `@tool` |
| `export var` | `@export var` |
| `onready var` | `@onready var` |
| `setget` | Inline `set(value):` / `get():` syntax |
| `func .() ` (parent call) | `super()` |
| `is_connected()` / `connect()` | Signal callables (`sig.connect(callable)`) |
| Typed arrays `Array` | `Array[Type]` |
| `PoolStringArray`, `PoolIntArray`, etc. | `PackedStringArray`, `PackedInt32Array`, etc. |
| `get_node()` / `find_node()` | Mostly unchanged, `$` notation same |

### Scene/Resource Format
| Godot 3 | Godot 4 |
|---------|---------|
| `format=2` | `format=3` |
| `type="Script"` | `type="GDScript"` |
| `ProceduralSky` sub_resource | `Sky` with `ProceduralSkyMaterial` |
| Numeric enum values (`mouse_filter=2`) | Named constants (`MOUSE_FILTER_IGNORE`) |

### Control Nodes
| Godot 3 | Godot 4 |
|---------|---------|
| `rect_position`, `rect_size`, `rect_rotation`, `rect_scale` | `position`, `size`, `rotation`, `scale` |
| `rect_min_size` | `custom_minimum_size` |
| `margin_left/top/right/bottom` | `offset_left/top/right/bottom` |
| `modulate[3]` / `self_modulate[3]` | `.a` property |
| `custom_fonts/font` | `theme_override_fonts/font` |
| `custom_styles/panel` | `theme_override_styles/panel` |

### Input System
| Godot 3 | Godot 4 |
|---------|---------|
| `BUTTON_LEFT`, `BUTTON_RIGHT` | `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_RIGHT` |
| `.scancode` | `.keycode` or `.physical_keycode` |
| `.to_ascii()[0]` | `.to_ascii_buffer()[0]` |
| `KEY_*` constants | Renamed constants |

### File I/O
| Godot 3 | Godot 4 |
|---------|---------|
| `File.new()`, `file.open(path, File.READ)` | `FileAccess.open(path, FileAccess.READ)` |
| `Directory.new()`, `dir.dir_exists()` | `DirAccess.open()` / static methods |
| `JSON.parse(string)`, `JSON.print(data)` | `JSON.new().parse(string)`, `.stringify(data)` |

### Tween System
| Godot 3 | Godot 4 |
|---------|---------|
| `$Tween.interpolate_property(...)` | `create_tween().tween_property(...)` |
| `$Tween.start()` | Auto-started |
| `tween_all_completed` signal | `finished` signal |

### Other Notable Changes
- `OS.get_ticks_msec()` → `Time.get_ticks_msec()`
- `Viewport` → `SubViewport` / `SubViewportContainer`
- `get_tree().get_nodes_in_group()` unchanged
- `randomize()` called automatically; use `RandomNumberGenerator` for deterministic
- `call_group()` now immediate; use `call_group_flags(GROUP_CALL_DEFERRED, ...)` for deferred
- `EditorPlugin.add_custom_type()` different signature

## Migration Strategy

1. **Backup** — This is already on a git branch, safe to proceed
2. **Run conversion tool** — Use Godot 4.7 binary with `--validate-conversion-3to4` then `--convert-3to4`
3. **Fix GDScript** — Address all syntax/API errors:
   - `yield` → `await` throughout
   - `export`/`onready`/`tool` → `@export`/`@onready`/`@tool`
   - `setget` → inline setter/getter blocks
   - `.instance()` → `.instantiate()`
   - Signal connections → callables
   - `Pool*Array` → `Packed*Array`
   - File/Directory → FileAccess/DirAccess
   - `BUTTON_LEFT` → `MOUSE_BUTTON_LEFT`
   - `scancode` → `keycode`
   - Tween nodes → `create_tween()` API
   - `rect_*` → direct properties on Control
   - `modulate[3]` → `.a`
4. **Fix scenes/resources** — Re-save in Godot 4 format
5. **Update GUT** — Replace Godot 3 addon with Godot 4 GUT version
6. **Fix tests** — Update test code for GUT 4 API + GDScript 2.0
7. **Verify** — Run full test suite, manual visual checks

## Key Conversion Challenges

1. **`yield` everywhere** — The codebase relies heavily on `yield` for animation sequencing, async card movement, and test coordination. Every occurrence must be converted to `await`.
2. **`GDScriptFunctionState` checks** — Used in tests to verify coroutine validity; must be removed or replaced.
3. **Tween-heavy animations** — Card movement, shuffle animations (corgi/splash/snap/overhand), highlight pulses, focus animations all use the old `Tween` node.
4. **Custom `_global_script_classes`** — Project settings define ~55 custom classes. Godot 4 uses `class_name` directly in scripts; this section can be removed.
5. **`InputEventKey.scancode`** — Used in the input map and input event creation.
6. **Scene format** — Every `.tscn`/`.tres` file needs conversion from `format=2` to `format=3`.
7. **`Array()` type hints** — GDScript 1.x uses untyped arrays; Godot 4 expects `Array[Type]`.
8. **GUT addon** — Entire GUT v7.3.0 must be replaced with a Godot 4-compatible version.
