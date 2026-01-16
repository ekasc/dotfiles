local M = {
	"nvim-lualine/lualine.nvim",
	enabled = true,
}

function M.config()
	local lualine = require("lualine")

	-- match darkvoid.nvim colors
	local colors = {
		-- bg = "#000000", -- transparent
		fg = "#c0c0c0", -- default text
		accent = "#8cf8f7",
		cursor = "#bdfe58", -- lime
		visual = "#303030", -- subtle dark gray
		comment = "#585858", -- dim gray
		error = "#dea6a0", -- soft red
		warning = "#d6efd8", -- pale green
		hint = "#bedc74", -- yellowish
		info = "#7fa1c3", -- steel blue
		inactive = "#3c3c3c", -- dim line
	}

	local conditions = {
		buffer_not_empty = function()
			return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
		end,
		hide_in_width = function()
			return vim.fn.winwidth(0) > 80
		end,
		check_git_workspace = function()
			local filepath = vim.fn.expand("%:p:h")
			local gitdir = vim.fn.finddir(".git", filepath .. ";")
			return gitdir and #gitdir > 0 and #gitdir < #filepath
		end,
	}

	local theme = {
		normal = {
			a = { fg = "#1c1c1c", bg = colors.accent, gui = "bold" },
			b = { fg = colors.fg, bg = colors.visual },
			c = { fg = colors.fg, bg = colors.bg },
		},
		insert = {
			a = { fg = "#1c1c1c", bg = colors.cursor, gui = "bold" },
			b = { fg = colors.fg, bg = colors.visual },
			c = { fg = colors.fg, bg = colors.bg },
		},
		visual = {
			a = { fg = "#1c1c1c", bg = colors.info, gui = "bold" },
			b = { fg = colors.fg, bg = colors.visual },
			c = { fg = colors.fg, bg = colors.bg },
		},
		replace = {
			a = { fg = "#1c1c1c", bg = colors.error, gui = "bold" },
			b = { fg = colors.fg, bg = colors.visual },
			c = { fg = colors.fg, bg = colors.bg },
		},
		command = {
			a = { fg = "#1c1c1c", bg = colors.hint, gui = "bold" },
			b = { fg = colors.fg, bg = colors.visual },
			c = { fg = colors.fg, bg = colors.bg },
		},
		inactive = {
			a = { fg = colors.comment, bg = "none" },
			b = { fg = colors.comment, bg = "none" },
			c = { fg = colors.comment, bg = "none" },
		},
	}

	local config = {
		options = {
			theme = "catppuccin",
			-- theme = theme,
			component_separators = "",
			section_separators = "",
			disabled_filetypes = {},
			globalstatus = true,
			always_divide_middle = true,
		},
		sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = {},
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = {},
		},
	}

	-- Inserts a component in lualine_c at left section
	local function ins_left(component)
		table.insert(config.sections.lualine_c, component)
	end

	-- Inserts a component in lualine_x ot right section
	local function ins_right(component)
		table.insert(config.sections.lualine_x, component)
	end

	ins_left({
		function()
			return "▊"
		end,
		color = { fg = colors.accent }, -- Sets highlighting of component
		padding = { left = 0, right = 1 }, -- We don't need space before this
	})

	ins_left({
		-- mode component
		function()
			return ""
		end,
		color = function()
			-- auto change color according to neovims mode
			local mode_color = {
				n = colors.accent, -- normal: bright cyan glow
				i = colors.cursor, -- insert: lime
				v = colors.info, -- visual: steel blue
				[""] = colors.info, -- visual block
				V = colors.info, -- visual line
				c = colors.warning, -- command: pale green
				no = colors.accent,
				s = colors.cursor, -- select
				S = colors.cursor,
				[""] = colors.cursor,
				ic = colors.hint, -- insert completion
				R = colors.error, -- replace: soft red
				Rv = colors.error,
				cv = colors.error, -- command-line mode
				ce = colors.error,
				r = colors.accent, -- prompt/confirm
				rm = colors.accent,
				["r?"] = colors.accent,
				["!"] = colors.accent, -- shell or external cmd
				t = colors.accent, -- terminal
			}

			return { fg = mode_color[vim.fn.mode()] }
		end,
		padding = { right = 1 },
	})

	-- Left sections
	ins_left({
		"filesize",
		cond = conditions.buffer_not_empty,
		color = { fg = colors.comment }, -- subtle gray to keep it low-key
	})

	ins_left({
		"filename",
		cond = conditions.buffer_not_empty,
		color = { fg = colors.accent, gui = "bold" }, -- cyan accent for filenames
	})

	ins_left({
		"location",
		color = { fg = colors.cursor }, -- lime = matches caret
	})

	ins_left({
		"progress",
		color = { fg = colors.fg, gui = "bold" }, -- neutral text tone
	})

	ins_left({
		"diagnostics",
		sources = { "nvim_diagnostic" },
		symbols = { error = " ", warn = " ", info = " " },
		diagnostics_color = {
			color_error = { fg = colors.error },
			color_warn = { fg = colors.hint },
			color_info = { fg = colors.info },
		},
	})

	-- Separator / spacer
	ins_left({
		function()
			return "%="
		end,
	})

	-- LSP name indicator
	ins_left({
		function()
			local msg = "No Active LSP"
			local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
			local clients = vim.lsp.get_clients()
			if next(clients) == nil then
				return msg
			end
			for _, client in ipairs(clients) do
				local filetypes = client.config.filetypes
				if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
					return client.name
				end
			end
			return msg
		end,
		icon = " LSP:",
		color = { fg = colors.error, gui = "bold" },
	})

	-- Right sections
	ins_right({
		require("noice").api.statusline.mode.get,
		cond = require("noice").api.statusline.mode.has,
		color = { fg = colors.cursor }, -- lime tone for messages
	})

	ins_right({
		"fileformat",
		fmt = string.upper,
		icons_enabled = false,
		color = { fg = colors.hint, gui = "bold" }, -- yellowish = subtle status info
	})

	ins_right({
		"branch",
		icon = "",
		color = { fg = colors.accent, gui = "bold" }, -- cyan glow for git
	})

	ins_right({
		"diff",
		symbols = { added = " ", modified = "柳 ", removed = " " },
		diff_color = {
			added = { fg = colors.cursor }, -- lime
			modified = { fg = colors.accent }, -- cyan
			removed = { fg = colors.error }, -- soft red
		},
		cond = conditions.hide_in_width,
	})

	ins_right({
		function()
			return "▊"
		end,
		color = { fg = colors.accent },
		padding = { left = 1 },
	})

	-- Make lualine respect colorscheme transparency
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })

	lualine.setup(config)
end

return M
