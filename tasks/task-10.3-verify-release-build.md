# Task 10.3 — Verify Release build

## Objective

Verify the project builds cleanly in Release configuration.

## Steps

1. Run `dotnet build -c Release`.
2. Confirm zero errors and zero warnings.

## Acceptance criteria

- [ ] Release build succeeds with 0 warnings and 0 errors.

## Verification

```bash
dotnet build -c Release
```

Expected: `Build succeeded`, `0 Warning(s)`, `0 Error(s)`.
