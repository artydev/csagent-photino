# Task 7.3 — Replace SSE with Photino bridge in `app.js`

## Objective

In the desktop `app.js`, replace the SSE/`EventSource` logic with Photino's
message bridge.

## Steps

1. Remove `startChatStream` (SSE/`EventSource`) from the desktop `app.js`.
2. Add a `sendPrompt(prompt)` that calls `window.external.sendMessage(prompt)`.
3. Add `window.external.receiveMessage(cb)` to receive agent events.
4. Route incoming events to the existing renderers.

## Acceptance criteria

- [ ] No SSE / `EventSource` remains in the desktop `app.js`.
- [ ] User prompt is sent via `window.external.sendMessage`.
- [ ] Agent events are received via `window.external.receiveMessage`.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
