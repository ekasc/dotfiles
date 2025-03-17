local M = {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Linter/Formatter
		{
			"stevearc/conform.nvim",
			dependencies = {
				"zapling/mason-conform.nvim",
			},
			event = { "BufWritePre" },
			cmd = "ConformInfo",
			keys = {
				{
					"<leader>f",
					function()
						require("conform").format({ async = true })
					end,
					mode = "",
				},
			},
		},
		-- Tool installer
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "VonHeikemen/lsp-zero.nvim" },
		{ "folke/neodev.nvim" },
		{ "princejoogie/tailwind-highlight.nvim" },
		{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
		{ "OmniSharp/omnisharp-vim" },
		{ "Zeioth/garbage-day.nvim", event = "VeryLazy" },
		{
			"nvim-java/nvim-java",
			dependencies = {
				{ "nvim-java/nvim-java-refactor" },
				{ "nvim-java/nvim-java-core" },
				{ "nvim-java/nvim-java-test" },
				{ "nvim-java/nvim-java-dap" },
				{ "nvim-java/lua-async-await" },
				{ "JavaHello/spring-boot.nvim" },
				{ "mfussenegger/nvim-dap" },
			},
		},
	},
}

function M.config()
	-- Setup for neodev and Mason
	require("neodev").setup()
	local registries = {
		"github:nvim-java/mason-registry",
		"github:mason-org/mason-registry",
	}
	require("mason").setup({
		registries = registries,
		ui = {
			border = "rounded",
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	})

	require("java").setup({
		spring_boot_tools = { enable = false },
		java_test = { enable = false },
		java_debug_adapter = { enable = false },
	})

	local lspconfig = require("lspconfig")
	local format_opts = { async = false, timeout_ms = 2500 }

	-- local function register_fmt_keymap(name, bufnr)
	-- 	vim.keymap.set("n", "<leader>f", function()
	-- 		vim.lsp.buf.format(vim.tbl_extend("force", format_opts, { name = name, bufnr = bufnr }))
	-- 	end, { desc = "Format current buffer [LSP]", buffer = bufnr })
	-- end

	-- Global diagnostic settings
	vim.diagnostic.config({
		underline = { severity_limit = "Error" },
		signs = true,
		update_in_insert = false,
		float = { border = "rounded", source = "if_many" },
	})

	-- LSP handlers with rounded borders
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
	vim.lsp.handlers["textDocument/signatureHelp"] =
		vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

	-- on_attach: common key mappings for LSP buffers
	local function on_attach(client, bufnr)
		vim.keymap.set(
			"n",
			"gt",
			Snacks.picker.lsp_type_definitions,
			{ desc = "Go to type definition", buffer = bufnr }
		)
		vim.keymap.set("n", "gD", Snacks.picker.lsp_declarations, { desc = "Go to declaration [LSP]", buffer = bufnr })
		vim.keymap.set(
			"n",
			"gi",
			Snacks.picker.lsp_implementations,
			{ desc = "Go to implementation [LSP]", buffer = bufnr }
		)
		vim.keymap.set("n", "gw", Snacks.picker.lsp_symbols, { desc = "Document symbols [LSP]", buffer = bufnr })
		vim.keymap.set(
			"n",
			"gW",
			Snacks.picker.lsp_workspace_symbols,
			{ desc = "Workspace symbols [LSP]", buffer = bufnr }
		)
		vim.keymap.set(
			"n",
			"<leader>vrr",
			Snacks.picker.lsp_references,
			{ desc = "Show references [LSP]", buffer = bufnr }
		)
		vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature help [LSP]", buffer = bufnr })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover info [LSP]", buffer = bufnr })
		vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, { desc = "Code action [LSP]", buffer = bufnr })
		vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, { desc = "Rename [LSP]", buffer = bufnr })
		vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, { desc = "Show diagnostic [LSP]", buffer = bufnr })

		-- Map organize imports for both svelte and ts_ls
		if client.name == "svelte" or client.name == "ts_ls" then
			vim.keymap.set(
				"n",
				"<Leader>oi",
				"<Cmd>OrganizeImports<CR>",
				{ desc = "Organize imports [TS]", buffer = bufnr }
			)
		end

		if client.name == "gopls" then
			vim.keymap.set(
				"n",
				"<leader>l",
				require("go.format").goimport,
				{ desc = "Go import [GOPLS]", buffer = bufnr }
			)
		end
	end

	-- LSP capabilities
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities.textDocument.completion.completionItem.preselectSupport = true
	capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
	capabilities.textDocument.completion.completionItem.resolveSupport = {
		properties = { "documentation", "detail", "additionalTextEdits" },
	}

	local default_config = { on_attach = on_attach, capabilities = capabilities }

	-- Mason tool installer and lspconfig setup
	require("mason-tool-installer").setup({
		ensure_installed = { "prettier", "stylua" },
	})

	require("mason-lspconfig").setup({
		ensure_installed = {
			"cssls",
			"gopls",
			"html",
			"jsonls",
			"lua_ls",
			"tailwindcss",
			"ts_ls",
			"svelte",
		},
		automatic_installation = true,
	})

	-- Setup language servers using default_config unless specific options are needed:
	lspconfig.cssls.setup(default_config)
	lspconfig.yamlls.setup(default_config)
	lspconfig.astro.setup(default_config)
	lspconfig.pylsp.setup(default_config)
	lspconfig.bashls.setup(default_config)
	lspconfig.svelte.setup(default_config)
	lspconfig.gopls.setup(default_config)
	lspconfig.jsonls.setup(default_config)
	lspconfig.jdtls.setup(default_config)
	lspconfig.clangd.setup(default_config)
	lspconfig.ltex.setup(default_config)
	lspconfig.html.setup(default_config)
	lspconfig.sqlls.setup({
		default_config,
		root_dir = function()
			return vim.loop.cwd()
		end,
	})
	-- lspconfig.rust_analyzer.setup(default_config)

	-- Tailwind CSS: enable tailwind highlighting and then call common on_attach
	local tw_highlight = require("tailwind-highlight")
	lspconfig.tailwindcss.setup({
		on_attach = function(client, bufnr)
			tw_highlight.setup(client, bufnr, {
				single_column = false,
				mode = "background",
				debounce = 200,
			})
			on_attach(client, bufnr)
		end,
		filetypes = { "javascriptreact", "typescriptreact", "php", "html", "svelte", "css" },
	})

	-- Typescript/JavaScript: organize imports command
	local function organize_imports()
		local params = {
			command = "_typescript.organizeImports",
			arguments = { vim.api.nvim_buf_get_name(0) },
			title = "",
		}
		vim.lsp.buf.execute_command(params)
	end

	lspconfig.ts_ls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		commands = {
			OrganizeImports = { organize_imports, description = "Organize Imports" },
		},
	})

	-- Lua: extend runtime path if needed and setup lua_ls with specific settings
	local lua_rtp = vim.split(package.path, ";")
	table.insert(lua_rtp, "lua/?.lua")
	table.insert(lua_rtp, "lua/?/init.lua")
	lspconfig.lua_ls.setup(vim.tbl_extend("force", default_config, {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	}))

	-- Conform Setup
	---@type conform.setupOpts
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			css = { "stylelint", "prettierd", stop_after_first = true },
			go = { "gofmt" },
			json = { "fixjson" },
			svelte = { "prettierd", "prettier", stop_after_first = true },
			tailwindcss = { "rustywind", "prettierd", stop_after_first = true },
			tex = { "tex-fmt" },
			python = { "black" },
			bash = { "shfmt" },
			java = { "google-java-format" },
			clangd = { "clang-format" },
			html = { "prettierd", "prettier", stop_after_first = true },
			-- php = { "php-cs-fixer" },
		},
		default_format_opts = { lsp_format = "fallback" },
		log_level = vim.log.levels.ERROR,
		-- Conform will notify you when a formatter errors
		notify_on_error = true,
		-- Conform will notify you when no formatters are available for the buffer
		notify_no_formatters = true,
	})

	require("mason-conform").setup({})
end

return M
