# Custom Game Layer (Demo Card Game)

Located in `src/custom/`, this layer demonstrates how a game extends the framework.

## Key Files

| File | Extends | Purpose |
|------|---------|---------|
| `MainMenu.gd/.tscn` | — | Main menu: Play, Deck Builder, Card Library buttons |
| `CGFBoard.gd` | Board | Loads test cards, toggle buttons (FancyMovement, OvalHand, Debug, Reshuffle, DeckBuilder), seed display |
| `CGFHand.gd` | Hand | Adds DiscardRandom manipulation button |
| `CGFDeck.gd` | Pile | Click-to-draw, emits `draw_card` signal |
| `CGFDiscard.gd` | Pile | Empty placeholder |
| `CGFCardTemplate.gd/.tscn` | Card | Credit cost payment, right-click targeting, custom property keys |
| `CGFCardFront.gd/.tscn` | CardFront | Maps labels: Name, Type, Tags, Requirements, Abilities, Cost, Power |
| `CGFCardBack.gd/.tscn` | CardBackGlow | Scaled font with viewport |
| `CGFCounters.gd/.tscn` | Counters | Credits (starts 100), Research (starts 0) |
| `CGFManipulationButtons.gd` | ManipulationButtons | Rot90, Rot180, Flip, AddToken, View |
| `CFConst.gd` | — | Paths, card size, colors, shuffle styles, token definitions |
| `SP.gd` | ScriptProperties | Adds "CREDITS_COST" filter |

## Card Definitions
- `cards/CardConfig.gd` — PROPERTIES_STRINGS (name, type, tags, requirements, abilities), PROPERTIES_NUMBERS (cost, power), explanations
- `cards/CustomScripts.gd` — Custom card script definitions
- `cards/sets/SetPreload.gd` — Loading manager for card sets
- `cards/sets/SetDefinition_Demo1.gd` / `SetDefinition_Demo2.gd` — Card definitions for demo sets
- `cards/sets/SetScripts_Demo1.gd` / `SetScripts_Demo2.gd` — Scripts for demo card sets
- Card scenes: Red.tscn, Blue.tscn, Green.tscn, Purple.tscn (with *Front.tscn variants)
- `cards/Token.tscn` — Token card scene
