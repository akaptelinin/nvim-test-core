# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-09

### Added
- Initial release
- Complete vim API mock (~1000 lines)
  - `vim.api` (buffers, windows, tabs, autocmds, keymaps, namespaces, extmarks, highlights)
  - `vim.fn` (expand, filereadable, getcwd, etc.)
  - `vim.loop` (TCP, timers)
  - `vim.json` (encode/decode)
  - `vim.treesitter` (stub)
  - `vim.bo`, `vim.o`, `vim.g`, `vim.b`
  - `vim.schedule`, `vim.defer_fn`, `vim.notify`
- Busted test helpers
  - `expect(value).to_be(expected)` and friends
  - `assert_contains`, `assert_not_contains`
  - `json_encode`, `json_decode`
- Spy system for tracking function calls
