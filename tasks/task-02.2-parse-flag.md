# Task 2.2 — Parse `--desktop` flag

## Objective

Parse the `--desktop` CLI flag and set `IsDesktopMode = true`.

## Steps

1. In `ArgumentParser.Parse`, add `var isDesktopMode = args.Contains("--desktop");`.
2. Pass it into the `AgentArguments` constructor.
3. Exclude `--desktop` from the positional memory-file detection (like `--ui`).

## Acceptance criteria

- [ ] `--desktop` sets `IsDesktopMode = true`.
- [ ] `--desktop` is not mistaken for a memory file path.
- [ ] Project compiles.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`.
