# Progress Tracker — Desktop Mode via PhotinoAOT

> This file traces which step we are at. Update it after completing each task.
> The project **must compile** at the end of every step.

## Current step

**Step 1.1 — DONE.** TFM changed to `net10.0`. Build succeeds on Linux (0 errors;
pre-existing AOT/trimming warnings remain, unrelated to this task).

## Task status

### Phase A — Foundation (cross-platform build)

| # | Task | Status |
|---|------|--------|
| 1.1 | Change TFM to `net10.0` | ✅ |
| 1.2 | Remove/neutralise Windows-only csproj settings | ⬜ |
| 1.3 | Verify cross-platform build on Linux | ⬜ |

### Phase B — CLI plumbing

| # | Task | Status |
|---|------|--------|
| 2.1 | Add `IsDesktopMode` to `AgentArguments` record | ⬜ |
| 2.2 | Parse `--desktop` flag | ⬜ |
| 3.1 | Create `DesktopHost` stub | ⬜ |
| 3.2 | Dispatch `--desktop` in `Program.cs` | ⬜ |

### Phase C — Photino window

| # | Task | Status |
|---|------|--------|
| 4.1 | Add `Photino.NET` package reference | ⬜ |
| 4.2 | Create desktop asset files (HTML/JS/CSS) | ⬜ |
| 4.3 | Embed desktop assets as resources | ⬜ |
| 4.4 | Add `DesktopAssets` loader class | ⬜ |
| 5.1 | Create `PhotinoWindow` in `DesktopHost` | ⬜ |
| 5.2 | Load embedded HTML into the window | ⬜ |

### Phase D — Agent bridge

| # | Task | Status |
|---|------|--------|
| 6.1 | Create `DesktopObserver` skeleton (IAgentObserver) | ⬜ |
| 6.2 | Implement `SendWebMessage` for each event type | ⬜ |
| 7.1 | Register web-message handler in `DesktopHost` | ⬜ |
| 7.2 | Run `CodingAgent` with `DesktopObserver` on prompt | ⬜ |
| 7.3 | Replace SSE with Photino bridge in `app.js` | ⬜ |
| 7.4 | Reuse Web UI renderers in desktop `app.js` | ⬜ |

### Phase E — Confirmation & polish

| # | Task | Status |
|---|------|--------|
| 8.1 | Send `confirm` event for destructive tools | ⬜ |
| 8.2 | JS confirmation dialog + return answer to .NET | ⬜ |
| 8.3 | Wait for JS answer before dispatching tool | ⬜ |
| 9.1 | Update README / help for `--desktop` | ⬜ |
| 9.2 | Remove leftover SSE/ASP.NET from desktop path | ⬜ |
| 9.3 | Full build + update PROGRESS.md | ⬜ |

## Build verification

- **Task 1.1:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  (17 pre-existing AOT/trimming warnings in Web/TUI paths — unrelated to this
  task, to be addressed in Task 9.3.)
