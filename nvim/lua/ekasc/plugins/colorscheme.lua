local KanagawaTheme = {
	"rebelot/kanagawa.nvim",

	lazy = true,
	config = function()
		require("kanagawa").setup({
			compile = true, -- enable compiling the colorscheme
			undercurl = true, -- enable undercurls
			commentStyle = { italic = true },
			keywordStyle = { italic = true },
			statementStyle = { bold = true },
			transparent = true, -- do not set background color
			dimInactive = false, -- dim inactive window `:h hl-NormalNC`
			terminalColors = true, -- define vim.g.terminal_color_{0,17}
			colors = { -- add/modify theme and palette colors
				theme = {
					wave = {
						ui = {
							bg = "none",
						},
					},
					all = {
						ui = {
							bg_gutter = "none",
						},
					},
				},
			},
			-- overrides = function(colors) -- add/modify highlights
			-- 	return {}
			-- end,
			overrides = function(colors)
				local theme = colors.theme
				local makeDiagnosticColor = function(color)
					local c = require("kanagawa.lib.color")
					return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
				end
				return {
					NormalFloat = { bg = "none" },
					FloatBorder = { bg = "none" },
					FloatTitle = { bg = "none" },

					-- Save an hlgroup with dark background and dimmed foreground
					-- so that you can use it where your still want darker windows.
					-- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
					NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

					LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
					MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
					TelescopeTitle = { fg = theme.ui.special, bold = true },
					TelescopePromptNormal = { bg = theme.ui.bg_p1 },
					TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
					TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
					TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
					TelescopePreviewNormal = { bg = theme.ui.bg_dim },
					TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
					Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
					PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
					PmenuSbar = { bg = theme.ui.bg_m1 },
					PmenuThumb = { bg = theme.ui.bg_p2 },
					DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
					DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
					DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
					DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),
				}
			end,
			-- theme = "wave", -- Load "wave" theme when 'background' option is not set
			-- background = { -- map the value of 'background' option to a theme
			-- 	dark = "dragon", -- try "dragon" !
			-- 	light = "lotus",
			-- },
		})
		vim.cmd.colorscheme("kanagawa")
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

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

-- local UltraDark = {
-- 	"cosmicthemethhead/ultradark.nvim",
-- 	config = function()
-- 		vim.cmd.colorscheme("ultradark")
-- 		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
-- 		vim.opt.fillchars = { eob = " " }
-- 	end,
-- }

local CatppuccinTheme = {
	"catppuccin/nvim",
	name = "catppuccin",
	-- lazy = true,
	-- dependencies = {
	-- 	"rktjmp/lush.nvim",
	-- },
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
				telescope = {
					enabled = true,
					--	style = "nvchad"
				},
				harpoon = true,
				cmp = true,
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
						ok = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
						ok = { "underline" },
					},
					inlay_hints = {
						background = true,
					},
				},
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
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

local NightfoxTheme = {
	"EdenEast/nightfox.nvim",
	lazy = true,
	config = function()
		require("nightfox").setup({
			options = {
				transparent = true,
			},
		})
		-- vim.cmd.colorscheme("carbonfox")
	end,
}

local DarkvoidTheme = {
	{
		"aliqyan-21/darkvoid.nvim",
		lazy = true,
		config = function()
			require("darkvoid").setup({
				transparent = true,
				glow = true,
				plugins = {
					gitsigns = true,
					nvim_cmp = true,
					treesitter = true,
					nvimtree = true,
					telescope = true,
					lualine = true,
					bufferline = true,
					oil = true,
					whichkey = true,
					nvim_notify = true,
				},
			})

			-- reapply transparency
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
			vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
			vim.opt.fillchars = { eob = " " }

			-- ✅ highlight fixes that Snacks and other UIs inherit
			vim.api.nvim_set_hl(0, "Visual", { bg = "#303030", fg = "#bdfe58", bold = true })
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#303030" })
			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#bdfe58", bold = true })
		end,
	},
}

local OneDarkTheme = {
	"navarasu/onedark.nvim",
	lazy = true,
	-- priority = 10000, -- make sure to load this before all the other start plugins
	config = function()
		require("onedark").setup({
			transparent = true,
			lualine = { transparent = true },
			style = "darker",
		})
		-- Enable theme
		require("onedark").load()
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
		vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none" })
		vim.opt.fillchars = { eob = " " }
	end,
}

return { CatppuccinTheme, KisslandTheme, KanagawaTheme, NightfoxTheme, DarkvoidTheme, OneDarkTheme }
