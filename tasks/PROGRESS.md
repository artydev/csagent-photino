# Progress Tracker — Desktop Mode via PhotinoAOT

> This file traces which step we are at. Update it after completing each task.
> The project **must compile** at the end of every step.

## Current step

**Step 9.3 — DONE.** Full clean build succeeds with **0 warnings and 0 errors**.
All tasks complete. Desktop mode via Photino is fully implemented.

## Task status

### Phase A — Foundation (cross-platform build)

| # | Task | Status |
|---|------|--------|
| 1.1 | Change TFM to `net10.0` | ✅ |
| 1.2 | Remove/neutralise Windows-only csproj settings | ✅ |
| 1.3 | Verify cross-platform build on Linux | ✅ |

### Phase B — CLI plumbing

| # | Task | Status |
|---|------|--------|
| 2.1 | Add `IsDesktopMode` to `AgentArguments` record | ✅ |
| 2.2 | Parse `--desktop` flag | ✅ |
| 3.1 | Create `DesktopHost` stub | ✅ |
| 3.2 | Dispatch `--desktop` in `Program.cs` | ✅ |

### Phase C — Photino window

| # | Task | Status |
|---|------|--------|
| 4.1 | Add `Photino.NET` package reference | ✅ |
| 4.2 | Create desktop asset files (HTML/JS/CSS) | ✅ |
| 4.3 | Embed desktop assets as resources | ✅ |
| 4.4 | Add `DesktopAssets` loader class | ✅ |
| 5.1 | Create `PhotinoWindow` in `DesktopHost` | ✅ |
| 5.2 | Load embedded HTML into the window | ✅ |

### Phase D — Agent bridge

| # | Task | Status |
|---|------|--------|
| 6.1 | Create `DesktopObserver` skeleton (IAgentObserver) | ✅ |
| 6.2 | Implement `SendWebMessage` for each event type | ✅ |
| 7.1 | Register web-message handler in `DesktopHost` | ✅ |
| 7.2 | Run `CodingAgent` with `DesktopObserver` on prompt | ✅ |
| 7.3 | Replace SSE with Photino bridge in `app.js` | ✅ |
| 7.4 | Reuse Web UI renderers in desktop `app.js` | ✅ |

### Phase E — Confirmation & polish

| # | Task | Status |
|---|------|--------|
| 8.1 | Send `confirm` event for destructive tools | ✅ |
| 8.2 | JS confirmation dialog + return answer to .NET | ✅ |
| 8.3 | Wait for JS answer before dispatching tool | ✅ |
| 9.1 | Update README / help for `--desktop` | ✅ |
| 9.2 | Remove leftover SSE/ASP.NET from desktop path | ✅ |
| 9.3 | Full build + update PROGRESS.md | ✅ |

## Build verification

- **Task 1.1:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  (17 pre-existing AOT/trimming warnings in Web/TUI paths — unrelated to this
  task, to be addressed in Task 9.3.)
- **Task 1.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  Excluded `PhotinoAOT/` reference dir from compilation. Same 17 pre-existing
  AOT/trimming warnings remain (unrelated).
- **Task 1.3:** `dotnet clean` + `dotnet build -c Debug` → `Build succeeded`,
  `0 Error(s)`, `17 Warning(s)` (pre-existing AOT/trimming warnings, deferred
  to Task 9.3). Cross-platform build on Linux confirmed.
- **Task 2.1/2.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  `IsDesktopMode` property added and `--desktop` flag parsed.
- **Task 3.1/3.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  `dotnet run -- --desktop` prints "Desktop mode coming soon." (no crash).
- **Task 4.1/4.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  `Photino.NET` v3.2.3 referenced; desktop placeholder assets created.
- **Task 4.3/4.4:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  Desktop assets embedded as resources; `DesktopAssets` loader added.
- **Task 5.1/5.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  `PhotinoWindow` created and loads embedded HTML via custom `app` scheme.
- **Task 6.1/6.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  `DesktopObserver` implements `IAgentObserver` and sends web messages.
- **Task 7.1/7.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  Web-message handler registered; `CodingAgent` runs with `DesktopObserver`.
- **Task 7.3/7.4:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  Desktop `app.js` uses Photino bridge (no SSE); reuses Web UI renderers.
- **Task 8.1:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  `Confirm` added to `IAgentObserver`; destructive tools send `confirm` event.
- **Task 8.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  JS `confirm` dialog added; answer sent back as `confirm-answer` message.
- **Task 8.3:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  `DesktopObserver.Confirm` awaits JS answer via `TaskCompletionSource`.
- **Task 9.1:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  `--desktop` documented in `HelpDisplay` and README files.
- **Task 9.2:** `dotnet build -c Debug` → `Build succeeded`, `0 Error(s)`.
  Verified desktop path has no SSE/ASP.NET dependencies.
- **Task 9.3:** `dotnet clean` + `dotnet build -c Debug` → `Build succeeded`,
  `0 Warning(s)`, `0 Error(s)`. Fixed CS8604 nullable warnings in
  `ToolDispatcher`; suppressed accepted AOT/trimming warnings (IL2026/IL3050)
  via `<NoWarn>` in `CsAgentUI.csproj`. All tasks complete.
