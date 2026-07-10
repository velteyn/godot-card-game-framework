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
5. **Update GUT** — Replace Godot 3 addon with Godot 4 GUT version (9.7.0)
6. **Fix tests** — Update test code for GUT 4 API + GDScript 2.0
7. **Verify** — Run full test suite, manual visual checks

## Migration Progress

### Phase 1 (Automated Conversion) — ✅ Completed
- Validated and converted via `--convert-3to4` tool
- All scenes/resources saved in Godot 4 format

### Phase 2 (Manual GDScript Fixes) — ✅ Completed
- `yield` → `await` throughout all `.gd` files
- `export`/`onready`/`tool` → `@export`/`@onready`/`@tool`
- `setget` → inline setter/getter blocks (fixed ~15 files)
- `.instance()` → `.instantiate()`
- Signal connections → callables throughout
- `Pool*Array` → `Packed*Array`
- File/Directory → FileAccess/DirAccess
- `BUTTON_LEFT` → `MOUSE_BUTTON_LEFT`
- `scancode` → `keycode`
- Tween nodes → `create_tween()` API throughout
- `rect_*` → direct properties on Control
- `modulate[3]` → `.a`

### Phase 3 (Scenes & Resources) — ✅ Completed
- All `.tscn`/`.tres` files saved in Godot 4 format
- Theme/style paths updated where needed

### Phase 4 (GUT Testing Framework) — ✅ Completed
- Replaced Godot 3 GUT v7.3.0 with Godot 4 GUT v9.7.0
- Updated `_ready()` chains to call `super()` in Pile, Hand, CGFDeck, CGFDiscard, CGFHand
- Fixed all Godot 4 API regressions in test utilities
- GUT CLI: `godot47 --headless -s res://addons/gut/gut_cmdln.gd --path . -gdir <dirs> -ginclude_subdirs -gexit`

### Phase 5 (Project Settings) — ✅ Completed
- Removed `_global_script_classes` and `_global_script_class_icons`
- Updated input map (`scancode` → `keycode`)
- Removed old `[editor_plugins]`

### Phase 6 (Verification) — 🔶 In Progress
- Project loads in headless mode without compilation errors
- All 8 unit test files pass: `test_card_class.gd` (10/10), `test_cardcontainer_class.gd` (5/5), `test_pile_class.gd` (6/6), `test_AskInteger_scene.gd` (3/3), `test_OptionalConfirmation_scene.gd` (5/5), `test_DeckBuilder.gd` (2/2), `test_token_class.gd` (6/6)
- Integration tests still failing (pre-existing migration issues: Tween nulls, signal conversion errors)
- Key fixes: `move_to` board-drop containment, `CGFBoard.gd` GUT detection, canonical_name check, child index adjustments, popup card return, tween signal name, shuffle signal lambda, anchor warning fix

### Key Bugs Discovered During Migration

1. **`Button.pressed` returns signal object, not bool**: In Godot 4, `Button.pressed` returns the signal object. Use `Button.button_pressed` for the boolean property. This corrupted the settings file when serialized.
2. **Property getter/setter recursion**: Godot 4 property getters/setters always go through themselves from within the class. Direct backing variables (`_card_name`, `_card_rotation`, etc.) needed where getter returns a function that reads the same property.
3. **`_ready()` super() chaining**: Godot 4 does NOT auto-call parent `_ready()`. Custom `_ready()` methods that override must call `super()`, or the parent's initialization (including `cfc.map_node(self)` in `CardContainer`) never runs.
4. **`Window.size` is `Vector2i`**: In Godot 4, `Window.size` returns `Vector2i`, not `Vector2`. Mixing with `Vector2` operands causes type errors.
5. **`connect()` errors on duplicate**: Godot 4's `connect()` raises an error if the same callable is already connected. Must use `is_connected()` guard when `_ready()` can be called multiple times (e.g., re-parenting).
6. **`popup_hide` signal removed**: `AcceptDialog`/`Window` no longer has `popup_hide` in Godot 4. Use `close_requested` or `visibility_changed` instead.
7. **`reset_min_size()` → `reset_size()`**: `PopupPanel` (Window-based) has `reset_size()`, not `reset_min_size()`.
8. **`Node.name` auto-renames sibling duplicates**: Godot 4 silently appends a suffix (e.g., "Test Card 2" → "Test Card 6") when multiple siblings share a name. `canonical_name` is unaffected. Found in tests checking `card.name`.
9. **`move_to()` board-drop code leaked into pile/hand moves**: The `get_parent().move_child(self, get_parent().get_child_count() - 1)` at line 1334 of `CardTemplate.gd` ran unconditionally, undoing any custom index placement for pile moves. Fixed by wrapping in an `else` clause.
10. **`CGFBoard.gd` GUT detection**: The guard `has_node('Gut')` never matched because GUT v9.7.0's root node is `GutRunner`. Changed to `cfc.is_testing`.
11. **`RichTextLabel.append_text()` doesn't set `.text`**: In Godot 4, `append_text()` does NOT update the `text` property (unlike Godot 3's `append_bbcode()`). Fixed in `CardFront.gd:_assign_bbcode_text`.
12. **`wait_seconds` fires before `process_frame`**: `SceneTreeTimer` resolves before `process_frame` in the same frame cycle, affecting test timing assumptions.

