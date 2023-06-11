local lsp = require("lsp-zero")
local tw_highlight = require('tailwind-highlight')

lsp.preset("recommended")

lsp.ensure_installed({
	'tsserver',
	'eslint',
	'gopls',
	'lua_ls',
	'pyright',
	'sqlls',
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-p'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-n'] = cmp.mapping.select_next_item(cmp_select),
	['<C-y'] = cmp.mapping.confirm({ select = true }),
	["<C-Space>"] = cmp.mapping.complete(),
})

lsp.set_preferences({
	sign_icons = {}
})

require('lspconfig').tailwindcss.setup({
	on_attach = function(client, bufnr)
		-- rest of your config
		tw_highlight.setup(client, bufnr, {
			single_column = false,
			mode = 'background',
			debounce = 200,
		})
	end
})

require('lspconfig').clangd.setup({
	cmd = { "clangd", "--background-index" },
	filetype = { "c", "cpp", "h" },
	init_options = {
		clangdFileStatus = true,
		usePlaceholders = true,
		completeUnimported = true,
		semanticHighlighting = true,
		clangdSemanticHighlights = true,
	},
	settings = {
		clangd = {
			formatting = {
				enable = true,
				style = "file",
				fallbackStyle = "llvm",
				tabSize = 4,
			},
		},
	},
})

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set('n', "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set('n', "K", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set('n', "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set('n', "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	vim.keymap.set('n', "[d", function() vim.diagnostic.goto_next() end, opts)
	vim.keymap.set('n', "]d", function() vim.diagnostic.goto_prev() end, opts)
	vim.keymap.set('n', "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set('n', "<leader>vrr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set('n', "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set('i', "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)



lsp.setup()
