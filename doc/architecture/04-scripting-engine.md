# Scripting Engine

## Overview
The Scripting Engine is the most complex subsystem (~45KB core engine). It allows card definitions to include executable scripts that automate game actions.

## Architecture

### ScriptingEngine (`src/core/ScriptingEngine/ScriptingEngine.gd`)
- **Base**: `Reference`
- **Roles**: Execute task queues, manage script lifecycle
- **Execution Modes**: `RunType.NORMAL`, `RunType.COST_CHECK`, `RunType.PRE`, `RunType.POST`
- **Flow**:
  1. `execute_scripts()` receives a script array from a card
  2. COST_CHECK runs first to verify costs are payable
  3. Pre-functions execute
  4. NORMAL tasks execute with optional confirmation popups
  5. Post-functions execute
- **Features**:
  - Nested script support (scripts within scripts)
  - Selection windows, ask-integer popups
  - Snapshot IDs for card references before/after execution
  - Targets and subjects resolution
  - Alterant runtime modifications

### ScriptObject (`src/core/ScriptingEngine/ScriptObject.gd`)
- **Base**: `Reference`
- **Base class** for ScriptTask, ScriptAlter, ScriptPer
- Subject finding via NMAP (node map)
- Property parsing with aliases
- Filter checking
- Replacement code parsing (`{subject_id}` patterns)

### ScriptTask (`src/core/ScriptingEngine/ScriptTask.gd`)
- Single executable action
- Trigger filtering, cost priming
- Optional confirmation via OptionalConfirmation dialog

### ScriptAlter (`src/core/ScriptingEngine/ScriptAlter.gd`)
- Single alteration to a value
- Valid/invalid filter, subject finding
- Value calculation

### ScriptPer (`src/core/ScriptingEngine/ScriptPer.gd`)
- **Enum**: `ScriptPerType` — boardseek, tutor, dictcount, custom, token, card, singlecard, property
- Handles counting/lookup logic for "per X" operations

### ScriptProperties (`src/core/ScriptingEngine/ScriptProperties.gd`)
- ~56KB dictionary of all property names, types, filter logic, descriptions
- Defines what properties cards can have and how they're compared

### AlterantEngine (`src/core/ScriptingEngine/AlterantEngine.gd`)
- Runtime modifier system
- Gathers all card alterants and applies modifications to running task values

### CFScriptUtils (`src/core/ScriptingEngine/CFScriptUtils.gd`)
- Static utility functions for alterant calculations
- Token counting, property counting, type counting

### perMessage (`src/core/ScriptingEngine/perMessage.gd`)
- Message object passed to ScriptPer
- Contains seek type, definitions array, subjects dictionary, multipliers

## Script Structure
```gdscript
# Example card script
[
    {
        "trigger": {
            "when": "on_play",
            "condition": {"property": "cost", "comparison": "le", "value": 5}
        },
        "tasks": [
            {
                "task": "modify_property",
                "subject": "target",
                "property": "power",
                "value": "+2"
            },
            {
                "task": "draw_cards",
                "value": 1
            }
        ]
    }
]
```
