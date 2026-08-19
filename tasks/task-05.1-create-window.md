# Task 5.1 — Create `PhotinoWindow` in `DesktopHost`

## Objective

Replace the `DesktopHost` stub with a real Photino window.

## Steps

1. In `DesktopHost.Run`, create a `PhotinoWindow`:
   - Set a title (e.g. `CSAgent`).
   - Set a default size (e.g. 1280x800) and center it.
2. Call `window.WaitForClose()` to keep the window open.
3. Keep the `ALBERT_API_KEY` check (exit gracefully if not set).

## Acceptance criteria

- [ ] `DesktopHost.Run` creates and shows a `PhotinoWindow`.
- [ ] The window stays open until closed.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`. (Running the window requires a display; on a
headless CI the build is the primary check.)
