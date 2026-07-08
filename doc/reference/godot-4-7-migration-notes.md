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
