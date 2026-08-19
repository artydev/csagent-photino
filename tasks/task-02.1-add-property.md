# Task 2.1 — Add `IsDesktopMode` to `AgentArguments` record

## Objective

Add a `bool IsDesktopMode` property to the `AgentArguments` record.

## Steps

1. In `src/Shared/ArgumentParser.cs`, add `bool IsDesktopMode` to the
   `AgentArguments` record (e.g. after `IsUiMode`).

## Acceptance criteria

- [ ] `AgentArguments` has an `IsDesktopMode` property.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
