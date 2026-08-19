# Progress Tracker — Desktop Mode via PhotinoAOT

> This file traces which step we are at. Update it after completing each task.
> The project **must compile** at the end of every step.

## Current step

**Step 0 — Setup.** Tasks folder created with all elementary sub-tasks and this
progress tracker. No code changes yet.

## Task status

### Phase A — Foundation (cross-platform build)

| # | Task | Status |
|---|------|--------|
| 1.1 | Change TFM to `net10.0` | ⬜ |
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

- Baseline build (before any changes): **FAILS** on Linux — project targets
  `net10.0-windows10.0.19041.0` (Windows-only). This is expected and is the
  subject of Task 1.1.

## Task files

- `task-01.1-tfm-net10.md`
- `task-01.2-remove-windows-settings.md`
- `task-01.3-verify-build.md`
- `task-02.1-add-property.md`
- `task-02.2-parse-flag.md`
- `task-03.1-desktop-host-stub.md`
- `task-03.2-dispatch.md`
- `task-04.1-add-package.md`
- `task-04.2-create-assets.md`
- `task-04.3-embed-assets.md`
- `task-04.4-assets-loader.md`
- `task-05.1-create-window.md`
- `task-05.2-load-html.md`
- `task-06.1-observer-skeleton.md`
- `task-06.2-send-messages.md`
- `task-07.1-register-handler.md`
- `task-07.2-run-agent.md`
- `task-07.3-replace-sse.md`
- `task-07.4-reuse-renderers.md`
- `task-08.1-send-confirm.md`
- `task-08.2-js-dialog.md`
- `task-08.3-wait-for-answer.md`
- `task-09.1-document.md`
- `task-09.2-remove-sse.md`
- `task-09.3-final-build.md`
