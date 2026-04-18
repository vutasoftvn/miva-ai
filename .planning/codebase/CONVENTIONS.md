# Code Conventions

## Naming Conventions

### Python
- **Variables & Functions**: `snake_case`
- **Classes**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`

### Dart/Flutter
- **Variables & Functions**: `camelCase`
- **Classes & Enums**: `PascalCase`
- **Constants**: `kPascalCase` (with leading `k`)
- **Private members**: Prefix with underscore (`_variable`)

## Code Style

### Python
- PEP 8 compliance enforced implicitly
- Async/await pattern for event handling
- Type hints not consistently used but encouraged
- Logging format: `[COMPONENT] Message`

### Dart/Flutter
- Flutter lints via `flutter_lints` package
- Line length soft limit ~80 chars, hard 120 chars
- Trailing commas preferred for multi-line constructs
- GetX reactive variables use `.obs` property

## Error Handling

### Python
- Try-catch blocks with fallback responses
- Validation guards at function entry
- Subprocess error checking with exception handling
- Graceful degradation on external API failures (Groq, Supabase)

### Dart/Flutter
- Try-catch for async operations
- Snackbar notifications for user-facing errors
- Error state propagation through GetX controllers
- Defensive null-coalescing operators

## Imports & Organization

### Python
Order: Standard Library → Third-party → Local modules
```python
import asyncio
from typing import Optional

import aiosupabase

from src.executor import CommandExecutor
```

### Dart
Order: Dart imports → Package imports → Relative imports
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/tts_service.dart';
```

## State Management

### Python
- Instance variables with private prefix for encapsulation
- Async context managers for resource lifecycle
- Event-driven architecture via Supabase realtime

### Dart
- GetX `.obs` observables for reactive state
- GetX controllers for business logic
- Immutable models where possible

## Language & Documentation

- **Primary language**: Vietnamese (all variable names, comments, documentation)
- **No code comments**: Self-documenting code preferred
- **Docstrings**: Limited, only for public APIs if needed
- **Issues & PRs**: Vietnamese-language descriptions

## File Structure

### Python (`src/`)
- One module per file (e.g., `brain.py` for AI logic)
- Async functions as primary pattern
- Minimal class usage, functions preferred

### Dart (`app/lib/`)
- MVC-style organization (controllers, models, ui, services)
- One widget per file convention
- Singleton pattern for services (e.g., `TtsService`)
