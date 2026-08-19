# Task 8.2 — JS confirmation dialog + return answer to .NET

## Objective

In the desktop `app.js`, show a JS confirmation dialog for destructive actions
and send the user's answer back to .NET.

## Steps

1. In `app.js`, handle the `confirm` event by showing a dialog
   (e.g. `confirm(...)` or a custom modal).
2. Send the user's yes/no answer back via `window.external.sendMessage` with a
   distinguishable payload (e.g. `{"type":"confirm-answer","value":true}`).

## Acceptance criteria

- [ ] A `confirm` event shows a JS dialog.
- [ ] The user's answer is sent back to .NET.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
