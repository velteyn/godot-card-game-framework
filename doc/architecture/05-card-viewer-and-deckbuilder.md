# Card Viewer & Deck Builder

## CardViewer (`src/core/CardViewer/CardViewer.gd`)
- **Base**: `PanelContainer` (extends `PanelContainer`, class_name `CardViewer`)
- Grid/list view toggle
- Card search/filter
- Preload selection
- Sub-components:
  - `CVGridCardObject.gd` (CenterContainer) — Grid display
  - `CVListCardObject.gd` (HBoxContainer) — List display
  - `CVFilter.gd` — Filter logic engine
  - `CVFilterButton.gd` (Button) — Filter toggle buttons
  - `CVFilterLine.gd` (LineEdit) — Text filter input
  - `CVPreviewPopup.gd` (Popup) — Card preview on hover
  - `CardLabel.gd` (RichTextLabel) — Card label component

## CardLibrary (`src/core/CardViewer/CardLibrary/CardLibrary.gd`)
- **Base**: `CardViewer` (inherits from CardViewer)
- Available cards list display
- Info panel integration
- `CLListCardObject.gd` — Library list card object

## DeckBuilder (`src/core/CardViewer/DeckBuilder/DeckBuilder.gd`)
- **Base**: `CardViewer` (inherits from CardViewer)
- Grid/list view for library + deck side-by-side
- Card search, category filter
- Quantity management (number buttons + freeform input)
- Deck serialization via DeckLoader
- Signals for deck changes

## DeckLoader (`src/core/CardViewer/DeckBuilder/DeckLoader.gd`)
- **Base**: `MenuButton`
- Save/load/reset/delete deck operations
- Formats: JSON (current default), legacy support for base64/ConfigFile
- Uses `File` and `Directory` classes (Godot 3 — needs migration to FileAccess/DirAccess)

## Custom Extensions (`src/custom/CGFDeckbuilder/`)
- `CGFDeckBuilder.gd` — Adds Back button, custom info panel
- `CGFCardLibrary.gd` — Responsive abilities header
- `CGFListCardObject.gd` — Viewport-resize-responsive abilities label
