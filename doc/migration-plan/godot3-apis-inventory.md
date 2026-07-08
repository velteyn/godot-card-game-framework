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

## GUT v7.3.0-specific

| Godot 3 GUT | Godot 4 GUT |
|-------------|-------------|
| `yield_to()` / `yield_for()` | Use `await` with GUT 4 equivalents |
| `autoqfree()` | `add_child_autofree()` |
| `assert_connected()` | May differ |
| `assert_freed()` | May differ |
| `assert_string_contains()` | May differ |
| Whole addon | Must be replaced |
| `input_factory.gd` API (scancode) | Must be updated |
| Editor plugin registration | Different API |
