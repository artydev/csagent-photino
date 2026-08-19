# Task 8.1 — Send `confirm` event for destructive tools

## Objective

When the agent wants to run a destructive tool, send a `confirm` event to the
JS side with the tool name.

## Steps

1. In `DesktopHost` (or a helper), detect destructive tools via
   `ToolDispatcher.IsDestructive(name)`.
2. Send a `confirm` message to the JS side with the tool name.

> The actual wait-for-answer logic is in Task 8.3. For this task, just send the
> event.

## Acceptance criteria

- [ ] Destructive tools trigger a `confirm` event to JS.
- [ ] Non-destructive tools do not.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
