# Godot 3 vs Godot 4 API Cheatsheet

## Annotations

| Godot 3 | Godot 4 |
|---------|---------|
| `tool` | `@tool` |
| `export var x` | `@export var x` |
| `export var x := 5` | `@export var x := 5` |
| `export(int, 0, 10) var x` | `@export_range(0, 10) var x` |
| `export(String, FILE) var x` | `@export_file var x` |
| `export(String, DIR) var x` | `@export_dir var x` |
| `export(String, MULTILINE) var x` | `@export_multiline var x` |
| `export(Color) var x` | `@export var x: Color` |
| `onready var x = $Path` | `@onready var x = $Path` |

## Signals

| Godot 3 | Godot 4 |
|---------|---------|
| `connect("sig", obj, "method")` | `sig.connect(method)` |
| `disconnect("sig", obj, "method")` | `sig.disconnect(method)` |
| `emit_signal("sig", args)` | `sig.emit(args)` |
| `is_connected("sig", obj, "method")` | `sig.is_connected(method)` |

## yield -> await

| Godot 3 | Godot 4 |
|---------|---------|
| `yield(get_tree(), "idle_frame")` | `await get_tree().process_frame` |
| `yield(get_tree().create_timer(1), "timeout")` | `await get_tree().create_timer(1.0).timeout` |
| `yield(obj, "completed")` | `await obj` |
| `var x = yield(some_func())` | `var x = await some_func()` |
| `has_method(obj, "method")` | No GDScriptFunctionState needed |

## Setters/Getters

| Godot 3 | Godot 4 |
|---------|---------|
| `var x setget set_x, get_x` | `var x: int: set(value): x = value; get: return x` |

### ⚠️ Property Recursion in Godot 4
In Godot 4, property getters/setters always go through themselves from within the class. You CANNOT do:
```gdscript
# BAD — infinite recursion
var name: String: get: return get_name()
func get_name() -> String:
    return name  # calls getter again!
```
Use a **backing variable**:
```gdscript
var _name := ""
var name: String:
    get: return _name
    set(value): set_name(value)
func set_name(value: String) -> void:
    _name = value  # never use `name = value` here
```

## Scenes/PackedScene

| Godot 3 | Godot 4 |
|---------|---------|
| `preload("res://scene.tscn").instance()` | `preload("res://scene.tscn").instantiate()` |
| `scene.instance()` | `scene.instantiate()` |

## File I/O

| Godot 3 | Godot 4 |
|---------|---------|
| `var f = File.new()` | `var f = FileAccess.open(path, FileAccess.READ)` |
| `f.open(path, File.READ)` | (done in open) |
| `f.get_as_text()` | `f.get_as_text()` (same) |
| `f.close()` | `f.close()` (same) |
| `var d = Directory.new()` | `DirAccess.dir_exists(path)` (static) |
| `d.open(path)` | `DirAccess.open(path)` |
| `d.dir_exists(path)` | `DirAccess.dir_exists_absolute(path)` |

## JSON

| Godot 3 | Godot 4 |
|---------|---------|
| `JSON.parse(str)` | `JSON.new().parse(str)` |
| `JSON.print(data)` | `JSON.new().stringify(data)` |
| `result.result` | `result.data` |

## Input

| Godot 3 | Godot 4 |
|---------|---------|
| `BUTTON_LEFT` | `MOUSE_BUTTON_LEFT` |
| `BUTTON_RIGHT` | `MOUSE_BUTTON_RIGHT` |
| `event.scancode` | `event.keycode` or `event.physical_keycode` |
| `str.to_ascii()[0]` | `str.to_ascii_buffer()[0]` |

## Control/Button Nodes

| Godot 3 | Godot 4 |
|---------|---------|
| `rect_position` | `position` |
| `rect_size` | `size` |
| `rect_rotation` | `rotation` |
| `rect_scale` | `scale` |
| `rect_min_size` | `custom_minimum_size` |
| `margin_left/top/right/bottom` | `offset_left/top/right/bottom` |
| `modulate[3]` | `modulate.a` |
| `self_modulate[3]` | `self_modulate.a` |
| `custom_fonts/font` | `theme_override_fonts/font` |
| `custom_styles/panel` | `theme_override_styles/panel` |
| `Button.pressed` (bool) | `Button.button_pressed` (`.pressed` is now the signal object!) |
| `Window.size` (Vector2) | `Window.size` is `Vector2i` |

## Tween

| Godot 3 | Godot 4 |
|---------|---------|
| `$Tween.interpolate_property(obj, prop, from, to, time, trans, ease)` | `create_tween().tween_property(obj, prop, to, time)` |
| `$Tween.start()` | Auto-started |
| `yield($Tween, "tween_all_completed")` | `await tween.finished` |
| `$Tween.stop_all()` | `tween.kill()` |

