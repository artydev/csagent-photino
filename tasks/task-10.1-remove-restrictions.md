# Task 10.1 — Remove all tool restrictions

## Objective

Remove all safety restrictions from the tool dispatcher so the agent can
operate without path sandboxing, shell command filtering, destructive-action
confirmation, timeouts, or size caps. This is intended as a temporary
("for now") relaxation that can be restored later.

## Steps

1. **Remove path sandboxing** (`IsSafePath`) from every file tool:
   `write_file`, `read_file`, `read_json`, `list_dir`, `tree`,
   `search_files`, `edit_file`, `copy_file`, `move_file`, `delete_file`,
   `zip`, `unzip`, and all `git_*` tools.
2. **Remove shell command filtering** (`IsSafeCommand`) from `sh` and
   `run_terminal`.
3. **Remove destructive-action confirmation gating** (`IsDestructive` and the
   `_opts.Confirm` branch in `CodingAgent`).
4. **Remove timeouts**:
   - The 60s `ShellTimeoutMs` in `RunGitAsync` and `RunShellAsync`.
   - The timeout clamps in `HttpRequestAsync`, `FetchUrlAsync`,
     `RunTerminalAsync`.
5. **Remove size caps**:
   - `MaxSearchResults`, `MaxSearchFileBytes`, `MaxTreeEntries`,
     `MaxParseOutputBytes` constants.
   - The 512 KB caps in `read_file` / `read_json`.
   - The 512 KB buffer cap in `TerminalSession`.
   - The `maxResults` clamp in `WebSearchAsync`, the `maxChars` clamp in
     `FetchUrlAsync`, and the `count` clamp in `GitLogAsync`.
6. **Remove now-unused helpers and constants**: `IsSafePath`,
   `IsSafeCommand`, `IsDestructive`, `IsBinaryFile`, and the unused
   constants.

## Acceptance criteria

- [ ] No `IsSafePath` / `IsSafeCommand` / `IsDestructive` / `IsBinaryFile`
      references remain in `src`.
- [ ] No timeout or size-cap clamps remain in `ToolDispatcher`.
- [ ] `CodingAgent` no longer gates destructive tools behind confirmation.
- [ ] Project compiles with 0 warnings and 0 errors.

## Verification

```bash
dotnet build -c Debug
```

Expected: `Build succeeded`, `0 Warning(s)`, `0 Error(s)`.
