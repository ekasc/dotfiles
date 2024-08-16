local KisslandTheme = {
	"ekasc/kissland.nvim",
	lazy = true,
	-- priority = 1000,
	-- dependencies = {
	-- 	"rktjmp/lush.nvim",
	-- },
	config = function()
		-- vim.cmd.colorscheme("kissland")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

local CatppuccinTheme = {
	"catppuccin/nvim",
	name = "catppuccin",
	-- lazy = true,
	dependencies = {
		"rktjmp/lush.nvim",
	},
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			transparent_background = true,
			term_colors = true,
			no_bold = false,
			styles = {
				functions = { "bold" },
				loops = { "italic" },
			},
			integrations = {
				telescope = { enabled = true, style = "nvchad" },
				harpoon = true,
			},
			color_overrides = {
				mocha = {
					rosewater = "#efc9c2",
					flamingo = "#ebb2b2",
					pink = "#f2a7de",
					mauve = "#b889f4",
					red = "#ea7183",
					maroon = "#ea838c",
					peach = "#f39967",
					yellow = "#eaca89",
					green = "#96d382",
					teal = "#78cec1",
					sky = "#91d7e3",
					sapphire = "#68bae0",
					blue = "#739df2",
					lavender = "#a0a8f6",
					text = "#b5c1f1",
					subtext1 = "#a6b0d8",
					subtext0 = "#959ec2",
					overlay2 = "#848cad",
					overlay1 = "#717997",
					overlay0 = "#63677f",
					surface2 = "#505469",
					surface1 = "#3e4255",
					surface0 = "#2c2f40",
					base = "#1a1c2a",
					mantle = "#141620",
					crust = "#0e0f16",
				},
			},
		})
		vim.cmd.colorscheme("catppuccin")
		--[[ vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" }) ]]
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

local EverBlush = {
	"Everblush/nvim",
	name = "everblush",
	priority = 1000,
	lazy = true,
	config = function()
		-- vim.cmd.colorscheme("everblush")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

local Base16 = {
	"RRethy/base16-nvim",
	name = "base16",
	priority = 1000,
	lazy = true,
	config = function()
		vim.cmd.colorscheme("base16-windows-10")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

local Leaf = {
	"daschw/leaf.nvim",
	name = "leaf",
	priority = 1000,
	lazy = true,
	config = function()
		vim.cmd.colorscheme("leaf")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end
}

return { CatppuccinTheme, KisslandTheme, PopPunkTheme, EverBlush, Base16, Leaf }
