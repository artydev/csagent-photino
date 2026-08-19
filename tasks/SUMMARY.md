# Desktop Mode via PhotinoAOT — Task Summary

## Final Objective

Add a **third usage type** to CSAgent: a **desktop** mode launched with a
`--desktop` flag that opens a native Photino window. The desktop mode:

- Is **cross-platform** (`net10.0`), not Windows-only.
- **Reuses the existing Web UI assets** (markdown rendering, tool call display)
  as the desktop front-end.
- Uses **no SSE and no ASP.NET server** — instead it uses Photino's direct
  .NET ↔ JS message bridge (`SendWebMessage` / `RegisterWebMessageReceivedHandler`).
- Uses a **JS confirmation dialog** for destructive tool actions.

The work is broken into **25 elementary, testable sub-tasks** across 5 phases.
The project **must compile** at the end of every step. Progress is tracked in
`tasks/PROGRESS.md`.

---

## Phase A — Foundation (cross-platform build)

| # | Task | Status |
|---|------|--------|
| 1.1 | Change TFM to `net10.0` | ⬜ |
| 1.2 | Remove/neutralise Windows-only csproj settings | ⬜ |
| 1.3 | Verify cross-platform build on Linux | ⬜ |

## Phase B — CLI plumbing

| # | Task | Status |
|---|------|--------|
| 2.1 | Add `IsDesktopMode` to `AgentArguments` record | ⬜ |
| 2.2 | Parse `--desktop` flag | ⬜ |
| 3.1 | Create `DesktopHost` stub | ⬜ |
| 3.2 | Dispatch `--desktop` in `Program.cs` | ⬜ |

## Phase C — Photino window

| # | Task | Status |
|---|------|--------|
| 4.1 | Add `Photino.NET` package reference | ⬜ |
| 4.2 | Create desktop asset files (HTML/JS/CSS) | ⬜ |
| 4.3 | Embed desktop assets as resources | ⬜ |
| 4.4 | Add `DesktopAssets` loader class | ⬜ |
| 5.1 | Create `PhotinoWindow` in `DesktopHost` | ⬜ |
| 5.2 | Load embedded HTML into the window | ⬜ |

## Phase D — Agent bridge

| # | Task | Status |
|---|------|--------|
| 6.1 | Create `DesktopObserver` skeleton (IAgentObserver) | ⬜ |
| 6.2 | Implement `SendWebMessage` for each event type | ⬜ |
| 7.1 | Register web-message handler in `DesktopHost` | ⬜ |
| 7.2 | Run `CodingAgent` with `DesktopObserver` on prompt | ⬜ |
| 7.3 | Replace SSE with Photino bridge in `app.js` | ⬜ |
| 7.4 | Reuse Web UI renderers in desktop `app.js` | ⬜ |

## Phase E — Confirmation & polish

| # | Task | Status |
|---|------|--------|
| 8.1 | Send `confirm` event for destructive tools | ⬜ |
| 8.2 | JS confirmation dialog + return answer to .NET | ⬜ |
| 8.3 | Wait for JS answer before dispatching tool | ⬜ |
| 9.1 | Update README / help for `--desktop` | ⬜ |
| 9.2 | Remove leftover SSE/ASP.NET from desktop path | ⬜ |
| 9.3 | Full build + update PROGRESS.md | ⬜ |

---

## Current state

**Step 0 — Setup.** Tasks folder created with all 25 elementary sub-tasks and
the progress tracker. No code changes yet.

**Baseline build:** currently **FAILS** on Linux — the project targets
`net10.0-windows10.0.19041.0` (Windows-only). This is expected and is the
subject of Task 1.1.