## Types

| Godot 3 | Godot 4 |
|---------|---------|
| `PoolStringArray` | `PackedStringArray` |
| `PoolByteArray` | `PackedByteArray` |
| `PoolIntArray` | `PackedInt32Array` |
| `PoolRealArray` | `PackedFloat32Array` |
| `PoolVector2Array` | `PackedVector2Array` |
| `PoolColorArray` | `PackedColorArray` |
| `StreamTexture` | `CompressedTexture2D` |
| `Viewport` | `SubViewport` |
| `ViewportContainer` | `SubViewportContainer` |
| `Spatial` | `Node3D` |
| `Sprite` | `Sprite2D` |
| `Area` | `Area2D` (2D) / `Area3D` (3D) |
| `KinematicBody2D` | `CharacterBody2D` |
| `RigidBody2D` | `RigidBody2D` (same) |

## _ready() Lifecycle

| Godot 3 | Godot 4 |
|---------|---------|
| Parent `_ready()` implicitly called | **Must call `super()` explicitly** |
| `func _ready(): pass` | `func _ready(): super() # calls parent's _ready()` |

If you override `_ready()` in a child class (especially `CardContainer` → `Pile` → `CGFDeck`), the parent's initialization code — including `@onready` var resolution and `cfc.map_node(self)` — will NOT run unless you call `super()`.

## Window/Popup Changes

| Godot 3 | Godot 4 |
|---------|---------|
| `popup_hide` signal | Removed. Use `close_requested` or `visibility_changed` instead |
| `Window.reset_min_size()` | `Window.reset_size()` (PopupPanel is Window-based) |
| `Window.size` (Vector2) | `Window.size` is `Vector2i` |

## Miscellaneous

| Godot 3 | Godot 4 |
|---------|---------|
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` |
| `OS.get_screen_size()` | `DisplayServer.screen_get_size()` |
| `OS.get_name()` | `DisplayServer.get_name()` |
| `get_tree().change_scene(path)` | `get_tree().change_scene_to_file(path)` |
| `CanvasItem.update()` | `queue_redraw()` |
| `Array.empty()` | `Array.is_empty()` |
| `Array.invert()` | `Array.reverse()` |
| `Node.filename` | `Node.scene_file_path` |
| `EditorPlugin.add_custom_type(...)` | Different signature |
| `FileDialog.mode` | `FileDialog.file_mode` |
| `String.right(pos)` | Changed behavior (use `substr()`) |

## Resources & Themes

| Godot 3 | Godot 4 |
|---------|---------|
| `DynamicFont` / `DynamicFontData` | `FontFile` (unified type, auto-detected from .ttf/.otf source) |
| Binary `.theme` files (header `RSRC`) | Text-based `.tres` theme files (`type="Theme"`, `format=3`) |
| `stylebox_styles` / `custom_styles` | `theme_override_styles/*` |
| `font_styles` / `custom_fonts` | `theme_override_fonts/*` |
| `color_styles` / `custom_colors` | `theme_override_colors/*` |
| `constant_styles` / `custom_constants` | `theme_override_constants/*` |
| `.res` binary font resources | Use `.ttf`/`.otf` directly with `FontFile` |

## Tween System Changes

| Godot 3 | Godot 4 |
|---------|---------|
| `Tween` as child `Node` in scene | `create_tween()` creates unattached Tween object |
| Tween persists after completion | **Tween auto-deletes** after `finished` signal emits |
| `tween_all_completed` signal | `finished` signal |
| `$Tween.interpolate_property(node, prop, from, to, dur)` | `create_tween().tween_property(node, prop, to, dur).from(from)` |
| `$Tween.start()` | Auto-started (no explicit start call) |
| State machine guard `if _tween.is_running()` | Add `state_finalized` flag — `is_running()` returns `false` after auto-delete |

## GDScript Reserved Keywords

| Godot 3 | Godot 4 |
|---------|---------|
| `class_name` can be a variable name | `class_name` is **reserved** for script class declarations |
| `get_class()` returns script `class_name` | `get_class()` returns engine-level class only (e.g., `"Area2D"`). Use `is` for type checks |

## Core Object Access

| Godot 3 | Godot 4 |
|---------|---------|
| `get_tree()` works on any `Object` | Only available on `Node` subclasses. For `RefCounted`: use `Engine.get_main_loop()` |

## Font Path Conventions

| Godot 3 | Godot 4 |
|---------|---------|
| `res://fonts/Comfortaa-Bold.ttf` (flat structure) | Fonts may be moved to subdirectories: `res://fonts/comfortaa/Comfortaa-Bold.ttf` |
| Ext_resource `type="DynamicFontData"` | Ext_resource `type="FontFile"` (uses same .ttf source file) |
