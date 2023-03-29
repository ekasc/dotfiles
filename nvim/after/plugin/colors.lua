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

require('ayu').setup({
	mirage = false,
})

--function KanagawaTheme(color)
--	color = color or "kanagawa"
--	vim.cmd.colorscheme(color)
--
--	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--end

function AyuTheme(color)
	color = color or "ayu"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

--RosePineTheme()
--OneDarkTheme()
--KanagawaTheme()
AyuTheme()
