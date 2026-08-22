# Task 10.6 — Document launching modes

## Objective

Document the different launching modes of the application.

## Steps

1. Read `Program.cs` to identify the mode dispatch logic.
2. Read `src/Shared/ArgumentParser.cs` to identify the CLI flags.
3. Read `src/Shared/HelpDisplay.cs` for the documented usage.
4. Summarise the launching modes and their options.

## Acceptance criteria

- [ ] All launching modes are documented:
      CLI/TUI (default), Web UI (`--ui`), Desktop (`--desktop`).
- [ ] Informational modes (`--help`, `--version`, `--doc`) are documented.
- [ ] Common options (`--mem`, `--model`, `--port`, `--dry-run`) are
      documented.

## Verification

```bash
dotnet run -- --help
```
