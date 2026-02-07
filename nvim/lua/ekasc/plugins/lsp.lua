local M = {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
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
		-- Minimal Java: use nvim-jdtls directly (ftplugin/java.lua starts it per-project)
		{ "mfussenegger/nvim-jdtls", ft = { "java" } },
		{ "JavaHello/spring-boot.nvim", ft = { "java", "yaml", "jproperties" } },
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
	--

	-- Global diagnostic settings
	vim.diagnostic.config({
		underline = { severity_limit = "Error" },
		signs = true,
		update_in_insert = false,
		float = { border = "rounded", source = "if_many" },
		virtual_text = { current_line = true },
	})

	-- LSP handlers with rounded borders

	vim.o.winborder = "rounded"

	-- Mason tool installer and lspconfig setup
	require("mason-tool-installer").setup({
		ensure_installed = {
			"prettier",
			"stylua",
			-- Java
			"jdtls",
			"google-java-format",
		},
	})

	require("mason-lspconfig").setup({
		ensure_installed = {
			"cssls",
			"gopls",
			"html",
			"jsonls",
			"lua_ls",
			"tailwindcss",
			-- "ts_ls",
			"svelte",
		},
		automatic_installation = true,
	})

	-- Conform Setup
	---@diagnostic disable-next-line: undefined-doc-name
	---@type conform.setupOpts
	require("conform").setup({
		formatters = {
			["php-cs-fixer"] = {
				command = "php-cs-fixer",
				args = {
					"fix",
					"--rules=@PSR12", -- Formatting preset. Other presets are available, see the php-cs-fixer docs.
					"$FILENAME",
				},
				stdin = false,
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", stop_after_first = true },
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
			php = { "php-cs-fixer" },
			[".sty"] = { "tex-fmt" },
		},
		default_format_opts = { lsp_format = "fallback" },
		log_level = vim.log.levels.ERROR,
		-- Conform will notify you when a formatter errors
		notify_on_error = true,
		-- Conform will notify you when no formatters are available for the buffer
		notify_no_formatters = true,
	})

	require("mason-conform").setup({})

	require("ekasc.lsp")
end

return M
