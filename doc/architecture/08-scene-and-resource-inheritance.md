# Scene & Resource Inheritance

## Scene Inheritance Chain

This project uses Godot 3's scene inheritance extensively:

```
Core Scenes (DO NOT MODIFY)
├── src/core/Main.tscn              ← Base main scene (Node2D)
│   └── src/custom/CGFMain.tscn     ← Custom main
├── src/core/BoardTemplate.tscn     ← Board scene (Control)
│   └── src/custom/CGFBoard.tscn    ← Custom board
│   └── tests/UTBoard.tscn          ← Test board
├── src/core/CardTemplate.tscn      ← Base card (Area2D)
│   └── src/custom/CGFCardTemplate.tscn  ← Custom card
│   └── src/custom/cards/Red.tscn, Blue.tscn, Green.tscn, Purple.tscn
├── src/core/Hand.tscn              ← Hand scene
│   └── src/custom/CGFHand.tscn     ← Custom hand
├── src/core/Pile.tscn              ← Pile scene
│   └── src/custom/CGFDeck.tscn     ← Deck
│   └── src/custom/CGFDiscard.tscn  ← Discard pile
├── src/core/Token.tscn             ← Token
├── src/core/Highlight.tscn         ← Highlight
├── src/core/SelectionWindow.tscn   ← Selection dialog
├── src/core/OptionalConfirmation.tscn ← Confirmation dialog
├── src/core/AskInteger.tscn        ← Integer input
├── src/core/CardChoices.tscn       ← Card choices popup
├── src/core/DetailPanels.tscn      ← Detail panels
└── src/core/MousePointer.tscn      ← Mouse pointer

CardViewer Scenes
├── src/core/CardViewer/CardViewer.tscn
│   ├── src/core/CardViewer/CardLibrary/CardLibrary.tscn
│   │   └── src/custom/CGFDeckbuilder/CGFCardLibrary.tscn
│   └── src/core/CardViewer/DeckBuilder/DeckBuilder.tscn
│       └── src/custom/CGFDeckbuilder/CGFDeckBuilder.tscn

Test Scenes
├── tests/tests.tscn                ← Main test runner (GUT)
├── tests/cli/tests.tscn            ← CLI test runner
├── tests/UTMain.tscn               ← Test main scene
├── tests/UTBoard.tscn              ← Test board scene
└── tests/UTBoard.tscn              ← (extends CGFBoard? check scene structure)
```

## Resource Files
- `default_env.tres` — Default environment (ProceduralSky, background_mode=2)
- `BigFont.tres` / `BigFontTheme.tres` — Font resources
- `fonts/Xolonium-Regular.ttf` — Main font
- `fonts/comfortaa/` — Secondary font
- Various `.tres` in CardViewer (CVCardListHeadersFont, CVCardObjectFont, FilterButtonStyle)
