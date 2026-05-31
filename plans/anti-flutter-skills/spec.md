# Spec: .anti-flutter Skill System cho Antigravity AI Agent

**Date:** 2026-05-31
**Status:** Ready

---

## Problem Statement

Antigravity AI coding agent generate Flutter code tự do, không theo Clean Architecture, bỏ qua domain layer, tạo file sai chỗ, và dùng BLoC sai pattern. Cần bộ skill `.anti-flutter/` để agent luôn follow convention của project này.

---

## User Stories

- **[P1]** As a developer, I want a `RULES.md` file that the agent always reads so that every code generation follows the project's folder structure, layer separation, and BLoC pattern.
  Accepted when: agent creates new files in the correct `lib/features/{feature}/data|domain|presentation/` path without being told.

- **[P1]** As a developer, I want a `/add-feature` skill so that scaffolding a new e-commerce feature (entity, repo, usecase, BLoC, page) takes one command and produces the full 3-layer structure.
  Accepted when: running `/add-feature cart2` creates all required files in the right directories.

- **[P1]** As a developer, I want a `/add-bloc` skill so that adding BLoC to an existing feature always produces sealed event/state/bloc files with correct Dart 3 syntax.
  Accepted when: generated BLoC uses sealed classes, Equatable, and correct event handler pattern.

- **[P1]** As a developer, I want `references/` docs with concrete code templates so that the agent has exact patterns to copy — not hallucinate.
  Accepted when: references contain full working code for Result<T>, BLoC, DI registration, and GoRouter patterns.

- **[P2]** As a developer, I want a `/fix-arch` skill so that I can ask the agent to audit a feature and flag architecture violations.
  Accepted when: skill produces a checklist of violations (wrong layer, missing usecase, direct API call in UI) for a given feature.

- **[P2]** As a developer, I want a `/wire-di` skill so that after creating a feature, all components get registered in `injection_container.dart` correctly (factory vs singleton rules).
  Accepted when: generated DI code uses `registerLazySingleton` for repos/datasources and `registerFactory` for BLoCs.

- **[P3]** _(Auto-detection of feature name from context — out of scope for v1)_

---

## Functional Requirements

1. FR-01: Create `.anti-flutter/RULES.md` — always-active passive rules covering folder structure, layer rules, BLoC pattern, DI rules, naming conventions.
2. FR-02: Create `.anti-flutter/skills/add-feature/SKILL.md` — step-by-step scaffold procedure for new features with full 3-layer structure.
3. FR-03: Create `.anti-flutter/skills/add-feature/references/feature-template.md` — concrete code templates for entity, model, datasource, repo, usecase, BLoC, page.
4. FR-04: Create `.anti-flutter/skills/add-bloc/SKILL.md` — procedure for adding BLoC/Cubit to existing feature.
5. FR-05: Create `.anti-flutter/skills/fix-arch/SKILL.md` — audit checklist skill.
6. FR-06: Create `.anti-flutter/skills/wire-di/SKILL.md` — DI registration procedure.
7. FR-07: Create `.anti-flutter/references/` with: `folder-structure.md`, `bloc-patterns.md`, `di-patterns.md`, `result-patterns.md`.
8. FR-08: All skill files use same YAML frontmatter format as `.claude/skills/` (name, description, user-invocable fields).

---

## Non-Functional Requirements

- Skill files: ≤ 300 lines each (extract to references/ if longer)
- Code templates in references/: production-quality Dart, null-safe, Dart 3 sealed classes
- RULES.md: ≤ 150 lines — concise enough agent reads fully every time
- All templates consistent with existing codebase patterns in `lib/`

---

## Success Criteria

- [ ] Agent creates new feature files in correct directory without extra instruction
- [ ] Generated BLoC uses sealed classes with no `default:` arm on switch
- [ ] Generated DI uses `registerLazySingleton` for repos, `registerFactory` for BLoCs
- [ ] `flutter analyze` passes on any file generated from a skill template
- [ ] `/add-feature` command produces ≥ 8 files covering all 3 layers

---

## Out of Scope

- Auto-detection of violations without explicit `/fix-arch` call
- Skill for GoRouter route registration (deferred to v2)
- Skill for writing unit tests (deferred to v2)
- Integration with CI/CD

---

## Assumptions

- Antigravity reads `.anti-flutter/RULES.md` automatically from project root (same as how Claude reads CLAUDE.md)
- Skill format is identical to `.claude/skills/` YAML frontmatter + markdown body
- Project follows the structure built in `lib/` — all templates are derived from existing working code
- Developer will update templates when new packages or patterns are adopted

---

## Architecture Reference

```
.anti-flutter/
├── RULES.md                            ← passive, always-active
├── skills/
│   ├── add-feature/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── feature-template.md    ← full code templates per layer
│   ├── add-bloc/
│   │   └── SKILL.md
│   ├── fix-arch/
│   │   └── SKILL.md
│   └── wire-di/
│       └── SKILL.md
└── references/
    ├── folder-structure.md
    ├── bloc-patterns.md
    ├── di-patterns.md
    └── result-patterns.md
```
