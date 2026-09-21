# Repository Guidelines

## Project Structure & Module Organization

This repository is currently an empty scaffold: only Git metadata is present. As the project grows, keep runtime Vim9 script under `autoload/` and user-facing commands or mappings under `plugin/`. Put filetype-specific behavior in `ftplugin/`, syntax definitions in `syntax/`, and help pages in `doc/`. Store automated checks in `test/`, mirroring source paths where practical. Avoid committing generated files, editor swap files, or local configuration.

## Build, Test, and Development Commands

No build system or test runner has been committed yet. Until one is added, use these baseline checks:

- `vim --clean -Nu NONE -n -es -S test/run.vim` runs a future headless Vim test entry point.
- `vim --clean -Nu NONE -n -es +'set rtp^=.' +'runtime plugin/*.vim' +qa` checks that plugin files load without startup errors.
- `git diff --check` detects trailing whitespace and malformed patch lines.

When introducing tooling, provide a single documented entry point such as `make test`, and keep this section synchronized with it.

## Coding Style & Naming Conventions

Write new Vim code in Vim9 script and begin applicable files with `vim9script`. Use two-space indentation, no tabs, and concise functions with explicit argument and return types. Prefer `PascalCase` for exported functions, `camelCase` for local functions and variables, and descriptive command names prefixed with the project name to avoid collisions. Keep Scala-facing identifiers consistent with Scala 3 terminology. Document public commands and configuration options in `doc/`.

## Testing Guidelines

Add regression tests for every bug fix and focused tests for new parsing, indentation, syntax, or completion behavior. Name test files after the feature, for example `test/indent.vim`, and make each test independent of the user's vimrc and installed plugins. Tests should run headlessly and leave no files behind. Add the concrete runner and any supported Vim version matrix once established.

## Commit & Pull Request Guidelines

There is no commit history from which to infer an established convention. Use short, imperative subjects such as `Add Scala 3 indentation rules`; keep each commit focused. Pull requests should explain the user-visible change, list verification commands, and link relevant issues. Include before/after examples for syntax or indentation changes and screenshots only when visual highlighting is important. Call out required Vim versions or compatibility tradeoffs explicitly.

既存のvim-scalaのソースを直接参照しないこと
