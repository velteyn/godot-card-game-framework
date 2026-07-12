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
- Integration tests: infrastructure 95% fixed (247 signal renames, `.from()` guards, `get_node('Tween')` fixes, `cfc.ut`, `fancy_movement`, `_find_container_at` helper, `drag_drop` bypass for headless)
- Remaining: card `global_position` stale after `move_to` — cards move to correct parent but position stays at hand coordinates. State transition completes, coordinate update needs visual debugging.

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

19. **`tween_all_completed` signal → `finished`**: Godot 4 Tween no longer has `tween_all_completed`. Use `finished` signal instead. Found in 247 occurrences across 24 test files (all integration tests).

20. **`InputEvent.meta` property removed**: Godot 4 `InputEvent`/`InputEventMouseButton` doesn't have `.meta` for storing meta-key state. The `fake_click` helper in UTcommon.gd assigned `ev.meta = flags` which fails. Fix: remove the line since it was unused.

21. **`PopupPanel` has no `modulate`**: In Godot 4, `PopupPanel` extends `Window` (not `Control`→`CanvasItem`), so it lacks `modulate`. Tests reading `ViewPopup.modulate[3]` for visibility checks must use `ViewPopup.visible` instead.

22. **Godot 3 `Tween` child node references in tests**: Many test files used `card.get_node('Tween')` / `.get_node("Tween")` to reference Tween child nodes that don't exist in Godot 4. These must be changed to `card._tween` (the tween created by `create_tween()` and stored as a member).

23. **`PropertyTweener.from()` returns null on started tweens**: In Godot 4, calling `.from()` on a `PropertyTweener` whose parent Tween has already started processing returns null with `"Condition 'started' is true"`. Fix: store the PropertyTweener returned by `tween_property()` and only call `.from()` if non-null.

24. **`yield_to` on null tween crashes GUT**: When GUT's `yield_to(object, signal, timeout)` is called with a null `object`, it triggers `"get_signal_list in null instance"`. All `yield_to` calls on `card._tween` must be guarded with `if card._tween and card._tween.is_valid()`.

25. **Card drag/drop state machine not completing**: Integration tests show cards stuck at `Vector2(-75, 0)` (scene default position) after drag/drop. Root cause: the card interaction system depends on `Area2D` overlap signals (`area_entered` → `_discover_focus` → `_on_Card_mouse_entered` → `FOCUSED_IN_HAND` state), which do not fire in Godot 4 `--headless` mode. The drag handler checks `if state in [FOCUSED_IN_HAND, ...]` but the card never enters a focused state because the virtual mouse never "overlaps" the card's Area2D collision shape. Fix: added `click_card` state force as workaround; needs editor-mode verification.

26. **`cfc.ut` (unit-test flag) never explicitly set**: The `MousePointer.determine_global_mouse_pos()` method checks `if cfc.ut and cfc.NMAP.get("board")` to use the virtual `_UT_mouse_position` for tests. While `cfc._setup()` sets `ut = true` when `is_testing` is true, this was redundant but harmless. The flag is now explicitly set in both `setup_board()` and `setup_main()` for clarity and safety.

27. **`fancy_movement` causes integration test deadlocks**: Card movement tweens with `await _tween.finished` deadlock in headless mode if tweens never complete. Setting `cfc.game_settings.fancy_movement = false` in `UTcommon.before_all()` makes movement instant (no tweens), avoiding the deadlock. Individual tests that need fancy movement can re-enable it in their own `before_each`.

28. **Card `global_position` stale after `move_to`**: The `move_to()` function changes the card's parent (e.g., from hand to pile) and restores `global_position = previous_pos` at line 1226. The MOVING_TO_CONTAINER state handler then creates a tween to `_target_position` (the pile's stack position). The tween completes and `_determine_idle_state()` runs, but the card's `global_position` remains at the old hand coordinates. This may be a Godot 4 coordinate-system difference in how `global_position` is computed after reparenting + tween. Needs editor-mode visual debugging to trace the transform chain.

29. **`get_tree()` not available on `RefCounted`**: `GameStats.gd` extends `RefCounted` but calls `await get_tree().process_frame` in the HTML5/Web branch. `RefCounted` has no `get_tree()` method. Fix: use `Engine.get_main_loop().process_frame` which returns the `SceneTree` via the main loop reference.

30. **Godot 3 binary `.theme` files incompatible**: The `darktheme.theme` file was a Godot 3 binary resource (header `RSRC`). Godot 4 cannot load binary theme resources; `.theme` files must be text-based (`format=3`, `type="Theme"`). Fix: recreated `darktheme.tres` from scratch using the existing `StyleBox/*.tres` assets and icon PNGs, covering Button, CheckButton, CheckBox, OptionButton, Label, PopupMenu, Panel, ScrollBar, SpinBox, and LineEdit styles.

