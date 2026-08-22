# Task 10.2 — Verify Debug standalone build

## Objective

Verify the project builds cleanly in Debug configuration after the
restriction-removal changes.

## Steps

1. Run `dotnet build -c Debug`.
2. Confirm zero errors and zero warnings.

## Acceptance criteria

- [ ] Debug build succeeds with 0 warnings and 0 errors.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`, `0 Warning(s)`, `0 Error(s)`.
