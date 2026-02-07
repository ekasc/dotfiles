local M = {
	"pmizio/typescript-tools.nvim",
	dependencies = {
		"davidosomething/format-ts-errors.nvim",
		config = function()
			require("format-ts-errors").setup({
				add_markdown = false, -- wrap output with markdown ```ts ``` markers
				start_indent_level = 0, -- initial indent
			})
		end,
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	},
	opts = {},
}

local utils = require("ekasc.lsp.utils")

M.config = function()
	require("typescript-tools").setup({
		handlers = {
			["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
				if result.diagnostics == nil then
					return
				end

				-- ignore some tsserver diagnostics
				local idx = 1
				while idx <= #result.diagnostics do
					local entry = result.diagnostics[idx]

					local formatter = require("format-ts-errors")[entry.code]
					entry.message = formatter and formatter(entry.message) or entry.message

					-- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
					if entry.code == 80001 then
						-- { message = "File is a CommonJS module; it may be converted to an ES module.", }
						table.remove(result.diagnostics, idx)
					else
						idx = idx + 1
					end
				end

				vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
			end,
		},
		settings = {
			expose_as_code_action = "all",
			tsserver_max_memory = 2048,
			separate_diagnostic_server = true,
		},
		capabilities = utils.capabilities,
		on_attach = utils.on_attach,
	})
end

return M
