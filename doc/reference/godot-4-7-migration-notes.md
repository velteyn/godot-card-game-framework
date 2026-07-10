# Godot 4.7 Migration Notes

Source: https://docs.godotengine.org/en/4.7/tutorials/migrating/

## Overview

Godot 4.7 has minimal breaking changes from 4.6. The main migration effort is from Godot 3 to 4.

## Key 4.7-specific Changes

### Control offset transforms (new in 4.7)
- Control nodes support offset transforms for animated UI
- May affect animated Control nodes (popup menus, manipulation buttons)

### Input device IDs changed
- Mouse/keyboard device IDs changed from 0 to InputEvent.DEVICE_ID_MOUSE and InputEvent.DEVICE_ID_KEYBOARD
- Check InputEvent.device by type or compare to these constants

### GDScript changes in 4.7
- Setting packed array elements no longer calls the array setter
- Methods inheriting typed return types now require explicit return in override

### Rendering changes in 4.7
- ImageTexture.get_format moved to Texture2D base class
- Particle methods added process_time_residual parameter

## Specific Issues Found in This Codebase

### Button.pressed → button_pressed
In Godot 4, `Button.pressed` returns the **signal object** (`"CheckButton::[signal]pressed"`), not the boolean pressed state. Use `Button.button_pressed` instead. This was found in:
- `CGFBoard.gd` — reading toggle state
- `CardViewer.gd` — reading button state
- Corrupted `CGFSettings.json` with serialized signal objects

### Property Getter/Setter Recursion
Godot 4 property getters/setters always route through themselves from within the class. When a getter returns `property_name` and that property's getter calls `get_function()` which returns `property_name`, infinite recursion occurs. Fix by using a `_backing_var`:
```gdscript
var _card_name := ""
var canonical_name: String:
    get: return _card_name
    set(value): set_card_name(value)
func set_card_name(val: String) -> void:
    _card_name = val  # NOT canonical_name = val
```

Found in: `CardTemplate.gd` (`canonical_name`, `card_rotation`, `card_size`, `state`, `is_faceup`)

### _ready() super() Chaining
In Godot 4, `_ready()` does NOT automatically call the parent class `_ready()`. If any node in the inheritance chain overrides `_ready()` without calling `super()`, the entire chain above it is skipped. This was breaking `cfc.map_node(self)` calls in `CardContainer._ready()`.

Affected nodes: `Pile`, `Hand`, `CGFDeck`, `CGFDiscard`, `CGFHand`

### Window.size is Vector2i
In Godot 4, `Window.size` returns `Vector2i`. Mixing with `Vector2` operands causes `Invalid operands 'Vector2i' and 'Vector2'` errors. Found in: `AskInteger.gd:34`

### connect() Rejects Duplicates
Calling `connect()` with an already-connected callable raises an error. Use `is_connected()` before `connect()` when `_ready()` may be called multiple times (e.g., nodes re-parented). Found in: `IntegerLineEdit.gd`, `AskInteger.gd`

### popup_hide Signal Removed
`AcceptDialog`/`Window` no longer has a `popup_hide` signal. Use `close_requested` or `visibility_changed`. Found in: `test_AskInteger_scene.gd`

### Window.reset_min_size() → reset_size()
PopupPanel extends Window in Godot 4. `Window` has `reset_size()`, not `reset_min_size()`. Found in: `Pile.gd`

### Node.name auto-renames on duplicate siblings
In Godot 4, setting `node.name = "Foo"` when a sibling already named "Foo" exists **silently auto-renames** the node (e.g., → "Foo@2", "Foo3", "Foo_4", etc.). Godot 3 allowed duplicate sibling names. This means `Node.name` can diverge from the intended canonical name.

**Impact:** Tests that checked `card.name` (Node name) against expected values now fail when multiple cards share the same name. Fix: check `card.canonical_name` instead, which holds the intended name unaffected by auto-renaming.

Found in: `test_card_class.gd:test_init_card_name`, `test_cardcontainer_class.gd`, `test_pile_class.gd`

### RichTextLabel.append_text() doesn't update .text
In Godot 4, `RichTextLabel.append_text(bbcode)` does NOT update the `text` property. The `text` property remains an empty string even after `append_text()`. In Godot 3, `append_bbcode()` (the Godot 3 equivalent) did update `text`.

**Impact:** Code that reads `rtlabel.text` after `append_text()` will see an empty string. Fix: use `rtlabel.text = formatted` instead of `append_text()`.

Found in: `CardFront.gd:_assign_bbcode_text` at line 175

### Card move_to board-drop code leaks into hand/pile moves
In `CardTemplate.gd:move_to()`, the board-drop-specific code at lines 1309-1344 (including `get_parent().move_child(self, get_parent().get_child_count() - 1)` at line 1334) ran **unconditionally** after the hand/pile `if/elif` chain. This undid the `move_child()` call that placed the card at the requested index when moving to a pile.

