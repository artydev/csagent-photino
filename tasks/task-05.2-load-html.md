# Task 5.2 — Load embedded HTML into the window

## Objective

Load the embedded desktop HTML into the Photino window.

## Steps

1. In `DesktopHost`, call `.Load(...)` with the embedded HTML from
   `DesktopAssets.HtmlUI`.
2. Ensure the HTML (and its JS/CSS) render in the window.

## Acceptance criteria

- [ ] The window loads the embedded HTML.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
