---
name: ui-components
description: Catalog of reusable UI components, snackbars, and dialogs in flutter_starter — CustomButton, CustomTextFormField, CustomAppBar, CustomCachedNetworkImage, OTPInputField, AnimatedDotsLoader, FailureWidget, EmptyWidget, ConfirmBackScope, DoubleBackToExit, MenuAction, RoundedLoadingButton, plus scaffold / overlay snackbars and warning dialog helpers. Use before writing any new widget — check the catalog first. Also covers core utilities (DateFormatter, NumberFormatter, Debouncer, PaginationController, image/file pickers, NetworkMonitor).
---

# UI components & utilities catalog

**Reach for these before writing anything new.** All under [core/ui/](../../../lib/core/ui/) and [core/utils/](../../../lib/core/utils/).

## 1. Core components

| Component | Purpose | Key props |
|-----------|---------|-----------|
| `CustomButton` | Primary button — loading / disabled / icon alignment | `text`, `onPressed`, `isLoading`, `icon`, `iconAlignment`, `height=52`, `borderRadius=8` |
| `CustomTextFormField` | Inputs — SVG prefix, password toggle, focus-aware | `controller`, `validator`, `prefixIconSvg`, `showVisibilityToggle`, `keyboardType` |
| `CustomAppBar` | App bar — auto overlay style; `gradient` reserved for hero surfaces | `title`, `actions`, `centerTitle`, `gradient` |
| `CustomCachedNetworkImage` | Cached image — placeholder, initials-avatar fallback, long-press preview | `imageUrl`, `name`, `defaultImage`, `addPrefix` |
| `OTPInputField` | OTP entry — uses `OTPManager` (owner disposes) | — |
| `AnimatedDotsLoader` | Full-screen loader (dialog overlay) | `.show(context)` / `.dismiss()` |
| `RoundedLoadingButton` | Button that morphs into a loader | requires `RoundedLoadingButtonController` |
| `ConfirmBackScope` | Confirms leaving a page with unsaved changes | `onConfirm` |
| `DoubleBackToExit` | Root-level "tap back twice to exit" | — |
| `EmptyWidget` | Standard empty state | `isEmpty`, `message`, `subtitle` |
| `FailureWidget` | Standard error state — pair with `error` Cubit state | `failure`, `onRetry` |
| `MenuAction` / `MenuActionWidget` | Popup menu | `actions: List<MenuAction>` |

## 2. Snackbars

- `showSnackbar(msg, type: OverlaySnackbarType.success)` — `ScaffoldMessenger`-based; requires a Scaffold ancestor.
  [core/ui/snackbar/scaffold_snackbar.dart](../../../lib/core/ui/snackbar/scaffold_snackbar.dart)
- `showOverlaySnackbar(msg, type: ..., position: OverlaySnackbarPosition.top)` — floating overlay outside Scaffold; use from guards, background tasks, or root listeners.
  [core/ui/snackbar/overlay_snackbar.dart](../../../lib/core/ui/snackbar/overlay_snackbar.dart)

`OverlaySnackbarType`: `success`, `error`, `warning`, `info`. **Both auto-translate** the message via `.tr(context)` — pass a `LocaleKeys.x` value directly.

## 3. Dialogs

- `showWarningDialog(context, title: ..., content: ..., confirmButtonText: ..., onConfirm: ...)` — destructive-action confirmation. Not dismissible by barrier tap.
  [core/ui/dialogs/warning_dialog.dart](../../../lib/core/ui/dialogs/warning_dialog.dart)

## 4. Utilities

| Utility | Purpose |
|---------|---------|
| `AppLogger` | `info` / `error` only — **never `debug`** ([utils/app_logger.dart](../../../lib/core/utils/app_logger.dart)) |
| `DateFormatter` | Date/time formatting, relative time |
| `NumberFormatter` | Decimals, currency, compact, percentages |
| `StringUtils` | String manipulation, sanitization |
| `Debouncer` | Debounce callbacks (search fields, resize) |
| `PaginationController` | Infinite-scroll list pagination |
| `FilePickerUtils` / `ImagePickerUtils` | File / image picking wrappers |
| `OrientationManager` | Lock / unlock orientation |
| `NetworkMonitor` | Connectivity state |

### Platform helpers — [core/functions/](../../../lib/core/functions/)

| Helper | Purpose |
|--------|---------|
| `DownloadPath.get()` | Platform-appropriate downloads directory |
| `SdkVersion.get()` | Android SDK int via platform channel |
| `StoragePermission.request()` | Right storage permission per OS version |

Use these instead of re-invoking `permission_handler` or `path_provider` inline.

## 5. Services — `core/services/`

| Service | Purpose |
|---------|---------|
| `FcmService` | Push registration, token refresh, message routing |
| `GoogleAuthService` | Google Sign-In; returns ID token for the backend |

Consumed by repositories / use cases — **never Cubits directly**. See `security` skill §6 for lifecycle rules.

## 6. Network interceptors — `core/network/interceptors/`

| Interceptor | Role |
|-------------|------|
| `HeaderInterceptor` | Injects auth token, locale, device headers |
| `UnauthorizedInterceptor` | Catches 401 → refresh + replay, or force logout |
| `NetworkInterceptor` | Short-circuits when offline (`NetworkMonitor`) |
| `ApiLoggerInterceptor` | Request/response logging; gated by `AppSettings.enableLogging` |

**Features never create a second `Dio`.** New headers or retry logic → edit `HeaderInterceptor` or extend `ApiClient`.
