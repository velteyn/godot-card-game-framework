# Godot 3.x API Inventory

This file catalogs every Godot 3.x-specific API usage pattern found in the codebase, organized by category.

## GDScript Language Patterns

| Pattern | Files Affected | Godot 4 Equivalent |
|---------|---------------|-------------------|
| `yield(x, "completed")` | ~ALL .gd files (~50+ files) | `await x` |
| `yield(get_tree(), "idle_frame")` | GameStats.gd, tests | `await get_tree().process_frame` |
| `GDScriptFunctionState` checks | UTcommon.gd, Basic_common.gd, Attachment_common.gd, ScEng_common.gd | Remove / use await |
| `export var` | ~30 files | `@export var` |
| `onready var` | ~20 files | `@onready var` |
| `tool` | ~5 files (plugin, editor) | `@tool` |
| `setget` | ~15 files | inline set/get blocks |
| `func .parent()` calls | ~10 files | `super()` |
| `instance()` | ~10 files | `instantiate()` |
| `PoolStringArray` | project.godot, CFUtils.gd | `PackedStringArray` |
| `Array()` | Throughout | `Array[Type]` |

## Input System

| Godot 3 | Files | Godot 4 |
|---------|-------|---------|
| `BUTTON_LEFT` | UTcommon.gd, GUT input_factory.gd | `MOUSE_BUTTON_LEFT` |
| `InputEventKey` with `.scancode` | project.godot (input map), GUT input_factory.gd | `.keycode` / `.physical_keycode` |
| `.to_ascii()[0]` | GUT input_factory.gd | `.to_ascii_buffer()[0]` |
| KEY constants | GUT input_factory.gd | renamed constants |

## File I/O

| Godot 3 | Files | Godot 4 |
|---------|-------|---------|
| `File.new()`, `file.open()`, `file.close()` | DeckLoader.gd, gut_config.gd, CFUtils.gd | `FileAccess.open()` |
| `Directory.new()`, `dir.dir_exists()` | DeckLoader.gd, CFUtils.gd | `DirAccess.dir_exists()` (static) |
| `File.READ`, `File.WRITE` | Same files | `FileAccess.READ`, `FileAccess.WRITE` |
| `JSON.parse(string)` | DeckLoader.gd, gut_config.gd | `JSON.new().parse(string)` |
| `JSON.print(data)` | DeckLoader.gd | `JSON.new().stringify(data)` |

## Tween System

| Godot 3 | Files | Godot 4 |
|---------|-------|---------|
| `$Tween.interpolate_property()` | CardTemplate.gd, Hand.gd, Pile.gd, Highlight.gd, etc. | `create_tween().tween_property()` |
| `$Tween.start()` | Multiple | Auto-started |
| `tween_all_completed` signal | Multiple | `.finished` signal |
| Tween node in scenes | CardTemplate.tscn, Highlight.tscn, Pile.tscn | Remove node, use code |

## Control Properties

| Godot 3 | Files | Godot 4 |
|---------|-------|---------|
| `rect_position` | CardTemplate.gd, many scenes | `position` |
| `rect_size` | CardTemplate.gd, CardFront.gd, many scenes | `size` |
| `rect_rotation` | BoardTemplate.gd, test_board_use.gd | `rotation` |
| `rect_scale` | CardTemplate.gd, test_facedown.gd | `scale` |
| `rect_min_size` | Various scenes | `custom_minimum_size` |
| `margin_left/right/top/bottom` | Various scenes | `offset_left/right/top/bottom` |
| `modulate[3]` (alpha index) | ManipulationButtons.gd, test_board_use.gd | `modulate.a` |

## Scene/Resource Format

| Godot 3 | Files | Godot 4 |
|---------|-------|---------|
| `format=2` | ALL .tscn/.tres files | `format=3` |
| `type="Script"` | All .tscn files | `type="GDScript"` |
| `ProceduralSky` sub_resource | default_env.tres | Sky + ProceduralSkyMaterial |
| Numeric enum values in scenes | Many scenes | Named constants |

## Theme/Style Override Properties

| Godot 3 | Godot 4 |
|---------|---------|
| `custom_fonts/font` | `theme_override_fonts/font` |
| `custom_styles/panel` | `theme_override_styles/panel` |
| `custom_constants/vseparation` | `theme_override_constants/vseparation` |

## OS/Miscellaneous

| Godot 3 | Files | Godot 4 |
|---------|-------|---------|
| `OS.get_ticks_msec()` | CardTemplate.gd | `Time.get_ticks_msec()` |
| `OS.get_name()` | Not confirmed but checked | `DisplayServer` |
| `get_tree().get_nodes_in_group()` | CardTemplate.gd | Same |
| `randomize()` / `randi()` / `rand_range()` | test_rng_seed.gd, CFUtils.gd | Auto-randomized; use `RandomNumberGenerator` for determinism |
| `get_tree().change_scene()` | Potential in MainMenu | `change_scene_to_file()` |
| `Thread.start(self, method, [args])` | GameStats.gd | `Thread.start(method.bind(args))` |

