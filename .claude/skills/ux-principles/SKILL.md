---
name: ux-principles
description: UX / UI design principles and quality gates for flutter_starter — hierarchy (one hero per screen), 8pt spacing grid, 60 / 30 / 10 color rule, typography rules, iconography, motion timing, the five required states (empty / loading / loaded / error / stale), form conventions, accessibility requirements (contrast, tap targets, semantics), and RTL / dark-mode correctness. Use when designing any screen or component, reviewing a layout, or deciding spacing / colors / motion values.
---

# UX / UI principles

## Hierarchy
One hero per screen — title, primary CTA, or key metric. Contrast via weight + color + spacing, not size alone. Scannable in 3 seconds or restructure.

## Spacing — 8pt grid
`4 / 8 / 12 / 16 / 24 / 32 / 48`. Nothing in between.
- Default screen padding `16`; inside-group `8`, between-group `16`, between-section `24–32`.
- Radii: buttons / inputs `8`, cards `12`, sheets / dialogs `16`.
- Elevation `0–4`, single level.

## Color — 60 / 30 / 10
60% neutral surface, 30% content, 10% accent (CTAs only).
- **Gradients** on hero surfaces only (app bar, splash, primary CTA); never on body, cards, or inputs.
- **Semantic colors** (`error` / `success` / `warning` / `info`) reserved for meaning.
- All colors via `context.colors`.

## Typography
`context.styles.<preset>` only — never a free `TextStyle(fontSize:)`.
- Max 3 sizes per screen.
- Body line length 45–75 chars.
- Always `maxLines` + `ellipsis` on `Text` that can overflow.

## Iconography
- No emojis; Material or `Assets.*` SVG.
- One icon family per screen.
- Sizes `16 / 20 / 24` matched to adjacent text.
- `CustomCachedNetworkImage` with explicit width/height.

## Motion
- `150–300ms` micro, `300–500ms` transitions.
- `easeOut` in, `easeIn` out, `easeInOut` both. No bounce / elastic.
- Feedback within 100ms of any tap.
- Haptics on destructive confirms only.

## Five required states — missing any = bug
1. **Empty** → `EmptyWidget`
2. **Loading** → `AnimatedDotsLoader` or skeleton
3. **Loaded** → content
4. **Error** → `FailureWidget` with retry iff `failure.isRetryable`
5. **Partial / stale** → cache-while-refreshing

## Forms
- One column, label-above-field, errors inline.
- Validate on blur.
- Correct `keyboardType` + `textInputAction` + autofill hints on every field.
- Sticky primary CTA above keyboard.
- Validators from the `validation` skill.

## Accessibility
- 4.5:1 body contrast, 3:1 large text and UI.
- 44×44pt tap targets.
- `tooltip` on every `IconButton`.
- `Semantics(label:, button: true)` on any icon-only gesture.
- `semanticsLabel` on images.
- Focus follows reading order.
- Color is **never** the only signal.

## RTL & dark mode
- `EdgeInsetsDirectional` + `Alignment.centerStart` — never `left` / `right`.
- Directional icons (arrows, chevrons) mirror in RTL.
- Numbers / dates via `NumberFormatter` / `DateFormatter`.
- No hardcoded `Colors.black` / `Colors.white`.
- **Test both locales + both themes.** If a pattern is wrong, fix it everywhere.
