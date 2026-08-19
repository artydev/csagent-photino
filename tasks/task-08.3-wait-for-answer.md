# Task 8.3 — Wait for JS answer before dispatching tool

## Objective

In .NET, wait for the JS confirmation answer before dispatching a destructive
tool (or declining it).

## Steps

1. Implement an async wait: when a destructive tool is detected, send the
   `confirm` event and await a `TaskCompletionSource` that is completed when the
   JS answer arrives.
2. The web-message handler must distinguish a `confirm-answer` message from a
   user prompt.
3. "Yes" runs the tool; "No" declines it (return a "declined by user" result).

## Acceptance criteria

- [ ] .NET waits for the JS answer before dispatching.
- [ ] "Yes" runs the tool; "No" declines it.
- [ ] Non-destructive tools run without confirmation.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
