# Task 10.4 — Verify AOT standalone publish

## Objective

Verify the project publishes as a self-contained AOT (native) executable.

## Steps

1. Run `dotnet publish -c Release -r linux-x64 --self-contained true -p:PublishAot=true`.
2. Confirm the native executable is produced.
3. Confirm the output is an ELF 64-bit x86-64 executable.

## Acceptance criteria

- [ ] AOT publish succeeds with 0 warnings and 0 errors.
- [ ] `bin/Release/net10.0/linux-x64/publish/CsAgentUI` exists and is a native
      ELF 64-bit executable.

## Verification

```bash
dotnet publish -c Release -r linux-x64 --self-contained true -p:PublishAot=true
ls -lh bin/Release/net10.0/linux-x64/publish/
file bin/Release/net10.0/linux-x64/publish/CsAgentUI
```

Expected: `Build succeeded`, `0 Warning(s)`, `0 Error(s)`; native executable
present.
