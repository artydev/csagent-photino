# Task 3.1 — Create `DesktopHost` stub

## Objective

Create a stub `DesktopHost` class so `Program.cs` can reference it.

## Steps

1. Create `src/Presentation/Desktop/DesktopHost.cs`.
2. Add `public static void Run(AgentArguments args)` that prints a placeholder
   (e.g. `"Desktop mode coming soon."`).

## Acceptance criteria

- [ ] `DesktopHost.Run(AgentArguments)` exists.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
