# Task 9.2 — Remove leftover SSE/ASP.NET from desktop path

## Objective

Ensure the desktop mode has no SSE or ASP.NET dependencies.

## Steps

1. Verify the desktop `app.js` has no `EventSource` / SSE code.
2. Verify `DesktopHost` / `DesktopObserver` do not reference ASP.NET or SSE.
3. Remove any unused Web/SSE references from the desktop path.

## Acceptance criteria

- [ ] Desktop mode has no SSE / ASP.NET dependencies.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
