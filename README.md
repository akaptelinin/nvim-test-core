# nvim-test-core

[![Tests](https://github.com/akaptelinin/nvim-test-core/actions/workflows/test.yml/badge.svg)](https://github.com/akaptelinin/nvim-test-core/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Standalone** mock of Neovim API for unit testing plugins with busted. No real Neovim required.

## Why this exists

| Approach | Requires Neovim | Speed |
|----------|-----------------|-------|
| plenary.nvim | Yes | ~100ms/test |
| mini.test | Yes (child process) | ~50ms/test |
| **nvim-test-core** | **No** | **~1ms/test** |

```bash
# Other frameworks:
nvim --headless -c "PlenaryBustedDirectory tests/"

# This framework:
busted tests/  # just lua, no neovim
```

## What's mocked (~10% of Neovim API)

| Module | Coverage | Notes |
|--------|----------|-------|
| `vim.api` (buffers, windows, tabs) | ✅ Good | Core CRUD operations |
| `vim.api` (autocmds, namespaces) | ✅ Good | Basic functionality |
| `vim.fn` | ⚠️ Partial | ~20 common functions |
| `vim.bo`, `vim.wo`, `vim.o` | ✅ Good | Options tables |
| `vim.loop` | ⚠️ Stubs | TCP/timers return stubs |
| `vim.treesitter` | ❌ Stub | Returns nil |
| `vim.lsp` | ❌ Not included | Use `stub()` if needed |
| `vim.diagnostic` | ❌ Not included | Use `stub()` if needed |

**If something is missing — use `stub()` to add it.**

## Installation

```bash
# As git submodule (recommended)
git clone https://github.com/akaptelinin/nvim-test-core tests/deps/nvim-test-core

# Or add to .gitignore and clone in CI
echo "tests/deps/" >> .gitignore
```

```lua
-- tests/minimal_init.lua
package.path = package.path .. ";./tests/deps/nvim-test-core/lua/?.lua"
package.path = package.path .. ";./tests/deps/nvim-test-core/lua/?/init.lua"
require("nvim-test-core")
```

## Usage

```lua
require("nvim-test-core")

describe("my plugin", function()
    before_each(function()
        vim._mock.reset()
    end)

    it("reads buffer name", function()
        vim._mock.add_buffer(1, "/test/file.go", "package main")

        local name = vim.api.nvim_buf_get_name(1)
        assert.equals("/test/file.go", name)
    end)
end)
```

## Mock helpers

```lua
-- Add buffer with content and options
vim._mock.add_buffer(1, "/path/file.go", "line1\nline2", { filetype = "go" })

-- Add window attached to buffer
vim._mock.add_window(1000, 1, { 5, 10 })  -- winid, bufnr, cursor {line, col}

-- Reset all state between tests
vim._mock.reset()
```

## Stubbing missing functions

**Key feature:** Override or add any function at any path:

```lua
-- Override existing
vim._mock.stub("api.nvim_buf_get_name", function(bufnr)
    return "/always/this/path.go"
end)

-- Add vim.lsp (not in mock by default)
vim._mock.stub("lsp.buf_get_clients", function()
    return {{ name = "gopls" }}
end)

-- Add vim.diagnostic
vim._mock.stub("diagnostic.get", function(bufnr)
    return {}
end)

-- Any depth works (creates intermediate tables)
vim._mock.stub("my.custom.nested.func", function()
    return 42
end)
```

## When to use this vs real Neovim

| Use nvim-test-core | Use real Neovim |
|--------------------|-----------------|
| Testing pure logic | Testing UI/rendering |
| Fast feedback loop | Testing treesitter queries |
| CI without Neovim installed | Testing LSP integration |
| Unit tests | E2E tests |

## Credits

Based on test infrastructure from [claudecode.nvim](https://github.com/coder/claudecode.nvim) by [Coder Technologies Inc.](https://github.com/coder)

## License

MIT
