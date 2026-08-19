# Task 7.4 — Reuse Web UI renderers in desktop `app.js`

## Objective

Reuse the Web UI's rendering functions (markdown, tool calls, results, step
counter) in the desktop `app.js`.

## Steps

1. Copy the rendering helpers from `src/Presentation/Web/assets/app.js`:
   - `parseMarkdown`, `createDoneMessage`, `createWarningMessage`,
     `createDangerMessage`, `createToolCallMessage`, `createToolResultMessage`,
     `createGenericMessage`, `appendMessageToLog`, `scrollToBottom`,
     `updateStepCounter`, `resetStepCounter`, `appendUserMessage`.
2. Ensure the desktop `index.html` includes the same CDN libs (marked, Prism).
3. Wire `run()` to send the prompt via the Photino bridge instead of SSE.

## Acceptance criteria

- [ ] Desktop `app.js` reuses the Web UI renderers.
- [ ] Desktop `index.html` loads marked + Prism.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
