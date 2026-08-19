# Task 1.1 — Change TFM to `net10.0`

## Objective

Change the target framework from the Windows-only `net10.0-windows10.0.19041.0`
to the cross-platform `net10.0`.

## Steps

1. In `CsAgentUI.csproj`, change:
   `<TargetFramework>net10.0-windows10.0.19041.0</TargetFramework>`
   to
   `<TargetFramework>net10.0</TargetFramework>`.

## Acceptance criteria

- [ ] `CsAgentUI.csproj` targets `net10.0` (not `net10.0-windows...`).

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded` (or only remaining errors are from Task 1.2's
Windows-only settings).
