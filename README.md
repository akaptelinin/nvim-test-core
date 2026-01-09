# nvim-test-core

Reusable test infrastructure for Neovim plugins. Provides a comprehensive vim API mock and busted test helpers.

## Credits

Based on the test infrastructure from [claudecode.nvim](https://github.com/coder/claudecode.nvim) by [Coder Technologies Inc.](https://github.com/coder)

## What's included

- **vim_mock.lua** (~1000 lines) — Complete mock of Neovim API:
  - `vim.api` (buffers, windows, tabs, autocmds, keymaps)
  - `vim.fn` (expand, filereadable, getcwd, etc.)
  - `vim.loop` (TCP, timers)
  - `vim.json` (encode/decode)
  - `vim.schedule`, `vim.defer_fn`, `vim.notify`
  - Spy system for tracking function calls

- **init.lua** — Busted test helpers:
  - `expect(value).to_be(expected)`
  - `assert_contains(str, pattern)`
  - `json_encode` / `json_decode`

## Installation

Add as a test dependency (not a runtime dependency).

### With busted

```lua
-- tests/minimal_init.lua
package.path = package.path .. ";./deps/nvim-test-core/lua/?.lua"
package.path = package.path .. ";./deps/nvim-test-core/lua/?/init.lua"

require("nvim-test-core")
```

### Clone as submodule

```bash
git submodule add https://github.com/akaptelinin/nvim-test-core tests/deps/nvim-test-core
```

## Usage

```lua
require("nvim-test-core")

describe("my plugin", function()
    before_each(function()
        vim._mock.reset()
        vim._mock.add_buffer(1, "/test/file.lua", "local x = 1")
    end)

    it("should work", function()
        local bufname = vim.api.nvim_buf_get_name(1)
        expect(bufname).to_be("/test/file.lua")
    end)
end)
```

## Mock helpers

```lua
-- Add a buffer with content
vim._mock.add_buffer(bufnr, name, content, opts)

-- Add a window
vim._mock.add_window(winid, bufnr, cursor)

-- Reset all state
vim._mock.reset()

-- Split string into lines
vim._mock.split_lines(str)
```

## Spy usage

```lua
vim.api.nvim_buf_get_name = spy.new(function(bufnr)
    return "/mocked/path.lua"
end)

-- ... call your code ...

assert.spy(vim.api.nvim_buf_get_name).was_called(1)
```

## License

MIT (same as claudecode.nvim)
