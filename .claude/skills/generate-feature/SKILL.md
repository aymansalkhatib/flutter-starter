---
name: generate-feature
description: Orchestrator for scaffolding a new Flutter Clean Architecture feature — enforces the intake ritual and generation order. All rules live in CLAUDE.md.
---

## Purpose

Thin orchestrator. **All rules, recipes, and templates live in [CLAUDE.md](../../../CLAUDE.md).** This file only enforces the entry ritual and the generation order. Do not duplicate rules here.

---

## Step 1 — Intake (MANDATORY)

Ask these 5 questions in one message. Wait for the reply before writing any file.

1. **Feature name** (snake_case).
2. **Scope** — one sentence.
3. **Backend** — list of API operations, or `none`.
4. **Caching** — yes/no; if yes, which reads + what invalidates.
5. **Navigation** — route path, guard (`AuthGuard` / `GuestGuard` / none), next screen on success/error.

Derive from the reply: entity fields, whether a Model is needed (only if API diverges), route args (if any).

If `Backend = none` → skip Step 2 (presentation-only; see CLAUDE.md §4).

---

## Step 2 — Generation order

Generate files in this exact order. Each bullet points to the authoritative rule in CLAUDE.md.

1. **Domain** — entity → repository (abstract) → use cases. CLAUDE.md §5, §6.
2. **Data** — remote DS → local DS (if caching) → repository impl → model (only if API diverges). CLAUDE.md §7, §8.
3. **Hive wiring** (only if caching) — add box name + pick next `typeId`. CLAUDE.md §8.
4. **DI** — `di/<feature>_dependencies.dart` + call from `service_locator.dart`. CLAUDE.md §12.
5. **Presentation** — state → cubit → args (if any) → page → body widget. CLAUDE.md §10, §11.1, §15, §16.
6. **Routing** — enum + `generateRoute` + `_guardsFor` (all three). CLAUDE.md §11.2.
7. **Translations** — add keys to `en.json` + `ar.json`; tell the user to regenerate. CLAUDE.md §13.

---

## Step 3 — Verify

Walk the checklist in CLAUDE.md §22. Report to the user:
- Files created, grouped by layer.
- Translation keys added.
- Any assumption made when an intake answer was ambiguous.

---

## Hard rules

- Never skip Step 1. No silent defaults.
- Never duplicate CLAUDE.md rules in generated code reviews — cite the section instead.
- Never run `build_runner` from a tool call.
- Never add a route without editing all three places (enum + switch + guards).
- Never add a feature without its DI file + registration in `service_locator.dart`.
