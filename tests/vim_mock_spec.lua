package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

require("nvim-test-core")

describe("vim_mock", function()
	before_each(function()
		vim._mock.reset()
	end)

	describe("buffers", function()
		it("creates buffer with add_buffer", function()
			vim._mock.add_buffer(1, "/test/file.go", "package main", { filetype = "go" })
			assert.equals("go", vim.bo[1].filetype)
		end)

		it("nvim_buf_get_name returns buffer path", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			assert.equals("/test/file.go", vim.api.nvim_buf_get_name(1))
		end)

		it("nvim_buf_get_lines returns buffer lines", function()
			vim._mock.add_buffer(1, "/test/file.go", "line1\nline2\nline3")
			local lines = vim.api.nvim_buf_get_lines(1, 0, -1, false)
			assert.is_table(lines)
		end)

		it("nvim_buf_line_count returns number", function()
			vim._mock.add_buffer(1, "/test/file.go", "a\nb\nc")
			local count = vim.api.nvim_buf_line_count(1)
			assert.is_number(count)
		end)

		it("nvim_get_current_buf returns current buffer", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			vim._mock.add_window(1000, 1, { 1, 0 })
			assert.equals(1, vim.api.nvim_get_current_buf())
		end)

		it("nvim_list_bufs returns all buffers", function()
			vim._mock.add_buffer(1, "/test/a.go", "a")
			vim._mock.add_buffer(2, "/test/b.go", "b")
			local bufs = vim.api.nvim_list_bufs()
			assert.equals(2, #bufs)
		end)
	end)

	describe("windows", function()
		it("creates window with add_window", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			vim._mock.add_window(1000, 1, { 5, 10 })
			assert.equals(1000, vim.api.nvim_get_current_win())
		end)

		it("nvim_win_get_buf returns window buffer", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			vim._mock.add_window(1000, 1, { 1, 0 })
			assert.equals(1, vim.api.nvim_win_get_buf(1000))
		end)

		it("nvim_win_get_cursor returns cursor position", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			vim._mock.add_window(1000, 1, { 5, 10 })
			local cursor = vim.api.nvim_win_get_cursor(1000)
			assert.equals(5, cursor[1])
			assert.equals(10, cursor[2])
		end)

		it("nvim_win_set_cursor updates position", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			vim._mock.add_window(1000, 1, { 1, 0 })
			vim.api.nvim_win_set_cursor(1000, { 10, 5 })
			local cursor = vim.api.nvim_win_get_cursor(1000)
			assert.equals(10, cursor[1])
			assert.equals(5, cursor[2])
		end)
	end)

	describe("namespaces", function()
		it("nvim_create_namespace returns unique id", function()
			local ns1 = vim.api.nvim_create_namespace("test1")
			local ns2 = vim.api.nvim_create_namespace("test2")
			assert.is_number(ns1)
			assert.is_number(ns2)
			assert.not_equals(ns1, ns2)
		end)

		it("nvim_create_namespace returns same id for same name", function()
			local ns1 = vim.api.nvim_create_namespace("same")
			local ns2 = vim.api.nvim_create_namespace("same")
			assert.equals(ns1, ns2)
		end)
	end)

	describe("extmarks", function()
		it("nvim_buf_set_extmark creates extmark", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			local ns = vim.api.nvim_create_namespace("test")
			local id = vim.api.nvim_buf_set_extmark(1, ns, 0, 0, {})
			assert.is_number(id)
		end)

		it("nvim_buf_clear_namespace clears extmarks", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			local ns = vim.api.nvim_create_namespace("test")
			vim.api.nvim_buf_set_extmark(1, ns, 0, 0, {})
			vim.api.nvim_buf_clear_namespace(1, ns, 0, -1)
		end)
	end)

	describe("highlights", function()
		it("nvim_set_hl sets highlight group", function()
			vim.api.nvim_set_hl(0, "TestGroup", { fg = "#ff0000" })
		end)

		it("nvim_get_hl returns highlight group", function()
			vim.api.nvim_set_hl(0, "TestGetHl", { fg = "#00ff00", bold = true })
			local hl = vim.api.nvim_get_hl(0, { name = "TestGetHl" })
			assert.are.equal("#00ff00", hl.fg)
			assert.is_true(hl.bold)
		end)

		it("nvim_get_hl returns empty for unknown group", function()
			local hl = vim.api.nvim_get_hl(0, { name = "NonExistentGroup" })
			assert.is_nil(hl.fg)
		end)

		it("nvim_get_hl with link=false returns same result", function()
			vim.api.nvim_set_hl(0, "TestLinkFalse", { fg = "#0000ff" })
			local hl = vim.api.nvim_get_hl(0, { name = "TestLinkFalse", link = false })
			assert.are.equal("#0000ff", hl.fg)
		end)

		it("nvim_buf_add_highlight adds highlight", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			local id = vim.api.nvim_buf_add_highlight(1, 0, "TestGroup", 0, 0, 5)
			assert.is_number(id)
		end)
	end)

	describe("autocommands", function()
		it("nvim_create_augroup creates group", function()
			local id = vim.api.nvim_create_augroup("TestGroup", { clear = true })
			assert.is_number(id)
		end)

		it("nvim_create_autocmd creates autocmd", function()
			local group = vim.api.nvim_create_augroup("TestGroup", { clear = true })
			local id = vim.api.nvim_create_autocmd("BufEnter", {
				group = group,
				pattern = "*.go",
				callback = function() end,
			})
			assert.is_number(id)
		end)

		it("nvim_create_autocmd with group ID stores in correct group", function()
			local group_id = vim.api.nvim_create_augroup("MyGroup", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = group_id,
				callback = function() end,
			})
			local group_data = vim._autocmds["MyGroup"]
			assert.is_table(group_data)
			assert.is_table(group_data.events)
			assert.equals(1, #group_data.events)
			assert.equals("ColorScheme", group_data.events[1].events)
		end)
	end)

	describe("user commands", function()
		it("nvim_create_user_command creates command", function()
			vim.api.nvim_create_user_command("TestCmd", function() end, {})
		end)
	end)

	describe("options", function()
		it("vim.bo returns buffer options", function()
			vim._mock.add_buffer(1, "/test/file.go", "content", { filetype = "go" })
			assert.equals("go", vim.bo[1].filetype)
		end)

		it("vim.wo returns window options", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			vim._mock.add_window(1000, 1, { 1, 0 })
			assert.is_table(vim.wo[1000])
		end)
	end)

	describe("vim.fn", function()
		it("expand returns path", function()
			local result = vim.fn.expand("%:p")
			assert.is_string(result)
		end)

		it("filereadable returns number", function()
			local result = vim.fn.filereadable("/some/path")
			assert.is_number(result)
		end)

		it("getcwd returns string", function()
			local result = vim.fn.getcwd()
			assert.is_string(result)
		end)
	end)

	describe("vim.treesitter", function()
		it("get_parser returns nil (stub)", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			local parser = vim.treesitter.get_parser(1, "go")
			assert.is_nil(parser)
		end)
	end)

	describe("reset", function()
		it("clears all state", function()
			vim._mock.add_buffer(1, "/test/file.go", "content")
			vim._mock.add_window(1000, 1, { 1, 0 })
			vim.api.nvim_create_namespace("test")

			vim._mock.reset()

			local bufs = vim.api.nvim_list_bufs()
			assert.equals(0, #bufs)
		end)
	end)

	describe("stub", function()
		it("overrides api function", function()
			vim._mock.stub("api.nvim_buf_get_name", function(bufnr)
				return "/stubbed/path.go"
			end)
			assert.equals("/stubbed/path.go", vim.api.nvim_buf_get_name(1))
			assert.equals("/stubbed/path.go", vim.api.nvim_buf_get_name(999))
		end)

		it("overrides fn function", function()
			vim._mock.stub("fn.getcwd", function()
				return "/my/custom/dir"
			end)
			assert.equals("/my/custom/dir", vim.fn.getcwd())
		end)

		it("overrides deeply nested path", function()
			vim._mock.stub("lsp.buf.format", function()
				return "formatted"
			end)
			assert.equals("formatted", vim.lsp.buf.format())
		end)

		it("creates intermediate tables if needed", function()
			vim._mock.stub("custom.nested.deep.func", function()
				return 42
			end)
			assert.equals(42, vim.custom.nested.deep.func())
		end)

		it("overrides single level", function()
			vim._mock.stub("notify", function(msg)
				return "notified: " .. msg
			end)
			assert.equals("notified: hello", vim.notify("hello"))
		end)
	end)
end)
