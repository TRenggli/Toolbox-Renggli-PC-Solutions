# CONTRIBUTING

## Contribution Workflow
1. Create a branch from `main`.
2. Keep changes focused and small.
3. Update docs when behavior changes.
4. Open a pull request with clear scope and risk notes.

## Required Checks Before PR
- CI must pass:
  - `CI Smoke Checks`
  - `CI Matrix Regression`
- No syntax errors in edited scripts.
- No new unsafe patterns in shutdown/cleanup logic.
- Exit option behavior must match menu text and docs.

## Commit Guidelines
- Use clear, action-oriented commit messages.
- Group related changes in the same commit.
- Do not mix unrelated refactors with security fixes.

## Script Safety Rules
- Keep admin/root checks intact.
- Protect system disk in destructive modules.
- Avoid broad wildcard cleanup outside Toolbox-owned scope.
- Preserve audit logging behavior unless explicitly redesigned.

## Documentation Rules
When changing behavior, update:
- `HISTORIAL_DE_CAMBIOS.md`
- `Manuales/README_ES.md`
- `Manuales/README_EN.md`
- `Manuales/README_CN.md`

## Pull Request Template (Recommended)
Include:
- What changed
- Why it changed
- Risk level (low/medium/high)
- Files impacted
- Validation performed
