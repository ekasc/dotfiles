return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	use "tpope/vim-fugitive"
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.0',
		-- or 				, branch = '0.1.x',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}
	use "Shatur/neovim-ayu"

	use { "catppuccin/nvim", as = "catppuccin" }
	use "ekasc/kissland.nvim"
	use{
		"nvim-treesitter/nvim-treesitter",
		requires = { "JoosepAlviste/nvim-ts-context-commentstring" },
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })()
		end
	}

	--use "fladson/vim-kitty"
	use {
		'neovim/nvim-lspconfig',
		requires = {
			-- Linter/Formatter
			"creativenull/diagnosticls-configs-nvim",
			-- Tool installer
			{ 'williamboman/mason.nvim' },
			{ 'williamboman/mason-lspconfig.nvim' },
		},
	}
	use {
		'VonHeikemen/lsp-zero.nvim',
		requires = {
			-- LSP Support

			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-buffer' },
			{ 'hrsh7th/cmp-path' },
			{ 'saadparwaiz1/cmp_luasnip' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'hrsh7th/cmp-nvim-lua' },

			-- Snippets
			{ 'L3MON4D3/LuaSnip' },
			{ 'rafamadriz/friendly-snippets' },
		}
	}
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true }
	}

	use 'ray-x/go.nvim'
	use 'ray-x/guihua.lua' -- recommanded if need floating window support
	use 'evanleck/vim-svelte'
	--use 'jose-elias-alvarez/typescript.nvim'
	use 'andweeb/presence.nvim'
	use 'nvim-lua/plenary.nvim' --" don't forget to add this one if you don't have it yet!
	use 'ThePrimeagen/harpoon'
	use "princejoogie/tailwind-highlight.nvim"
	use 'OmniSharp/Omnisharp-vim'
	use 'rktjmp/lush.nvim'
	--use 'phpactor/phpactor'
	--use 'roobert/tailwindcss-colorizer-cmp.nvim'
	--use "jose-elias-alvarez/null-ls.nvim"
	use "tpope/vim-surround"
	use {
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	}
end)
