# Task 4.4 — Add `DesktopAssets` loader class

## Objective

Add a `DesktopAssets` static class that loads the embedded desktop resources.

## Steps

1. Create `src/Presentation/Desktop/DesktopAssets.cs`.
2. Add `HtmlUI`, `JsUI`, `CssUI` properties that load the embedded resources
   (mirror `StaticAssets` in the Web project).

## Acceptance criteria

- [ ] `DesktopAssets.HtmlUI` / `JsUI` / `CssUI` load the embedded resources.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
