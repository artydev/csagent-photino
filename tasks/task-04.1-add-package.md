# Task 4.1 — Add `Photino.NET` package reference

## Objective

Add the `Photino.NET` NuGet package to the project.

## Steps

1. In `CsAgentUI.csproj`, add:
   `<PackageReference Include="Photino.NET" Version="3.2.3" />`.

## Acceptance criteria

- [ ] `Photino.NET` package is referenced.
- [ ] Project restores and compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
