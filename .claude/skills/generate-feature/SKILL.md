---
name: generate-feature
description: Orchestrator for scaffolding a new Flutter Clean Architecture feature end-to-end in flutter_genesis — enforces mode selection (quick / detailed), the intake ritual, the strict generation order across layers, and the feature-delivery checklist. Supports two modes — quick (5 basic questions) and detailed (expanded API contracts with exact request / response shapes). Delegates detailed rules to the per-layer skills (architecture / domain-layer / data-layer / presentation-layer / hive-caching / security / di-registration / navigation / translations). Use when the user asks to create a new feature with domain, data, and presentation layers.
---

# Generate feature — orchestrator

**Thin orchestrator. All rules live in per-layer skills.** This file enforces mode selection, the intake ritual, the generation order, and the final verification checklist — it does not duplicate rules.

---

## Step 0 — Mode selection (MANDATORY)

Before asking intake questions, identify the mode from the user's request:

- **quick** — user said "quick" or described a small / simple feature.
- **detailed** — user said "detailed", "complete", "production-ready", or explicitly asked for full API contracts.
- **neither** — ask the user **first**:

> "Would you like quick mode (5 fast questions) or detailed mode (full API contracts)?"

**Never pick a mode silently.** Never default to quick without asking.

---

## Step 1 — Intake (MANDATORY)

Ask all questions in one message. Wait for the reply before writing any file.

### Quick mode — 5 questions

1. **Feature name** (snake_case).
2. **Scope** — one sentence.
3. **Backend** — list of API operations, or `none`.
4. **Caching** — yes/no; if yes, which reads + what invalidates.
5. **Navigation** — route path, guard (`AuthGuard` / `GuestGuard` / none), next screen on success / error.

### Detailed mode — same 5, expanded Backend (Q3)

1. **Feature name** (snake_case).
2. **Scope** — one sentence + main user flow.
3. **Backend** — for **each** endpoint, provide:
   - `METHOD /path`
   - **Request:**
     - Headers beyond default `Authorization` (if any)
     - Query params with types (e.g. `status: string?`, `page: int`)
     - Body shape (for POST / PUT / PATCH)
   - **Response:** exact JSON sample or schema. Note if:
     - Wrapped (`{data: ...}`)
     - Paginated (`{data: [...], meta: {total, page, ...}}`)
     - Nested objects that might become sub-entities
   - **Error shape:** `{message: string}` (default) or custom.
4. **Caching** — yes/no; if yes, per-endpoint:
   - Which reads should fall back to cache on network failure?
   - Invalidation trigger: logout / app version diff / manual?
5. **Navigation** — route path, guard, next screen on success / error, route args class (if any).

### Optional extra — raise if relevant

If any endpoint response contains tokens, refresh tokens, passwords, or PII:

> "Field `<x>` looks sensitive — should it live in `HiveBoxes.secureBox` (encrypted) instead of the regular cache?"

This triggers the `security` skill. Don't ask by default — only when the data itself flags the concern.

---

## Step 2 — Derive & confirm

From the intake reply, derive and **state your assumptions explicitly**:

- Entity fields (name + type + nullability).
- Whether a separate `Model` is needed (only if API response diverges from the domain — wrapped, renamed keys, type coercion, nested normalisation).
- Route args class name + fields.
- Hive `typeId` — next unused integer.
- Translation keys to add.

If any derived value is a guess, flag it — don't hide it.

---

## Step 3 — Generation order

Generate files in this exact order. Each bullet names the authoritative skill.

1. **Domain** — entity → repository (abstract) → use cases → `domain-layer` skill.
2. **Data** — remote DS → local DS (if caching) → repository impl → model (only if API diverges) → `data-layer` skill (+ `hive-caching` if caching).
3. **Hive wiring** (only if caching) — box name + next `typeId` → `hive-caching` skill.
4. **Security audit** — if the feature touches tokens, PII, external inputs, FCM, or social auth → `security` skill.
5. **DI** — `di/<feature>_dependencies.dart` + call from `service_locator.dart` → `di-registration` skill.
6. **Presentation** — state → cubit → args (if any) → page → body widget → `presentation-layer` skill.
7. **Routing** — enum + `generateRoute` + `_guardsFor` (all three) → `navigation` skill.
8. **Translations** — add keys to `translations.json`; tell the user to regenerate → `translations` skill.

---

## Step 4 — Verify (feature-delivery checklist)

- [ ] Mode confirmed with user (Step 0).
- [ ] Intake answered; derived assumptions stated (Step 2).
- [ ] Repository returns `Either<Failure, T>`; DataSource throws (`data-layer`).
- [ ] Cubit uses `safeEmit`; navigation / loaders / snackbars only in `listener` (`presentation-layer`).
- [ ] Route wired in **all three** places: enum + `generateRoute` + `_guardsFor` (`navigation`).
- [ ] Feature DI file created and registered in `service_locator.dart` (`di-registration`).
- [ ] Zero hardcoded strings / colors / font sizes — translations + `context.*` (`translations`, `theming`).
- [ ] Security: sensitive data in encrypted box; no tokens / PII in logs; no `e.toString()` to UI; external args validated (`security`).
- [ ] Hive: `typeId` and `@HiveField` indexes unchanged from prior releases (`hive-caching`).
- [ ] Five UI states handled: empty, loading, loaded, error, stale (`ux-principles`).
- [ ] Tested in both locales (en / ar) and both themes (light / dark).

Report to the user:
- Files created, grouped by layer.
- Translation keys added.
- Every assumption made with a ⚠️ marker.
- Any manual step (`dart helpers/translation_codegen.dart`, etc.).

---

## Hard rules

- **Never skip Step 0.** Mode must be explicit.
- **Never skip Step 1.** No silent defaults for intake answers.
- **Never hide assumptions.** If you derived it, name it (Step 2).
- **Never duplicate skill rules** in generated code reviews — cite the skill name.
- **Never run `build_runner`** from a tool call.
- **Never add a route** without editing all three places (enum + switch + guards).
- **Never add a feature** without its DI file + registration in `service_locator.dart`.
