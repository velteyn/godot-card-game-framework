# Godot 3.x → 4.7 Migration Strategy

## Prerequisites
- Godot 4.7 binary: `/home/velteyn/.local/bin/godot47` (4.7.stable)
- Godot online docs: https://docs.godotengine.org/en/4.7/
- Project backed up in git (branch)

## Phase 1: Automated Conversion

### Step 1: Validate conversion
```bash
/home/velteyn/.local/bin/godot47 --path /home/velteyn/projects/godot-card-game-framework --validate-conversion-3to4
```

### Step 2: Run conversion tool
```bash
/home/velteyn/.local/bin/godot47 --path /home/velteyn/projects/godot-card-game-framework --convert-3to4
```

### What the tool handles automatically:
- Scene/resource format conversion (`format=2` → `format=3`)
- Node renames (Area → Area2D, Sprite → Sprite2D, etc.)
- Property renames (`rect_position` → `position`, `rect_size` → `size`, etc.)
- `instance()` → `instantiate()` in most cases
- `FILE`/`DIR` export hints
- `PoolStringArray` → `PackedStringArray`
- Some `yield` → `await` conversions

### What the tool does NOT handle:
- `yield` → `await` (only partial)
- `GDScriptFunctionState` checks
- `setget` → inline getter/setter
- `tool` → `@tool` on built-in scripts
- `export var` → `@export var` (only partial)
- `onready var` → `@onready var` (only partial)
- `Tween` node → `create_tween()` API
- String signal connections → callables
- `File`/`Directory` → `FileAccess`/`DirAccess`
- `BUTTON_LEFT` → `MOUSE_BUTTON_LEFT`
- `scancode` → `keycode`/`physical_keycode`
- `InputEventKey`/`InputEventMouseButton` structure changes
- `rect_rotation` → `rotation` (Control)
- `modulate[3]` → `modulate.a`
- `.to_ascii()[0]` → `.to_ascii_buffer()[0]`
- JSON.parse/print changes
- `OS.get_ticks_msec()` → `Time.get_ticks_msec()`
- `OS.get_name()` → DisplayServer (if used)
- Callback in Thread.start changed
- GUT addon (must be replaced entirely)

## Phase 2: Manual GDScript Fixes

### Priority 1 — Compilation blockers
1. `yield` → `await` throughout all `.gd` files
2. `GDScriptFunctionState` type checks → remove or use `await`
3. `export` → `@export` (all variants: `@export_range`, `@export_file`, `@export_dir`, `@export_multiline`)
4. `onready` → `@onready`
5. `tool` → `@tool`
6. `setget` → inline setter/getter blocks
7. `.instance()` → `.instantiate()` (remaining)
8. `func .parent_method()` → `super.parent_method()`

### Priority 2 — API changes
1. Tween: `$Tween.interpolate_property(...)` → `create_tween().tween_property(...)`
2. Signal connections: `connect("signal", obj, "method")` → `signal.connect(method)`
3. `File.new()` / `Directory.new()` → `FileAccess` / `DirAccess`
4. `JSON.parse()` / `JSON.print()` → `JSON.new().parse()` / `.stringify()`
5. `BUTTON_LEFT` → `MOUSE_BUTTON_LEFT` (and similar)
6. `scancode` → `keycode` or `physical_keycode`
7. `PoolStringArray` → `PackedStringArray` (remaining)
8. Color alpha: `modulate[3]` → `modulate.a`
9. `rect_rotation` → `rotation` (on Control)
10. `rect_scale` → `scale` (on Control)
11. `rect_position` → `position` (on Control)
12. `rect_size` → `size` (on Control)
13. `rect_min_size` → `custom_minimum_size`

### Priority 3 — Code improvements
1. Typed arrays: `var x = []` → `var x: Array[Type] = []`
2. StringName for constant strings: `"string"` → `&"string"`
3. Signal objects: `emit_signal("name")` → `name.emit()`
4. Parent lifecycle calls: add `super()` in `_ready()`, `_process()`, etc.

## Phase 3: Scenes & Resources

1. Re-save all `.tscn` and `.tres` files (done by conversion tool)
2. Fix any custom font/style paths (`custom_fonts` → `theme_override_fonts`)
3. Fix any hardcoded enum values in scenes
4. Update `default_env.tres` (ProceduralSky → Sky + ProceduralSkyMaterial)

## Phase 4: GUT Testing Framework

1. Remove `addons/gut/` entirely (Godot 3 version)
2. Install Godot 4-compatible GUT (latest from asset library or GitHub)
3. Update test scripts:
   - `yield` → `await`
   - `yield_to()` / `yield_for()` → GUT 4 equivalents
   - `autoqfree()` → `add_child_autofree()` (if not already)
   - `GDScriptFunctionState` checks removed
   - `BUTTON_LEFT` → `MOUSE_BUTTON_LEFT`
   - `.instance()` → `.instantiate()`
4. Update `.gutconfig.json` for GUT 4 format
5. Update `tests.tscn` and `tests/cli/tests.tscn` for GUT 4

## Phase 5: Project Settings

1. Remove `_global_script_classes` and `_global_script_class_icons` from project.godot (class_name handles this in Godot 4)
2. Update input map (`scancode` → `keycode`)
3. Remove `[editor_plugins]` (GUT 4 uses different plugin system)
4. Update `[display]` section if needed
5. Update `[rendering]` section

## Phase 6: Verification

1. Open project in Godot 4.7 editor
2. Fix any remaining script errors
3. Run test suite
4. Visual inspection of UI components
5. Test card interactions (drag, drop, focus, targeting)
6. Test scripting engine execution
7. Test deck builder / card library
8. Test all dialog scenes

## Risks & Considerations

1. **Tween animations**: The entire card movement system relies on the old Tween API. This is the most pervasive change.
2. **Yield-heavy code**: The scripting engine and test suite use `yield` extensively. All must be converted to `await`.
3. **Scene inheritance**: Complex scene inheritance chains may need manual fixes after conversion.
4. **Custom class registration**: Godot 4 handles this differently—scripts with `class_name` are auto-registered.
5. **GUT addon**: The Godot 3 addon must be completely replaced.
6. **Viewport changes**: `Viewport` → `SubViewport` may affect the card focus system.
7. **Input handling**: Right-click detection and targeting arrow input may need rework.
8. **Rect property changes**: All `rect_*` properties on Control nodes must be updated.
