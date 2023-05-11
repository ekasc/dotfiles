--require('rose-pine').setup({
--	disable_background = true
--})

--require('onedark').setup({
--	style = 'deep',
--	transparent = true,
--	term_colors = true,
--})

--require('kanagawa').setup({
--	undercurl = true, -- enable undercurls
--	commentStyle = { italic = true },
--	functionStyle = {},
--	keywordStyle = { italic = true },
--	statementStyle = { bold = true },
--	typeStyle = {},
--	variablebuiltinStyle = { italic = true },
--	specialReturn = true, -- special highlight for the return keyword
--	specialException = true, -- special highlight for exception handling keywords
--	transparent = false,  -- do not set background color
--	dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
--	globalStatus = false, -- adjust window separators highlight for laststatus=3
--	terminalColors = true, -- define vim.g.terminal_color_{0,17}
--})


--function RosePineTheme(color)
--	color = color or "rose-pine"
--	vim.cmd.colorscheme(color)
--
--	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--end
--
--
--function OneDarkTheme(color)
--	color = color or "onedark"
--	vim.cmd.colorscheme(color)
--
--	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--end

--require('ayu').setup({
--	mirage = false,
--})

--function KanagawaTheme(color)
--	color = color or "kanagawa"
--	vim.cmd.colorscheme(color)
--
--	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--end

require("catppuccin").setup({
	flavour = "mocha", -- latte, frappe, macchiato, mocha
	background = {
	                   -- :h background
		light = "latte",
		dark = "mocha",
	},
	transparent_background = true,
	show_end_of_buffer = false, -- show the '~' characters after the end of buffers
	term_colors = false,
	dim_inactive = {
		enabled = false,
		shade = "dark",
		percentage = 0.15,
	},
	no_italic = false, -- Force no italic
	no_bold = false,   -- Force no bold
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
		loops = {},
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
	},
	color_overrides = {},
	custom_highlights = {},
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		telescope = true,
		notify = false,
		mini = false,
		mason = true,
		harpoon = true,
		-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
	},
})

-- setup must be called before loading
function CatTheme(color)
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

--function AyuTheme(color)
--	color = color or "ayu"
--	vim.cmd.colorscheme(color)
--
--	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--end

--RosePineTheme()
--OneDarkTheme()
--KanagawaTheme()
--AyuTheme()

CatTheme()
