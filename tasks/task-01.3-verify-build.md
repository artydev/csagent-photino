# Task 1.3 — Verify cross-platform build on Linux

## Objective

Confirm the project now builds cleanly on Linux (and by extension is
cross-platform).

## Steps

1. Run a clean build.
2. Confirm zero errors and zero warnings.

## Acceptance criteria

- [ ] `dotnet build -c Debug` succeeds on Linux.
- [ ] No errors or warnings.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`, `0 Warning(s)`, `0 Error(s)`.
