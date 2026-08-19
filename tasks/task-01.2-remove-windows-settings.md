# Task 1.2 — Remove/neutralise Windows-only csproj settings

## Objective

Remove or neutralise csproj settings that are Windows-only or that break
cross-platform builds.

## Steps

1. Review `CsAgentUI.csproj` for Windows-only settings:
   - `DisableRuntimeMarshalling` — keep (cross-platform safe).
   - `PlatformTarget` / `Platforms` — keep but ensure they don't force Windows.
   - Any `net10.0-windows...` references — remove.
2. Ensure no `EnableWindowsTargeting` hack is required.

## Acceptance criteria

- [ ] No Windows-only TFM or settings remain.
- [ ] Project builds without `EnableWindowsTargeting`.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
