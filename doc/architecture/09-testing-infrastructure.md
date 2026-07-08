# Testing Infrastructure

## GUT v7.3.0 (Godot 3 Version)
- Located in `addons/gut/` — full test framework addon (~30+ files)
- **Plugin**: Registered in `project.godot` as `[editor_plugins] enabled=PoolStringArray("gut")`
- **Config**: `.gutconfig.json` — dirs: `res://tests/unit` and `res://tests/integration`
- **Key classes**:
  - `gut.gd` — Main test runner (1676 lines)
  - `test.gd` — Test base class with assert methods (1651 lines)
  - `plugin_control.gd` — Editor plugin control
  - `gut_plugin.gd` — EditorPlugin registration
  - `doubler.gd` — Script doubling
  - `input_factory.gd` / `input_sender.gd` — Input simulation
  - `signal_watcher.gd` — Signal monitoring

## Test Structure
```
tests/
├── UTcommon.gd                     ← Base test utility (UTCommon class)
├── Basic_common.gd                 ← Test with board + 5 cards before_each
├── Attachment_common.gd            ← Test with attachment mode
├── ScEng_common.gd                 ← Scripting engine test commons
├── tests.tscn                      ← GUT main runner scene
├── UTMain.tscn                     ← Test main scene (inherits Main.tscn)
├── UTBoard.tscn                    ← Test board scene (~232 lines)
├── cli/
│   ├── tests.tscn                  ← CLI test runner
│   └── cli_plugin.gd              ← CLI plugin (auto-quit after tests)
├── unit/ (10 files)
│   ├── test_card_class.gd
│   ├── test_cardcontainer_class.gd
│   ├── test_pile_class.gd
│   ├── test_token_class.gd
│   ├── test_cardfilter.gd
│   ├── test_BoardPlacementGrid_class.gd
│   ├── test_DeckBuilder.gd
│   ├── test_AskInteger_scene.gd
│   ├── test_CardChoices_scene.gd
│   ├── test_OptionalConfirmation_scene.gd
│   └── test_utils.gd
└── integration/ (21 files)
    ├── test_anchors.gd
    ├── test_attachments.gd
    ├── test_board_use.gd
    ├── test_card_draw.gd
    ├── test_card_index.gd
    ├── test_facedown.gd
    ├── test_manipulation_buttons.gd
    ├── test_mouse_pointer.gd
    ├── test_piles.gd
    ├── test_placement_grid.gd
    ├── test_reshuffle_all.gd
    ├── test_rng_seed.gd
    ├── test_scaling_focus.gd
    ├── test_targetting.gd
    ├── test_tokens.gd
    ├── test_viewport_focus.gd
    └── test_scripting_engine_*.gd (7 files)
```

## Godot 3-specific Testing APIs Used
- `yield`, `yield_to()`, `yield_for()` for async test coordination
- `GDScriptFunctionState` checks (`confirm_return is GDScriptFunctionState`)
- `BUTTON_LEFT` constant
- `InputEventMouseButton` manual creation
- `assert_almost_eq()`, `assert_signal_emitted()`, `assert_connected()`, `assert_freed()`, `assert_typeof()`
- `autoqfree()` → `add_child_autofree()`
- `watch_signals()` — signal monitoring
- `.instance()` for scene instantiation
