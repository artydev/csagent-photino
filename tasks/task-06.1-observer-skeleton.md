# Task 6.1 — Create `DesktopObserver` skeleton (IAgentObserver)

## Objective

Create a `DesktopObserver` class that implements `IAgentObserver`.

## Steps

1. Create `src/Presentation/Desktop/DesktopObserver.cs`.
2. Implement `IAgentObserver` with empty method bodies (or `Task.CompletedTask`).
3. Give it a reference to the `PhotinoWindow` (constructor parameter).

## Acceptance criteria

- [ ] `DesktopObserver` implements `IAgentObserver`.
- [ ] It holds a reference to the `PhotinoWindow`.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
