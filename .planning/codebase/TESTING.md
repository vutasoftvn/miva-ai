# Testing & Quality Assurance

## Current Test Coverage

**Overall Coverage: 0%**
- No test files found in Python or Dart codebases
- `flutter_test` listed in dev_dependencies but unused
- No Python test framework detected in requirements.txt

## Test Framework Status

### Python
- **Recommended**: pytest with async support (`pytest-asyncio`)
- **Current**: None installed
- **Target modules needing tests**:
  - `src/main.py` - Event loop orchestration
  - `src/brain.py` - Groq AI integration
  - `src/executor.py` - Command execution (critical for security)
  - `src/database.py` - Supabase realtime connection

### Dart/Flutter
- **Recommended**: flutter_test (built-in, already in dev_dependencies)
- **Current**: Not implemented
- **Target modules needing tests**:
  - `controllers/miva_controller.dart` - State management
  - `core/services/tts_service.dart` - TTS integration
  - `ui/screens/home_screen.dart` - UI interactions
  - Models and data classes

## CI/CD Pipeline

**Status**: Not configured
- No GitHub Actions workflows
- No automated test runs on PR
- No build validation pipeline
- No deployment gates

## Manual Testing Practices

- **Pre-commit**: Developers test app manually in Flutter emulator/device
- **Functionality**: Smoke tests for voice input → command execution → TTS response
- **Platform testing**: iOS (logical), macOS (partial), Android (logical), web (untested)

## Critical Testing Gaps

### High Priority
1. **Security validation** - `src/executor.py` terminal command whitelist enforcement
2. **Intent parsing** - Groq response schema validation in `src/brain.py`
3. **State synchronization** - Flutter ↔ Python state consistency

### Medium Priority
1. **Error recovery** - Supabase connection loss handling
2. **Performance** - IPC latency benchmarks
3. **Cross-platform** - Platform-specific edge cases (iOS/Android STT/TTS)

### Low Priority
1. **UI regression** - Home screen layout across devices
2. **API integration** - Groq/Supabase happy paths

## Recommended Test Strategy

### Phase 1: Security Tests
```
pytest src/executor.py -k "whitelist"
pytest src/brain.py -k "validation"
```

### Phase 2: Integration Tests
```
pytest src/database.py -k "realtime"
pytest tests/integration/ --asyncio-mode=auto
```

### Phase 3: UI Tests
```
flutter test test/widgets/
```

### Phase 4: E2E Tests
```
flutter drive --target=test_driver/app.dart
```

## Coverage Reporting

**Current**: Not configured
**Recommended**: 
- Python: `pytest-cov` for coverage reports
- Dart: Built-in `flutter test --coverage`
- Target: 70% minimum coverage for critical paths

## Documentation Status

- No API documentation
- No testing guide for contributors
- Recommendations: Add TESTING.md with examples