31. **`class_name` is a reserved keyword**: In Godot 4, `class_name` is used to declare script class names and cannot be used as a variable name. The `gen_class_cache.gd` tool script used `var class_name = ...`. Fix: renamed variable and rewrote using `ProjectSettings.get_global_class_list()`.

32. **Coroutine functions require `await` on every call**: Godot 4 enforces that every call to a function containing `await` (a coroutine) must itself use `await`. The `Counters.get_counter()` function was a coroutine (internally calls `await get_counter_and_alterants()`), causing parse errors in 11 test files with 47+ call sites. All callers must add `await`. Note: calls through dynamic property chains (e.g., `cfc.NMAP.board.counters.get_counter()`) may escape parse-time detection but will fail at runtime.

33. **Tween auto-delete causes state machine re-entry (MOVING_TO_CONTAINER)**: In Godot 4, `Tween` auto-deletes after finishing (unlike Godot 3 where tweens persisted). The `MOVING_TO_CONTAINER` state handler's guard `if not (_tween and _tween.is_running())` passed every frame because the auto-deleted tween is no longer running, spawning a new position tween each frame and causing cards to drift right endlessly. Fix: added `state_finalized` guard (matching pattern of all other state handlers) that returns early once the transition completes.

34. **GUT 9.x removed `plugin_control.gd`**: GUT v7.3.0 had a `plugin_control.gd` base class for test runner plugins. GUT v9.7.0 removed this. `cli_plugin.gd` in the tests folder extended this non-existent path. Fix: changed `extends` to `Node`.

35. **Font path migration**: The Comfortaa fonts were moved from `res://fonts/` to `res://fonts/comfortaa/` during migration. Scene files (`CGFBoard.tscn`, `CGFBoardControlLayout.tscn`) still referenced the old path. Fix: updated ext_resource paths to `res://fonts/comfortaa/Comfortaa-Bold.ttf`.

36. **`target_card()` coroutine in `yield_to()` wrappers**: The `target_card()` test utility function is a coroutine (uses `await yield_for()`). Calls wrapped in `yield_to(target_card(...), "completed", 0.1)` failed because Godot 4 requires `await` on the coroutine itself, even when used as an argument. Fix: replaced with direct `await target_card(...)`.

37. **Pile Control labels/buttons hidden behind cards — RESOLVED**: In Godot 3, Control children of CanvasItem parents rendered in a **separate pass** always on top of non-Control children. Godot 4 merged all children into a single `z_index` sort. Fix applied in two parts:
   - **Visual (z_index)**: `control.z_index = 1` in `CardContainer._init_ui()` ensures labels/buttons render above cards. Panel background opacity is handled by the tween in `_pile_add_card` (snapped in `_process` for raw-`add_child` edge cases).
   - **Mouse routing**: Connected the Pile's own `Area2D.mouse_entered` / `Area2D.mouse_exited` signals to `_on_Control_mouse_entered` / `_on_Control_mouse_exited` in `CardContainer._init_signal()`. In Godot 4, `$Control.mouse_entered` can be blocked by sibling Area2D physics input dispatch even with `z_index = 1`; the Area2D signals fire reliably from the collision shape overlap regardless.
   - **Card count label**: Added a sync in `Pile._process()` that keeps `card_count_label.text` up to date every frame (no-op when already correct). This handles the case where cards are added via raw `add_child` (e.g. `load_test_cards`), which bypasses `_pile_add_card` where the label was previously only updated.

## Key Conversion Challenges

1. **`yield` everywhere** — The codebase relies heavily on `yield` for animation sequencing, async card movement, and test coordination. Every occurrence must be converted to `await`.
2. **`GDScriptFunctionState` checks** — Used in tests to verify coroutine validity; must be removed or replaced.
3. **Tween-heavy animations** — Card movement, shuffle animations (corgi/splash/snap/overhand), highlight pulses, focus animations all use the old `Tween` node.
4. **Custom `_global_script_classes`** — Project settings define ~55 custom classes. Godot 4 uses `class_name` directly in scripts; this section can be removed.
5. **`InputEventKey.scancode`** — Used in the input map and input event creation.
6. **Scene format** — Every `.tscn`/`.tres` file needs conversion from `format=2` to `format=3`.
7. **`Array()` type hints** — GDScript 1.x uses untyped arrays; Godot 4 expects `Array[Type]`.
8. **GUT addon** — Entire GUT v7.3.0 must be replaced with a Godot 4-compatible version.
