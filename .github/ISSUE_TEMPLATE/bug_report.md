---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Description

A clear and concise description of what the bug is.

## Steps to reproduce

1. Configure `SadadConfig` with...
2. Call `client.checkout(...)` with...
3. See error...

## Expected behavior

A clear and concise description of what you expected to happen.

## Actual behavior

What actually happened (include error messages, stack traces, etc.).

## Code sample

```dart
// Minimal reproducible example
final config = SadadConfig(
  merchantId: '1234567',
  secretKey: 'REDACTED',
  website: 'www.example.com',
);
```

## Environment

- Dart SDK version: `dart --version`
- sadad_qatar version: e.g. `1.0.0`
- Platform: e.g. Android, iOS, Web, macOS

## Additional context

Add any other context about the problem here.
