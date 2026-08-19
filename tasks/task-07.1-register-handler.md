# Task 7.1 — Register web-message handler in `DesktopHost`

## Objective

Register a web-message handler on the Photino window so it can receive messages
from JS.

## Steps

1. In `DesktopHost`, call `.RegisterWebMessageReceivedHandler(...)`.
2. For now, the handler just logs/prints the received message (real logic comes
   in Task 7.2).

## Acceptance criteria

- [ ] The window has a registered web-message handler.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
