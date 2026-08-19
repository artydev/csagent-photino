# Task 3.2 — Dispatch `--desktop` in `Program.cs`

## Objective

Wire `--desktop` into `Program.Main` so it dispatches to `DesktopHost.Run`.

## Steps

1. In `Program.cs`, add a branch: if `parsed.IsDesktopMode`, call
   `DesktopHost.Run(parsed)`.
2. Order the dispatch so `--desktop` takes precedence over the default TUI.

## Acceptance criteria

- [ ] `Program.Main` dispatches to `DesktopHost.Run` when `--desktop` is passed.
- [ ] Running `dotnet run -- --desktop` prints the placeholder.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
dotnet run -- --desktop
```

Expected: placeholder message printed, no crash.
