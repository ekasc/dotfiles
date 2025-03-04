local M = {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Linter/Formatter
		{ "creativenull/diagnosticls-configs-nvim" },
		-- Tool installer
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "VonHeikemen/lsp-zero.nvim" },
		{ "folke/neodev.nvim" },
		{ "princejoogie/tailwind-highlight.nvim" },
		{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
		--[[ { "yuchanns/phpfmt.nvim" },
		{
			"phpactor/phpactor",
			ft = "php",
			version = "*",
			build = "composer install --no-dev -o",
		}, ]]
		{
			"OmniSharp/omnisharp-vim",
		},
		{ "Zeioth/garbage-day.nvim", event = "VeryLazy" },
		{
			"nvim-java/nvim-java",
			dependencies = {
				{ "nvim-java/nvim-java-refactor" },
				{ "nvim-java/nvim-java-core" },
				{ "nvim-java/nvim-java-test" },
				{ "nvim-java/nvim-java-dap" },
				{ "nvim-java/nvim-java" },
				{ "nvim-java/lua-async-await" },
				{ "JavaHello/spring-boot.nvim" },
				{ "mfussenegger/nvim-dap" },
			},
		},
	},
}

function M.config()
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
		spring_boot_tools = {
			enable = false,
		},
		java_test = {
			enable = false,
		},
		java_debug_adapter = {
			enable = false,
		},
	})
	local lspconfig = require("lspconfig")
	local diagnosticls = require("diagnosticls-configs")
	-- local format_group = vim.api.nvim_create_augroup("LspFormatGroup", {})
	local format_opts = { async = false, timeout_ms = 2500 }

	local function register_fmt_keymap(name, bufnr)
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format(vim.tbl_extend("force", format_opts, { name = name, bufnr = bufnr }))
		end, { desc = "Format current buffer [LSP]", buffer = bufnr })
	end

	-- Global diagnostic config
	vim.diagnostic.config({
		underline = { severity_limit = "Error" },
		signs = true,
		update_in_insert = false,
		float = {
			border = "rounded",
			source = "always",
		},
	})

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})

	local function on_attach(client, bufnr)
		-- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition [LSP]", buffer = bufnr })
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition", buffer = bufnr })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration [LSP]", buffer = bufnr })
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implentation [LSP]", buffer = bufnr })
		vim.keymap.set(
			"n",
			"gw",
			vim.lsp.buf.document_symbol,
			{ desc = "Search document symbols [LSP]", buffer = bufnr }
		)
		vim.keymap.set(
			"n",
			"gW",
			vim.lsp.buf.workspace_symbol,
			{ desc = "Search workspace symbols [LSP]", buffer = bufnr }
		)
		vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, { desc = "Show references [LSP]", buffer = bufnr })
		vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, { desc = "Show signature help [LSP]", buffer = bufnr })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show stuff on hover", buffer = bufnr })
		vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, { desc = "Code action [LSP]", buffer = bufnr })
		vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, { desc = "Rename [LSP]", buffer = bufnr })
		vim.keymap.set(
			"n",
			"<leader>vd",
			vim.diagnostic.open_float,
			{ desc = "Show diagnostic at line [LSP]", buffer = bufnr }
		)

		if client.name == "svelte" then
			vim.keymap.set(
				"n",
				"<Leader>oi",
				"<Cmd>OrganizeImports<CR>",
				{ desc = "Organize imports [TS]", buffer = bufnr }
			)
		end

		if client.name == "ts_ls" then
			vim.keymap.set(
				"n",
				"<Leader>oi",
				"<Cmd>OrganizeImports<CR>",
				{ desc = "Organize imports [TS]", buffer = bufnr }
			)
		end

		if client.name == "gopls" then
			-- GoImport
			vim.keymap.set("n", "<leader>l", require("go.format").goimport)
		end

		--[[ vim.keymap.set("n", "<leader>l", function()
			require("phpfmt").formatting()
		end, { desc = "PHP Code format [LSP]", buffer = bufnr }) ]]
	end

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities.textDocument.completion.completionItem.preselectSupport = true
	capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
	capabilities.textDocument.completion.completionItem.resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	}

	local default_config = {
		on_attach = on_attach,
		capabilities = capabilities,
	}

	require("mason-tool-installer").setup({
		ensure_installed = {
			"eslint_d",
			"prettier",
			"stylua",
		},
	})
	require("mason-lspconfig").setup({
		ensure_installed = {
			"cssls",
			"diagnosticls",
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

	-- Language Servers
	lspconfig.cssls.setup(default_config)
	lspconfig.yamlls.setup(default_config)
	-- lspconfig.svelte.setup(default_config)
	lspconfig.eslint.setup(default_config)
	-- lspconfig.astro.setup({
	-- 	on_attach = function(client, bufnr)
	-- 		register_fmt_keymap(client, bufnr)
	-- 		on_attach(client, bufnr)
	-- 	end,
	-- 	capabilities = capabilities,
	-- })
	lspconfig.astro.setup({})
	-- lspconfig.pylsp.setup(default_config)
	lspconfig.sqlls.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("sqlfmt", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
		root_dir = function(_)
			return vim.loop.cwd()
		end,
	})
	lspconfig.pylsp.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("pylsp", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})
	lspconfig.bashls.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("bashls", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})

	-- lspconfig.htmx.setup(default_config)

	lspconfig.svelte.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("svelte", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})

	lspconfig.rust_analyzer.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("rust_analyzer", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})

	lspconfig.gopls.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("gopls", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})
	lspconfig.jsonls.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("jsonls", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})
	-- java
	lspconfig.jdtls.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("jdtls", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})

	lspconfig.clangd.setup({
		on_attach = function(client, bufnr)
			register_fmt_keymap("clangd", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})

	-- csharp
	lspconfig.omnisharp.setup({
		-- cmd = { "dotnet", "~/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll" },

		-- Enables support for reading code style, naming convention and analyzer
		-- settings from .editorconfig.
		enable_editorconfig_support = true,

		-- If true, MSBuild project system will only load projects for files that
		-- were opened in the editor. This setting is useful for big C# codebases
		-- and allows for faster initialization of code navigation features only
		-- for projects that are relevant to code that is being edited. With this
		-- setting enabled OmniSharp may load fewer projects and may thus display
		-- incomplete reference lists for symbols.
		enable_ms_build_load_projects_on_demand = false,

		-- Enables support for roslyn analyzers, code fixes and rulesets.
		enable_roslyn_analyzers = true,

		-- Specifies whether 'using' directives should be grouped and sorted during
		-- document formatting.
		organize_imports_on_format = true,

		-- Enables support for showing unimported types and unimported extension
		-- methods in completion lists. When committed, the appropriate using
		-- directive will be added at the top of the current file. This option can
		-- have a negative impact on initial completion responsiveness,
		-- particularly for the first few completion sessions after opening a
		-- solution.
		enable_import_completion = true,

		-- Specifies whether to include preview versions of the .NET SDK when
		-- determining which version to use for project loading.
		sdk_include_prereleases = true,

		-- Only run analyzers against open files when 'enableRoslynAnalyzers' is
		-- true
		analyze_open_documents_only = false,

		on_attach = function(client, bufnr)
			register_fmt_keymap("omnisharp", bufnr)
			on_attach(client, bufnr)
		end,
		capabilities = capabilities,
	})

	-- lspconfig.omnisharp_mono.setup(default_config)

	-- lspconfig.csharp_ls.setup(default_config)

	lspconfig.html.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "html", "php" },
	})

	-- Tailwind CSS
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

	-- Typescript/JavaScript
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
			OrganizeImports = {
				organize_imports,
				description = "Organize Imports",
			},
		},
	})

	-- Lua
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

	-- PHP
	--[[ lspconfig.phpactor.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		init_options = {
			["php_code_sniffer.enabled"] = true,
			-- ["language_server_php_cs_fixer.enabled"] = true,
		},
	}) ]]

	--[[ require("phpfmt").setup({
		-- Default configs
		cmd = "phpcbf",
		standard = "PSR12",
		auto_format = false,
	}) ]]

	-- local fs = require("diagnosticls-configs.fs")
	--[[ local php_format = require("diagnosticls-configs.formatters.php_cs_fixer")
	php_format = vim.tbl_extend("force", php_format, {
		sourceName = "php-cs-fixer_ext",
		command = fs.executable("php-cs-fixer", fs.Scope.COMPOSER),
		args = {
			"--rules=@PSR12",
			"--using-cache=no",
			"--no-interaction",
			-- "--dry-run",
			"fix",
			"-",
		},
		isStdout = false,
		isStdin = true,
		doesWriteToFile = true,
		ignoreExitCode = true,
		rootPatterns = { "composer.json" },
	}) ]]

	-- local php_lint = require("diagnosticls-configs.linters.phpcs")
	-- php_lint = vim.tbl_extend("force", php_lint, {
	-- 	sourceName = "phpcs_ext",
	-- 	command = fs.executable("phpcs", fs.Scope.COMPOSER),
	-- 	debounce = 100,
	-- 	args = {
	-- 		"--standard=PSR12",
	-- 		"--report=emacs",
	-- 		"-l",
	-- 	},
	-- 	offsetLine = 0,
	-- 	offsetColumn = 0,
	-- 	formatLines = 1,
	-- 	formatPattern = {
	-- 		[[^.*:(\d+):(\d+):\s+(.*)\s+-\s+(.*)(\r|\n)*$]],
	-- 		{ line = 1, column = 2, security = 3, message = { "[phpcs] ", 4 } },
	-- 	},
	-- 	securities = { error = "error", warning = "warning" },
	-- 	rootPatterns = { ".git", "vendor", "composer.json" },
	-- })

	diagnosticls.init({
		on_attach = function(_, bufnr)
			register_fmt_keymap("diagnosticls", bufnr)
			-- register_fmt_autosave("diagnosticls", bufnr)
		end,
		default_config = false,
	})

	local web_config = {
		-- linter = require("diagnosticls-configs.linters.eslint_d"),
		formatter = require("diagnosticls-configs.formatters.prettier"),
	}

	-- local gopls_config = {
	-- 	linter = require("diagnosticls-configs.linters.golangci_lint"),
	-- 	formatter = require("diagnosticls-configs.formatters.gofumpt"),
	-- }

	local html_config = {
		-- linter = require("diagnosticls-configs.linters.stylelint"),
		formatter = require("diagnosticls-configs.formatters.prettier"),
	}
	local css_config = {
		linter = require("diagnosticls-configs.linters.stylelint"),
		formatter = require("diagnosticls-configs.formatters.prettier"),
	}

	local php_config = {
		-- linter = php_lint,
		-- formatter = php_format,
	}
	local python_config = {
		linter = require("diagnosticls-configs.linters.mypy"),
		formatter = require("diagnosticls-configs.formatters.autopep8"),
	}

	diagnosticls.setup({
		javascript = web_config,
		javascriptreact = web_config,
		typescript = web_config,
		typescriptreact = web_config,
		-- svelte = web_config,
		-- go = gopls_config,
		html = html_config,
		css = css_config,
		php = php_config,
		-- python = python_config,
		lua = {
			formatter = require("diagnosticls-configs.formatters.stylua"),
		},
		astro = web_config,
	})
end

return M
