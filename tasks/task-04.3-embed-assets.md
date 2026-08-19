# Task 4.3 — Embed desktop assets as resources

## Objective

Embed the desktop HTML/JS/CSS as `EmbeddedResource` in the csproj.

## Steps

1. In `CsAgentUI.csproj`, add `<EmbeddedResource>` entries for the three desktop
   asset files (mirror how the Web assets are embedded).

## Acceptance criteria

- [ ] Desktop assets are embedded resources.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
