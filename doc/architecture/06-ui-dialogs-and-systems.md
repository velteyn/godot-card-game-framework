# UI Dialogs & Supporting Systems

## Dialog Scenes
All in `src/core/`:

| File | Base | Purpose |
|------|------|---------|
| `SelectionWindow.gd/.tscn` | AcceptDialog | Card selection with min/equal selection modes |
| `OptionalConfirmation.gd/.tscn` | ConfirmationDialog | Yes/No confirmation with is_accepted flag |
| `AskInteger.gd/.tscn` | AcceptDialog | Integer input with validation |
| `CardChoices.gd/.tscn` | PopupMenu | Multi-option popup for card scripts |
| `IntegerLineEdit.gd` | LineEdit | Integer-only text input with regex validation |
| `DetailPanels.gd/.tscn` | GridContainer | Card info panels for tags/keywords/illustration |

## Supporting Systems

### Counters (`src/core/Counters.gd`)
- **Base**: `Control`
- Dictionary of named integer counters
- `mod_counter()` with temp modifier support
- Value label management

### Token (`src/core/Token.gd` + `.tscn`)
- **Base**: HBoxContainer
- Individual token with +/- buttons, counter label
- Min/max validation
- Expand/retract for compact display
- Lowercase name normalization

### Highlight (`src/core/Highlight.gd` + `.tscn`)
- ColorRect with Tween modulate animation
- Used for hover effects on cards and containers

### ViewportCardFocus (`src/core/ViewportCardFocus.gd`)
- **Base**: Node2D
- Creates a duplicate card in a SubViewport for detailed view
- Scales, rotates, and displays card properties
- Info panel integration for tags/keywords
- Handles face-down card display

### GameStats (`src/core/GameStats.gd`)
- **Base**: `Reference`
- HTTP stats submission via Thread
- HTML5 fallback using `yield(get_tree(), "idle_frame")`
- CGF-Stats server integration

### OverridableUtils (`src/core/OverridableUtils.gd`)
- **Base**: `Reference`
- Extension points for game-specific overrides
- `execute_task_subject_selection()`, `populate_card_info_panels()`, `get_task_subject()`

### CardFilter (`src/core/Utils/CardFilter.gd`)
- **Base**: `Reference`
- Property comparison engine with typed comparisons and regex
- Used by scripting engine and deck builder filters

### CFUtils (`src/core/CFUtils.gd`)
- Static utilities: `shuffle_array()`, `random_seed_generator()`, array join, directory listing
- Confirmation dialog generation

### CFInt (`src/core/CFInt.gd`)
- Internal enums: RunType, FocusStyle, OverlapShiftDirection, IndexShiftPriority
