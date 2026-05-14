local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
	config.automatically_reload_config = true

	-- Font
	config.font = wezterm.font({
		family = "Miracode",
	})

	config.font_rules = {
		{
			intensity = "Bold",
			font = wezterm.font({
				family = "SauceCodePro Nerd Font Mono",
				weight = "Bold",
				style = "Normal",
			}),
		},
		{
			italic = true,
			font = wezterm.font({
				family = "SauceCodePro Nerd Font Mono",
				weight = "Regular",
				style = "Italic",
			}),
		},
		{
			intensity = "Bold",
			italic = true,
			font = wezterm.font({
				family = "SauceCodePro Nerd Font Mono",
				weight = "Bold",
				style = "Italic",
			}),
		},
	}

	config.font_size = 17.5
	config.adjust_window_size_when_changing_font_size = false

	-- Rendering
	config.front_end = "WebGpu"
	config.default_cursor_style = "SteadyBlock"

	-- Window
	config.window_background_opacity = 1
	-- config.macos_window_background_blur = 20
	config.window_decorations = "RESIZE"

	-- Tab bar
	config.enable_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = true
	config.tab_bar_at_bottom = true
	config.show_new_tab_button_in_tab_bar = true
	config.use_fancy_tab_bar = false

	-- Nightfox colors
	config.colors = {
		foreground = "#cdcecf",
		background = "#000000",

		cursor_fg = "#cdcecf",
		cursor_bg = "#aeafb0",
		cursor_border = "#aeafb0",

		selection_fg = "#cdcecf",
		selection_bg = "#2b3b51",

		ansi = {
			"#393b44", -- black
			"#c94f6d", -- red
			"#81b29a", -- green
			"#dbc074", -- yellow
			"#719cd6", -- blue
			"#9d79d6", -- magenta
			"#63cdcf", -- cyan
			"#dfdfe0", -- white
		},

		brights = {
			"#575860", -- bright black
			"#d16983", -- bright red
			"#8ebaa4", -- bright green
			"#e0c989", -- bright yellow
			"#86abdc", -- bright blue
			"#baa1e2", -- bright magenta
			"#7ad5d6", -- bright cyan
			"#e4e4e5", -- bright white
		},

		indexed = {
			[16] = "#f4a261",
			[17] = "#d67ad2",
		},

		scrollbar_thumb = "#29394f",
		split = "#29394f",

		copy_mode_active_highlight_fg = { Color = "#cdcecf" },
		copy_mode_active_highlight_bg = { Color = "#81b29a" },

		copy_mode_inactive_highlight_fg = { Color = "#cdcecf" },
		copy_mode_inactive_highlight_bg = { Color = "#3c5372" },

		quick_select_label_fg = { Color = "#cdcecf" },
		quick_select_label_bg = { Color = "#f4a261" },

		quick_select_match_fg = { Color = "#cdcecf" },
		quick_select_match_bg = { Color = "#29394f" },

		tab_bar = {
			background = "#000000",

			active_tab = {
				bg_color = "#000000",
				fg_color = "#63cdcf",
			},

			inactive_tab = {
				bg_color = "#000000",
				fg_color = "#cdcecf",
			},

			inactive_tab_hover = {
				bg_color = "#29394f",
				fg_color = "#dfdfe0",
			},

			new_tab = {
				bg_color = "#000000",
				fg_color = "#cdcecf",
			},

			new_tab_hover = {
				bg_color = "#29394f",
				fg_color = "#dfdfe0",
			},
		},
	}
end

return module
