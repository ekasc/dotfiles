local lsp = require("lsp-zero")
local lspconfig = require("lspconfig")
local diagnosticls = require("diagnosticls-configs")

local omnisharp_bin = "/usr/local/bin/omnisharp-roselyn/OmniSharp"
local pid = vim.fn.getpid()

--local psalm_bin = "~/.composer/vendor/bin/psalm"

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
cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered()
	},
	mapping = lsp.defaults.cmp_mappings({
		['<C-p'] = cmp.mapping.scroll_docs(-1),
		['<C-n'] = cmp.mapping.scroll_docs(1),
		['<C-y'] = cmp.mapping.confirm({ select = true }),
		["<C-Space>"] = cmp.mapping.complete(),
	}),
	formatting = {
		format = require('lspkind').cmp_format({
			mode = 'symbol',
			maxwidth = 50,
			ellipsis_char = '...',
		})
	},
	sources = cmp.config.sources({
		{ name = 'luasnip' },
	})
})


lsp.set_preferences({
	sign_icons = {}
})

-- C
lspconfig.clangd.setup({
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


lspconfig.omnisharp.setup({
	cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) }
})

lsp.configure('intelephense', {
	settings = {
		intelephense = {
			telemetry = {
				enabled = false,
			},
		}
	}
})


lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }


	vim.keymap.set('n', "gd", vim.lsp.buf.definition, { desc = "Go to definition [LSP]", buffer = bufnr })
	vim.keymap.set('n', "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition [LSP]", buffer = bufnr })
	vim.keymap.set('n', "K", vim.lsp.buf.hover, { desc = "Show stuff on hover", buffer = bufnr })
	vim.keymap.set('n', "<leader>vws", vim.lsp.buf.workspace_symbol,
		{ desc = "Search workspace symbols [LSP]", buffer = bufnr })
	vim.keymap.set('n', "<leader>vd", vim.diagnostic.open_float,
		{ desc = "Show diagnostic at line [LSP]", buffer = bufnr })
	vim.keymap.set('n', "[d", vim.diagnostic.goto_next, { desc = "Jump to next reference", buffer = bufnr })
	vim.keymap.set('n', "]d", vim.diagnostic.goto_prev, { desc = "Jump to previous reference", buffer = bufnr })
	vim.keymap.set('n', "<leader>vca", vim.lsp.buf.code_action, { desc = "Code action [LSP]", buffer = bufnr })
	vim.keymap.set('n', "<leader>vrr", vim.lsp.buf.references, { desc = "Show references [LSP]", buffer = bufnr })
	vim.keymap.set('n', "<leader>vrn", vim.lsp.buf.rename, { desc = "Rename [LSP]", buffer = bufnr })
	vim.keymap.set('n', "<c-k>", vim.lsp.buf.signature_help, { desc = "Show signature help [LSP]", buffer = bufnr })
end)

-- Tailwind CSS

-- diagnostics
local web_configs = {
	linter = require("diagnosticls-configs.linters.eslint_d"),
	formatter = require("diagnosticls-configs.formatters.prettier"),
}

diagnosticls.setup({
	javascript = web_configs,
	javascriptreact = web_configs,
	typescript = web_configs,
	typescriptreact = web_configs,
	lua = {
		formatter = require("diagnosticls-configs.formatters.stylua"),
	},
})
lsp.setup()
