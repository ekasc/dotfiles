local KisslandTheme = {
	"ekasc/kissland.nvim",
	-- lazy = true,
	priority = 1000,
	dependencies = {
		"rktjmp/lush.nvim",
	},
	config = function()
		vim.cmd.colorscheme("kissland")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

local CatppuccinTheme = {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = true,
	config = function()
		--vim.cmd.colorscheme("catppuccin")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

local PopPunkTheme = {
	"bignimbus/pop-punk.vim",
	name = "punk",
	lazy = true,
	-- priority = 1000,
	config = function()
		-- vim.cmd.colorscheme("pop-punk")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

return { CatppuccinTheme, KisslandTheme, PopPunkTheme }
