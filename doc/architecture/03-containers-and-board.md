# Containers & Board System

## CardContainer (`src/core/CardContainer.gd`)
- **Base**: `Area2D`
- **Parent class** for Hand and Pile
- **Anchor System**: `Anchors` enum (TOP_LEFT, TOP_CENTER, TOP_RIGHT, MIDDLE_LEFT, MIDDLE_CENTER, MIDDLE_RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT)
- **Features**:
  - Card overlap management with configurable shift direction
  - Max card width constraints (`max_card_width`)
  - `move_to_container()` triggered on Area2D overlap
  - Manipulation buttons (configurable per container type)
  - Shuffle button on piles
  - Signals: `card_added`, `card_removed`, `mouse_entered`, `mouse_exited`, `pressed`

## Hand (`src/core/Hand.gd`)
- **Base**: `extends CardContainer`
- **Features**:
  - `max_hand_size` limit with `ExcessCardsBehaviour` (DISALLOW, ALLOW, DISCARD_DRAWN, DISCARD_OLDEST)
  - `draw_card()` method with animated card drawing
  - Oval hand layout support
  - `rebuild_hand_position()` for reorganization
  - Override anchor for top/draw from bottom

## Pile (`src/core/Pile.gd`)
- **Base**: `extends CardContainer`
- **Features**:
  - Stack positioning (`get_stack_position()`)
  - Shuffle animations: CORGI, SPLASH, SNAP, OVERHAND
  - Popup view (grid layout showing all cards)
  - Sort modes (NAME, COST, TYPE, POWER)
  - `faceup_cards` property
  - Signals: `shuffled`

## Board (`src/core/BoardTemplate.gd`)
- **Base**: `extends Control`
- **Features**:
  - Central area where cards are placed in free-form or grid slots
  - References MousePointer instance for hover detection
  - `get_all_cards()`, `get_grid()`, `get_final_placement_node()`
  - Reshuffle all piles functionality
  - Fancy movement toggle for smooth vs instant card movement
  - Debug toggle, seed display

## BoardPlacementGrid / BoardPlacementSlot
- **Grid**: `extends Control` — Manages a grid of slots
- **Slot**: `extends Control` — Individual slot that can hold one card
- Supports ANY_GRID, SPECIFIC_GRID, GRID_AUTOPLACEMENT modes
- Slot highlighting, occupied slot detection
- Grid auto-extension

## MousePointer (`src/core/MousePointer.gd`)
- **Base**: `Area2D`
- Workaround for Godot bugs #16854 and #44138
- Detects hover over cards and containers
- Used for highlighting and drag-drop target detection
