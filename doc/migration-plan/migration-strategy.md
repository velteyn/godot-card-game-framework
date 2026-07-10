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

1. ~~Open project in Godot 4.7 editor~~ (DONE — loads without errors)
2. Fix any remaining script errors (IN PROGRESS)
3. Run test suite (IN PROGRESS — GUT v9.7.0 runs, partial passes)
4. Visual inspection of UI components
5. Test card interactions (drag, drop, focus, targeting)
6. Test scripting engine execution
7. Test deck builder / card library
8. Test all dialog scenes

## Current Status Summary

| Phase | Status |
|-------|--------|
| 1. Automated Conversion | ✅ Complete |
| 2. Manual GDScript Fixes | ✅ Complete |
| 3. Scenes & Resources | ✅ Complete |
| 4. GUT Testing Framework | ✅ Complete |
| 5. Project Settings | ✅ Complete |
| 6. Verification | 🔶 In Progress |

### Verification Progress

| Test File | Status | Notes |
|-----------|--------|-------|
| `test_card_class.gd` | ✅ 10/10 passing | 3 bugs fixed |
| `test_cardcontainer_class.gd` | ✅ 5/5 passing | Fixed get_class, child indices, tween signal |
| `test_pile_class.gd` | ✅ 6/6 passing | Fixed indices, popup return, shuffle signal, anchor warning |
| `test_AskInteger_scene.gd` | ✅ 3/3 passing | |
| `test_OptionalConfirmation_scene.gd` | ✅ 5/5 passing | |
| `test_DeckBuilder.gd` | ✅ 2/2 passing | |
| `test_token_class.gd` | ✅ 6/6 passing | |
| Integration tests | ❌ Mostly failing | Pre-existing Tween/signal migration issues |

## Key Godot 4 Pitfalls Discovered

### `_ready()` inheritance
Godot 4 does NOT automatically call parent `_ready()`. Every overridden `_ready()` must call `super()` explicitly, or the parent's initialization is skipped. This was the root cause of missing NMAP mappings: `CGFDeck._ready()` → `Pile._ready()` → `CardContainer._ready()` chain was broken.

### Property getter/setter recursion
In Godot 4, property access always goes through the getter/setter, even from within the class. If a getter calls a function that returns `property_name` and that property's getter calls the function, infinite recursion occurs. Fix: use a backing variable (`_property_name`) in getter/setter blocks.

### `Button.pressed` is now the signal object
`Control.pressed` was renamed to `Control.button_pressed` for the boolean property. In Godot 4, `Button.pressed` returns the signal object. This silently corrupts JSON-serialized game settings.

### `Window.size` is `Vector2i`
`Window.size` returns `Vector2i`, not `Vector2`. Mixing with `Vector2` in arithmetic operations causes runtime errors.

### `connect()` rejects duplicate callables
Unlike Godot 3, calling `connect()` with an already-connected callable raises an error. Use `is_connected()` guard when `_ready()` may be called multiple times (e.g., nodes moved between parents).

### `popup_hide` signal removed
`AcceptDialog`/`Window` no longer has a `popup_hide` signal in Godot 4. Use `close_requested` or `visibility_changed` instead.

### `Window.reset_min_size()` → `reset_size()`
PopupPanel (Window-based) has `reset_size()` not `reset_min_size()`.

### `Node.name` auto-renames duplicate siblings
Godot 4 silently appends a numeric suffix to `Node.name` when a sibling already has the same name. Godot 3 allowed duplicates. Tests checking `card.name` now fail. Fix: check `card.canonical_name` (the intended name, stored in a backing variable).

### `move_to()` board-drop code leaks into pile/hand moves
In `CardTemplate.gd:move_to()`, the code at lines 1309-1344 (setting board position, moving child to end, emitting `card_moved_to_board`) ran AFTER the hand/pile if/elif chain because it lacked an enclosing `else`. Line 1334 `get_parent().move_child(self, get_parent().get_child_count() - 1)` undid the custom index placement from line 1222-1224. Fix: wrap in `else`.

### `RichTextLabel.append_text()` doesn't set `.text`
In Godot 4, `append_text()` does not update the `text` property of `RichTextLabel`. Godot 3's `append_bbcode()` did. Reading `.text` after `append_text()` returns `""`. Fix: use `rtlabel.text = formatted` instead of `append_text()`.

### GUT v9.7.0 node name mismatch
GUT v9.7.0 creates a root node named `GutRunner` (not `Gut`). The original guard `has_node('Gut')` in `CGFBoard.gd:_ready()` never matched during tests, causing `load_test_cards(false)` to double-load the deck. Fix: use `cfc.is_testing`.

### `wait_seconds` vs `process_frame` timing
`SceneTreeTimer` (from `create_timer()`) fires BEFORE `process_frame` in the same frame cycle. Code that uses `await wait_seconds(0)` to "settle" the frame may observe incomplete UI state. A `process_frame` await is needed for `RichTextLabel` and other deferred operations.

### `get_class()` returns engine class, not script class_name
In Godot 4, `Object.get_class()` only returns the engine-level class name (e.g., `"Area2D"`), never a script-defined `class_name`. Use `is` keyword for type checks or a custom method.

### `Window.transparency` no-op on embedded windows
In Godot 4, `Window.transparency` has no effect on embedded windows (popups/dialogs). `tween_property($ViewPopup, 'transparency', ...)` returns null, crashing subsequent `.from()` calls. Fix: animate `modulate:a` on the popup's content child instead.

### `Control.new().set_name()` overridden by `add_child`
In Godot 4, `Control.new().set_name("Foo")` followed by `add_child()` results in internal names like `@Control@212`. Set `name = "Foo"` AFTER `add_child()`.

### Signal `bind()` type coercion with typed functions
`bind()` appends bound arguments after signal-emitted arguments. If the target function has typed parameters and the combined args don't match types, a "Cannot convert argument N" error occurs. Fix: use a lambda wrapper.

### Control `layout_mode` anchor conflicts
Controls default to `layout_mode = 1` (anchors mode). Direct `position`/`size` assignments trigger engine warnings. Set `layout_mode = 0` for Controls under non-Control parents (e.g., Area2D).

### Godot 3 Tween nodes → orphaned scene overrides
Inherited scenes that overrode removed Tween nodes produce "node was modified from inside an instance, but it has vanished" warnings. Remove orphaned `[node name="Tween"]` entries.

## Risks & Considerations

1. **Tween animations**: The entire card movement system relies on the old Tween API. This is the most pervasive change.
2. **Yield-heavy code**: The scripting engine and test suite use `yield` extensively. All must be converted to `await`.
3. **Scene inheritance**: Complex scene inheritance chains may need manual fixes after conversion.
4. **Custom class registration**: Godot 4 handles this differently—scripts with `class_name` are auto-registered.
5. **GUT addon**: The Godot 3 addon must be completely replaced.
6. **Viewport changes**: `Viewport` → `SubViewport` may affect the card focus system.
7. **Input handling**: Right-click detection and targeting arrow input may need rework.
8. **Rect property changes**: All `rect_*` properties on Control nodes must be updated.
