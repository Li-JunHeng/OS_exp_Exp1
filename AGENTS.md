# AGENTS.md

<!-- AUTONOMY DIRECTIVE - DO NOT REMOVE -->
YOU ARE AN AUTONOMOUS CODING AGENT. EXECUTE TASKS TO COMPLETION WITHOUT ASKING FOR PERMISSION.
DO NOT STOP TO ASK "SHOULD I PROCEED?" - PROCEED. DO NOT WAIT FOR CONFIRMATION ON OBVIOUS NEXT STEPS.
IF BLOCKED, TRY AN ALTERNATIVE APPROACH. ONLY ASK WHEN TRULY AMBIGUOUS OR DESTRUCTIVE.
USE CODEX NATIVE SUBAGENTS FOR INDEPENDENT PARALLEL SUBTASKS WHEN THAT IMPROVES THROUGHPUT. THIS IS COMPLEMENTARY TO OMX TEAM MODE.
<!-- END AUTONOMY DIRECTIVE -->

This file governs the entire Exp1 repository.

## Project Context

This repository contains the Verilog materials for the Exp1 CPU task.

- `src/cpu/` contains the editable CPU implementation.
- `src/board/` contains board-level integration files.
- `src/io/` and `src/ip/` contain provided IO/IP helper modules.
- `memory/` contains instruction and data memory initialization files.
- `tests/` contains Icarus Verilog smoke tests and golden outputs.
- `scripts/` contains local automation scripts.
- `results/` is a self-contained Vivado/result subtree and may be a submodule; do not rewrite it unless the task explicitly targets it.
- When parent-repo changes affect source, memory, constraints, or board behavior that is mirrored by `results/`, make the corresponding `results/` submodule update in the same workflow, commit/push the submodule first, then commit/push the parent repository's updated submodule pointer.

## Working Agreements

- Solve the requested task directly when it is safe and clear.
- Prefer existing project patterns over new abstractions.
- Keep diffs small, reviewable, and reversible.
- Prefer deletion and simplification over adding new layers.
- Do not add new dependencies unless explicitly requested.
- Do not revert user changes. If the worktree is dirty, inspect relevant files and work with the existing changes.
- Do not leave mirrored parent/submodule behavior out of sync; every parent change with a `results/` counterpart must be reflected in the submodule before publishing.
- Write a cleanup plan before cleanup/refactor/deslop work.
- Lock behavior with regression tests before cleanup edits when behavior is not already protected.
- Final reports must include changed files, simplifications made, verification performed, and remaining risks when relevant.

## Commands

Use these commands from the repository root:

```sh
make test
```

Runs the Python test harness with Icarus Verilog/VVP.

```sh
make top-syntax
```

Compiles the board-level top with IO/IP stubs for syntax and port-wiring checks.

```sh
make clean
```

Removes generated build output.

## Verification

Verify before claiming completion.

- For CPU RTL changes, run `make test`.
- For board integration changes, run `make top-syntax`.
- For broad RTL changes, run both `make test` and `make top-syntax`.
- If verification cannot run because a tool is missing, report the missing tool and what remains unverified.

## Verilog Guidelines

- Preserve synthesizable Verilog unless the file is clearly testbench-only.
- Keep module ports and signal widths explicit and consistent with existing files.
- Avoid changing provided IP/EDF wrappers unless the task explicitly requires it.
- Keep board-only Vivado files separate from the Mac-side simulation harness.
- When adding test programs, place instruction hex files under `tests/programs/`, golden register snapshots under `tests/golden/`, and register the case in `scripts/run_tests.py`.

## Commit Message Protocol

Every commit message must follow the Lore protocol: an intent line first, followed by narrative context when useful, then git-native trailers as appropriate.

Useful trailers include:

- `Constraint:`
- `Rejected:`
- `Confidence:`
- `Scope-risk:`
- `Reversibility:`
- `Directive:`
- `Tested:`
- `Not-tested:`
- `Related:`

Example:

```text
Prevent silent session drops during long-running operations

The auth service returns inconsistent status codes on token expiry,
so the interceptor catches all 4xx responses and triggers an inline
refresh.

Constraint: Auth service does not support token introspection
Rejected: Extend token TTL to 24h | security policy violation
Confidence: high
Scope-risk: narrow
Tested: Single expired token refresh (unit)
Not-tested: Auth service cold-start > 500ms behavior
```

## `copy` Command

If the user starts a request with `copy args...`, run `args...` as a shell command, capture combined stdout/stderr, copy that exact output to the macOS clipboard, and report the command status. Prefer `/Users/lijunheng/.local/bin/copy` when available.

## OMX Notes

Use OMX skills and state only when they materially improve the task or are explicitly requested. Default to direct solo execution for small, well-scoped changes.

When using workflow skills, load their `SKILL.md` instructions before acting. Delegate only bounded, verifiable subtasks, and own final verification in the main session.
