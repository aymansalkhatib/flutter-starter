---
name: migrate-packages
description: Read pubspec.yaml and print flutter pub add commands for all packages.
disable-model-invocation: true
---

## Instructions

### Step 1 — Read
Read `pubspec.yaml` once. Do not read any other file.

### Step 2 — Extract
Collect all package names:
- From `dependencies:` → regular list (exclude `flutter` and `flutter_localizations`)
- From `dev_dependencies:` → dev list (exclude `flutter_test`)

### Step 3 — Output
Print **only** these two lines — nothing else:

```
flutter pub add <pkg1> <pkg2> <pkg3> ...
flutter pub add --dev <dev_pkg1> <dev_pkg2> ...
```

If one list is empty, omit its line entirely.

### Rules
- Do NOT run any terminal commands.
- Do NOT search the codebase.
- Do NOT explain, summarize, or add any extra text.
- Each command is a single line — all packages space-separated.
