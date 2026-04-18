# Commands Reference

---

## Code Generation

```bash
dart helpers/asset_codegen.dart              # Generate asset classes
dart helpers/asset_usage_lint.dart        # Check for unused assets

dart helpers/translation_codegen.dart         # Generate localization files
dart helpers/feature_generator.dart          # Scaffold a new feature
```

---

## Build Runner

```bash
dart run build_runner clean                                    # Clean generated files
dart run build_runner build --delete-conflicting-outputs       # One-time build
dart run build_runner watch --delete-conflicting-outputs       # Watch mode
```

---

## Assets & Splash

```bash
dart run flutter_launcher_icons                # Generate launcher icons
dart run flutter_native_splash:create          # Generate native splash screen
```

---

## Flutter

```bash
flutter pub get                                # Fetch dependencies
flutter pub upgrade                            # Upgrade all dependencies
flutter pub outdated                           # Check outdated dependencies
flutter pub cache repair                       # Repair corrupted pub cache

flutter clean                                  # Clean build cache
flutter analyze                                # Analyze code for issues
flutter test                                   # Run tests

flutter run                                    # Run on connected device
flutter build apk --release                                                      # Build release APK
flutter build apk --release --obfuscate --split-debug-info=build/debug_info      # Release APK with obfuscation
flutter build apk --profile                    # Build profile APK
flutter install --profile -d <device_id>       # Install on specific device

flutter doctor                                 # Check Flutter environment
flutter upgrade                                # Upgrade Flutter SDK
```

#### Full clean restart
```bash
flutter clean && flutter pub get && flutter run
```

---

## Git

```bash
git status                                     # Show working tree status
git add .                                      # Stage all changes
git commit -m "type: message"                  # Commit staged changes
git push                                       # Push to remote
git pull                                       # Pull latest from remote

git branch                                     # List branches
git checkout <branch>                          # Switch branch
git merge <branch>                             # Merge branch into current
git rebase <branch>                            # Rebase onto branch
git cherry-pick <hash>                         # Apply specific commit

git stash                                      # Stash changes
git stash pop                                  # Apply latest stash

git log --oneline                              # Compact commit history
git reset --hard <hash>                        # Reset to specific commit
git clean -fd                                  # Remove untracked files
```

---

## Android / System

```bash
adb devices                                    # List connected Android devices
cd android && ./gradlew signingReport          # Show signing report

# Kill stuck Gradle / Java process
taskkill /F /IM java.exe /T

# Kill Android Studio
taskkill /F /IM studio64.exe /T

# PowerShell alternative
Stop-Process -Name java -Force -ErrorAction SilentlyContinue
```

---

## Hive Setup

```bash
flutter pub add hive_ce hive_ce_flutter
flutter pub add --dev hive_ce_generator build_runner
```
