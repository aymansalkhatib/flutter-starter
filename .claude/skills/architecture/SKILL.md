---
name: architecture
description: Clean Architecture layer rules, feature folder structure, import direction, and no-backend feature scaffolding for flutter_genesis. Use when deciding where a new file belongs, reviewing dependency direction between domain/data/presentation, structuring a feature folder, or building a presentation-only feature (splash, onboarding, info).
---

# Architecture

## Layer rules — non-negotiable

```
presentation  →  domain  ←  data
```

| Layer | Contains | Depends on |
|-------|----------|------------|
| `domain` | Entity, Repository (abstract), UseCase + Params | Nothing |
| `data` | Repository (impl), RemoteDataSource, LocalDataSource *(if cached)*, Model *(only if API diverges)* | domain |
| `presentation` | Cubit, State, Page, Widget, Args | domain |

- `data` imports `domain` — **never the reverse**.
- `presentation` never imports `data` directly — only the domain `Repository` abstraction, resolved from `sl`.
- One feature never imports another feature's `data/` or `cubit/` internals.

## Folder structure

Folder names are **plural** (collections). File names are **singular** (one concern per file).

```
lib/features/<feature>/
├── data/
│   ├── datasources/
│   │   ├── <feature>_remote_data_source.dart   # abstract + impl in same file
│   │   └── <feature>_local_data_source.dart    # only if caching was requested
│   ├── models/                                 # only if API diverges from domain
│   │   └── <feature>_model.dart
│   └── repositories/
│       └── <feature>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <feature>_entity.dart
│   ├── repositories/
│   │   └── <feature>_repository.dart           # abstract only
│   └── usecases/
│       ├── get_<feature>_usecase.dart
│       └── create_<feature>_usecase.dart       # Params in same file
├── presentation/
│   ├── args/
│   │   └── <feature>_args.dart                 # typed route arguments
│   ├── cubit/
│   │   ├── <feature>_cubit.dart
│   │   └── <feature>_state.dart
│   ├── pages/
│   │   └── <feature>_page.dart
│   └── widgets/
│       └── <feature>_body_widget.dart
└── di/
    └── <feature>_dependencies.dart
```

- Every file belongs to exactly one of those folders — no loose files at the feature root.
- Page holds `BlocProvider` + `Scaffold` + `CustomAppBar`; body widget holds `BlocConsumer` + content only.
- Never use Flutter's `AppBar` directly — always `CustomAppBar`. Never place `Scaffold`/`AppBar` inside a body widget.

## No-backend features (splash, onboarding, info)

Build **presentation only** — no Cubit, no UseCase, no Repository, no DataSource, no `di/`:

```
presentation/
├── pages/
└── widgets/
```

If dynamic behaviour is later required, scale up then. **Never pre-build empty layers.**
