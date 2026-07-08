# Project Overview

## Identity
- **Name**: Godot Card Game Framework (CGF)
- **Version**: 2.2
- **License**: AGPL v3 + Steam Addendum
- **Author**: db0 (see https://github.com/db0/godot-card-framework)
- **Engine**: Godot 3.x (current), targeting Godot 4.7

## Scope
A turnkey card game framework for Godot that provides:
- Drag-and-drop card interactions
- A scripting engine for defining card behaviors
- Deck builder and card library UIs
- Multiplayer-capable architecture
- Full test suite with GUT

## Directory Layout
```
/
├── project.godot         ← Engine config, autoloads, input map, 55 custom class registrations
├── src/
│   ├── core/             ← Framework base classes (43 entries)
│   │   ├── CFControl.gd  ← Singleton autoload (cfc) - central hub
│   │   ├── CardTemplate.gd / .tscn ← Card class
│   │   ├── CardContainer.gd ← Base container
│   │   ├── Hand.gd / Pile.gd ← Container subclasses
│   │   ├── BoardTemplate.gd ← Board class
│   │   ├── BoardPlacementGrid.gd / BoardPlacementSlot.gd
│   │   ├── Card/ ← Front, Back, TargetingArrow, ManipulationButtons, TokenDrawer
│   │   ├── ScriptingEngine/ ← 9 files (Task-based card automation)
│   │   ├── CardViewer/ ← Viewer, Library, DeckBuilder subsystems
│   │   ├── UI dialogs × 6 (SelectionWindow, OptionalConfirmation, etc.)
│   │   └── Utilities × 4 (CFUtils, CFInt, CardFilter, OverridableUtils, ViewportCardFocus)
│   └── custom/           ← Demo game extending core
│       ├── CGF*.gd/.tscn  ← Board, Hand, Deck, Discard, etc.
│       ├── CGFDeckbuilder/ ← Extended CardViewer/DeckBuilder
│       └── cards/         ← CardConfig, CustomScripts, SetPreload, demo sets
├── addons/gut/           ← GUT v7.3.0 test framework
├── tests/                ← 40+ test files (unit + integration)
├── assets/               ← card_backs/, icons/, tokens/
├── fonts/                ← Xolonium-Regular, Comfortaa
├── themes/               ← Dark theme
└── tutorial/             ← Tutorial data
```

## Source Files Count
- GDScript files: ~95
- Scene files (.tscn): ~40
- Resource files (.tres): ~15

## Singletons (Autoload)
- `cfc` → `res://src/core/CFControl.gd` — Central singleton managing NMAP (node map), scripting engine, settings, font cache, unit testing flags, alterant cache, card definitions

## Custom Classes (55 total)
Registered in `project.godot` under `_global_script_classes`. They span:
- Cards (Card, CardFront, CardBack variants, CardContainer, Hand, Pile)
- Board (Board, BoardPlacementGrid, BoardPlacementSlot)
- Scripting (ScriptingEngine, ScriptObject, ScriptTask, ScriptAlter, ScriptPer, ScriptProperties, AlterantEngine, CFScriptUtils, perMessage)
- UI (CardViewer, CardLibrary, DeckBuilder, DeckLoader, SelectionWindow, etc.)
- Utilities (CFConst, CFUtils, CFInt, CardFilter, OverridableUtils, etc.)
- Custom (CustomScripts, CardConfig, SP, SetPreload, various CGF components)