**Fix:** Wrap the board-drop block in an `else` clause attached to the `if targetHost.is_in_group("hands") / elif targetHost.is_in_group("piles")` chain, so it only executes for board drops.

### GUT runner node name
The original guard `if not get_tree().get_root().has_node('Gut')` in `CGFBoard.gd:_ready()` never matched because GUT v9.7.0's root node is named **"GutRunner"**, not "Gut". This caused `load_test_cards(false)` to run during tests, doubling the deck size.

**Fix:** Changed to `if not cfc.is_testing` which correctly detects the test environment.

### wait_seconds timer fires before process_frame
In Godot 4, `SceneTreeTimer` (from `create_timer()`) fires before `process_frame` in the same frame cycle. This means `await wait_seconds(0)` resolves BEFORE `await get_tree().process_frame`. Code that depends on `wait_seconds` to "settle" UI state may observe inconsistent results — a `process_frame` wait is needed for `RichTextLabel` updates and other deferred operations.

### get_class() returns engine class, not script class_name
In Godot 4, `Object.get_class()` only returns the engine-level class name (e.g., `"Area2D"`), never a script-defined `class_name`. Godot 3 had the same behavior for engine classes but scripts could override via `_get_class()`. Tests checking `container.get_class()` against `"CardContainer"` fail because the return is `"Area2D"`. Fix: use `is CardContainer` for type checks, or call a custom method like `get_card_container_class()`.

### Window.transparency no-op on embedded windows
In Godot 4, `Window.transparency` has no effect on embedded windows (popups/dialogs). When `tween_property($ViewPopup, 'transparency', ...)` runs on a PopupPanel, the property is invalid and the tween returns null. The subsequent `.from()` call crashes with `"Cannot call method 'from' on a null value"`. Fix: animate `modulate:a` on the popup's content child (`$ViewPopup/CardView`) instead of `transparency` on the Window.

### Control.new().set_name() overridden by add_child
In Godot 4, calling `Control.new().set_name("Foo")` followed by `add_child(node)` results in the node's name being an internal engine name like `@Control@212` instead of the intended `"Foo"`. The engine overrides the pre-add_child name. Fix: set `node.name = "Foo"` AFTER `add_child(node)`.

Found in: `Pile.gd:_slot_card_into_popup` — CardPopUpSlot naming for popup card detection.

### Signal bind() type coercion with typed functions
In Godot 4, `signal.connect(target_fn.bind(extra_args))` appends bound arguments AFTER any signal-emitted arguments. When the target function has typed parameters, the combined argument list must match. For `shuffle_completed.connect(cfc.signal_propagator._on_signal_received.bind("shuffle_completed", {src: name}))`, the signal emits `(self)` and the bound args are `("shuffle_completed", {})`, so the call is `_on_signal_received(self, "shuffle_completed", {})`. Since `_on_signal_received` expects first param `Card`, passing a Pile/Hand Node fails type checking with "Cannot convert argument 1 from Object to Object". Fix: use a lambda wrapper `func(source): propagate._on_signal_received(null, "shuffle_completed", {})` that discards the signal arg and provides explicit args.

Found in: `Pile.gd:_ready` shuffle_completed connection.

### Control layout_mode conflicts with direct position/size
In Godot 4, Controls default to `layout_mode = 1` (anchors mode). Setting `position` or `size` directly on a Control with anchors mode active triggers `"Nodes with non-equal opposite anchors will have their size overridden after _ready()"` engine warnings. For Controls parented under Area2D nodes (not using the Control layout system), set `layout_mode = 0` before performing direct position/size manipulation.

Found in: `Pile.gd:reorganize_stack` — `$Control.size` and `$Control.position` assignments.

### Godot 3 Tween nodes leave orphaned scene overrides
The Godot 3 Pile.tscn included `Tween` child nodes for animation. During migration these were removed (Godot 4 uses `create_tween()`). Inherited scenes like UTBoard.tscn that overrode those specific Tween nodes now produce warnings: `"node was modified from inside an instance, but it has vanished"`. Fix: remove orphaned `[node name="Tween" ...]` entries from inheriting scenes.

## Documentation Links

- Godot 3 to 4 migration: https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.html
- GDScript basics: https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/gdscript_basics.html
- GDScript exports: https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/exports.html
- Tween system: https://docs.godotengine.org/en/4.7/classes/class_tween.html
- FileAccess: https://docs.godotengine.org/en/4.7/classes/class_fileaccess.html
- DirAccess: https://docs.godotengine.org/en/4.7/classes/class_diraccess.html
- InputEvent: https://docs.godotengine.org/en/4.7/classes/class_inputevent.html
- SubViewport: https://docs.godotengine.org/en/4.7/classes/class_subviewport.html
- JSON: https://docs.godotengine.org/en/4.7/classes/class_json.html