## GUT v7.3.0 → v9.7.0

| Godot 3 GUT (v7.3.0) | Godot 4 GUT (v9.7.0) |
|-------------|-------------|
| `yield_to()` / `yield_for()` | `wait_seconds()` / `wait_frames()` |
| `autoqfree()` | `add_child_autofree()` |
| `assert_connected()` | `assert_signal_emitted()` or `assert_connected()` (different sig) |
| `assert_freed()` | Removed |
| `assert_string_contains()` | Removed |
| Whole addon | Replaced entirely |
| `input_factory.gd` API (scancode) | Removed (use `InputEvent` directly) |
| Editor plugin registration | Different API |
| CLI: `gut_cmdln.gd -gdir ...` | Same but with `--headless` flag |

## New Godot 4 API Patterns Discovered

| Pattern | Files | Godot 4 Rule |
|---------|-------|-------------|
| `Button.pressed` (bool read) | CGFBoard.gd, CardViewer.gd | `Button.button_pressed` (`.pressed` is now the signal object) |
| Property getter reads own property | CardTemplate.gd | Use `_backing_var` in getter/setter to avoid recursion |
| `_ready()` without `super()` | Pile.gd, Hand.gd, CGFDeck.gd, CGFDiscard.gd, CGFHand.gd | Must call `super()` or parent init is skipped |
| `Window.size` is `Vector2i` | AskInteger.gd | Convert to `Vector2i` arithmetic when mixing with `Vector2` |
| `connect()` with duplicate callable | IntegerLineEdit.gd, AskInteger.gd | Use `is_connected()` guard or error at runtime |
| `popup_hide` signal | test_AskInteger_scene.gd | Removed from AcceptDialog/Window in Godot 4 |
| `Window.reset_min_size()` | Pile.gd | Use `reset_size()` for Window-based nodes |
| `Node.name` auto-renames siblings | Tests checking `card.name` | Check `canonical_name` instead; Node auto-suffixes duplicate sibling names |
| `RichTextLabel.append_text()` ≠ `.text` | CardFront.gd:_assign_bbcode_text | `append_text()` does NOT set `.text` property; use `rtlabel.text = formatted` |
| `move_to()` board code runs on pile/hand | CardTemplate.gd:move_to | Board-drop code (line 1334 `move_child` to last) ran unconditionally; wrapped in `else` |
| `has_node('Gut')` not matching | CGFBoard.gd | GUT v9.7.0 root node is `GutRunner`, not `Gut`; use `cfc.is_testing` |
| `wait_seconds` vs `process_frame` order | Test timing | `SceneTreeTimer` fires before `process_frame` in the same frame cycle |
| `get_class()` → engine class only | CardContainer tests | Godot 4 `get_class()` returns `"Area2D"`, not script `class_name`; use `is` or custom method |
| `Window.transparency` on embedded windows | Pile.gd | No-op on PopupPanel/popups; returns null from `tween_property`; use `modulate:a` on child Content |
| `Control.new().set_name()` overridden by `add_child` | Pile.gd | Internal name `@Control@NNN` overrides user-set name; set `name = "Foo"` AFTER `add_child()` |
| Signal `bind()` + typed function params | Pile.gd | `bind()` appends args after signal args; typed first param causes type coercion error |
| Control `layout_mode` anchor conflicts | Pile.gd | Default `layout_mode=1`; direct `position`/`size` triggers anchor warnings; set `layout_mode=0` |
| Godot 3 Tween nodes → orphaned overrides | UTBoard.tscn | Inherited scenes with `[node name="Tween"]` overrides cause "vanished" warnings after Tween removal |
| `tween_all_completed` signal removed | 24 test files (247 occurrences) | Godot 4 Tween uses `finished` signal, not `tween_all_completed` |
| `InputEvent.meta` property removed | UTcommon.gd | Godot 4 `InputEventMouseButton` has no `.meta`; remove unused assignment |
| `PopupPanel` has no `modulate` | test_piles.gd | Window-based PopupPanel lacks `modulate`; use `.visible` for visibility check |
| `card.get_node('Tween')` removes Tween node | 5 test files | Godot 3 Tween child nodes removed; use `card._tween` (member var from `create_tween()`) |
| `PropertyTweener.from()` returns null | CardTemplate.gd, Pile.gd | Returns null when parent Tween already started; capture and guard |
| `yield_to` on null tween | UTcommon.gd | GUT crashes on null object with `"get_signal_list in null instance"` |
| `Area2D` overlap signals in headless | All drag tests | `area_entered` may not fire in Godot 4 `--headless`; card focus state never set → drag stuck |
| `fancy_movement` deadlocks in headless | All integration tests | Tween `await _tween.finished` never resolves; disable via `cfc.game_settings.fancy_movement = false` |
| drag_drop bypass for headless | UTcommon.gd | `_find_container_at()` detects target by CollisionShape2D; `drag_drop` calls `move_to` directly |
| `global_position` stale after reparent+tween | CardTemplate.gd:move_to | Card position stays at hand coords after parent change to pile; needs editor debugging |
