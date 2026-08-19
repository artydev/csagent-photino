# Task 7.2 — Run `CodingAgent` with `DesktopObserver` on prompt

## Objective

When the web-message handler receives a user prompt, run the `CodingAgent` with
a `DesktopObserver`.

## Steps

1. In the web-message handler, treat the received message as a user prompt.
2. Load the memory file, add the user message (mirror `TuiHost`/`ApiEndpoints`).
3. Create a `CodingAgent` with a `DesktopObserver` and run it.
4. Handle the `ALBERT_API_KEY` check.

## Acceptance criteria

- [ ] A user prompt triggers a `CodingAgent` run.
- [ ] The agent uses a `DesktopObserver`.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
