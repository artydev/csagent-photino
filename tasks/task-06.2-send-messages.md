# Task 6.2 — Implement `SendWebMessage` for each event type

## Objective

Make each `DesktopObserver` method send a JSON message to the JS side via
`window.SendWebMessage`.

## Steps

1. Add a private `Send(type, data)` helper that serialises `{ type, data }` to
   JSON and calls `_window.SendWebMessage(json)`.
2. Implement each `OnXxx` method to call `Send`:
   - `OnStep` → `step` with `{ n, m }`
   - `OnThought` → `thought` with text
   - `OnToolCall` → `call` with `{ n, a }`
   - `OnToolResult` → `result` with `{ r, e }`
   - `OnDone` → `done` with message
   - `OnError` → `error` with message
   - `OnWarning` → `warning` with message
   - `OnDanger` → `danger` with message

## Acceptance criteria

- [ ] Each observer method sends a JSON message to the window.
- [ ] Message types match the Web UI contract.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