13. **`get_class()` returns engine class, not script class_name**: In Godot 4, `Node.get_class()` returns only the engine-level class name (e.g., `"Area2D"`), never script-defined `class_name` (e.g., `"CardContainer"`). Use `is` keyword for type checks or a custom method like `get_card_container_class()`.

14. **`Window.transparency` no-op on embedded popups**: In Godot 4, `Window.transparency` is documented as having no effect on embedded windows (popups/dialogs). The `tween_property($ViewPopup, 'transparency', ...)` call returns null, causing `.from()` to crash. Fix: animate `modulate:a` on the popup's content child instead.

15. **`Control.new().set_name()` overridden by `add_child`**: In Godot 4, calling `set_name("Foo")` on a dynamically created `Control.new()` before adding it to the scene tree gets overridden. The node receives an internal name like `@Control@212` after `add_child()`. Fix: set the name AFTER `add_child()` via `node.name = "Foo"`.

16. **Signal `bind()` type coercion with typed functions**: Godot 4's `Callable.bind()` appends bound arguments after signal arguments. When the target function has typed parameters, a type mismatch occurs if the signal argument or bound arg doesn't match the parameter type. The original `shuffle_completed.connect(cfc.signal_propagator._on_signal_received.bind("shuffle_completed", {...}))` called `_on_signal_received(self, "shuffle_completed", {...})` where `self` (Pile) couldn't be converted to `Card`. Fix: use a lambda wrapper that accepts the signal arg and passes `null` as the typed param.

17. **Control `layout_mode` anchor conflicts**: In Godot 4, Controls default to `layout_mode = 1` (anchors mode). Direct `position`/`size` assignments trigger `"Nodes with non-equal opposite anchors will have their size overridden"` warnings. For Controls parented under Area2D (like the Pile's Panel), set `layout_mode = 0` before direct manipulation.

18. **Godot 3 Tween nodes removed from scenes**: The Godot 3 Pile.tscn included `Tween` child nodes. During migration these were removed (Godot 4 uses `create_tween()`). Custom scenes like UTBoard.tscn had overrides referencing these removed nodes, causing `"node was modified from inside an instance, but it has vanished"` warnings. Fix: remove orphaned Tween node overrides from inherited scenes.

## Key Conversion Challenges

1. **`yield` everywhere** — The codebase relies heavily on `yield` for animation sequencing, async card movement, and test coordination. Every occurrence must be converted to `await`.
2. **`GDScriptFunctionState` checks** — Used in tests to verify coroutine validity; must be removed or replaced.
3. **Tween-heavy animations** — Card movement, shuffle animations (corgi/splash/snap/overhand), highlight pulses, focus animations all use the old `Tween` node.
4. **Custom `_global_script_classes`** — Project settings define ~55 custom classes. Godot 4 uses `class_name` directly in scripts; this section can be removed.
5. **`InputEventKey.scancode`** — Used in the input map and input event creation.
6. **Scene format** — Every `.tscn`/`.tres` file needs conversion from `format=2` to `format=3`.
7. **`Array()` type hints** — GDScript 1.x uses untyped arrays; Godot 4 expects `Array[Type]`.
8. **GUT addon** — Entire GUT v7.3.0 must be replaced with a Godot 4-compatible version.
