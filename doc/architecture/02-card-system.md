# Card System

## Card Class (`src/core/CardTemplate.gd`)
- **Base**: `Area2D` (extends Area2D)
- **State Machine**: 16-state FSM via `CardState` enum
  - `IDLE`, `FOCUS`, `SELECTED`, `BOARD`, `HAND`, `PILE`, `DRAG`, `POPUP`
  - `DECKBUILDER_GRID`, `DECKBUILDER_DECK`, `JUST_DROPPED`, `FOCUSED_IN_HAND`
  - `MOVING_TO_CONTAINER`, `IN_HAND`, `IN_PILE`, `ON_BOARD`
- **Key Features**:
  - Face-up/down with flip animation (scale.x transition)
  - Drag & drop with physics-based movement (via `_input` events)
  - Board placement modes (FREE, ANY_GRID, SPECIFIC_GRID, GRID_AUTOPLACEMENT)
  - Attachment system (cards attach to each other, follow parent)
  - Ghost card system (transparent preview during drag)
  - Rotation support (90/180/270)
  - Targeting arrow system (Line2D + Polygon2D arrowhead)
  - Token drawer (ScrollContainer of Token HBoxContainers)
  - Manipulation buttons (dynamic, per-card-config)
- **Script Properties**: Dynamic dictionary-based property system (strings + numbers)
  - Properties defined in `ScriptProperties.gd` (~56KB)
  - CardConfig defines per-game properties (name, type, tags, cost, power, etc.)
- **Card Lifecycle**:
  - State transitions via `_determine_idle_state()`, `_process_state_*()`, `_exit_state_*()`
  - `move_to()` for container transfers with tween animations
  - `execute_scripts()` for scripting engine integration
  - `modify_property()` for runtime property changes

## CardFront (`src/core/Card/CardFront.gd`)
- **Base**: `Panel`
- Manages label mapping, font scaling, rich text labels with BBCode
- `set_label_text()` refreshes labels from card definitions
- `set_font_size()` handles font scaling per label
- Threaded text parsing for performance

## CardBack (`src/core/Card/CardBack.gd`)
- **Base**: `Panel`
- With subclasses: `CardBackGlow` (animated pulse), `CardBackTexture` (texture-based)
- `_determine_viewed_node()` for viewport focus integration
- `scale_to()` for viewport zoom support

## Card Scene (`CardTemplate.tscn`)
Structure:
```
Area2D "CardTemplate"
├── CollisionShape2D
└── Control "Control"
    ├── CardFront (Panel)
    │   └── Labels (RichTextLabel × N)
    ├── CardBack (Panel)
    ├── Highlight (ColorRect + Tween)
    ├── TokenDrawer (ScrollContainer)
    │   └── Token (HBoxContainer × N, dynamically created)
    ├── ManipulationButtons (VBoxContainer)
    │   └── Button (dynamically spawned from scenes)
    └── TargetingArrow (Line2D)
        └── Polygon2D "ArrowHead"
```
