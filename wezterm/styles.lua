local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
	--
	config.color_scheme = "UltraDark"

	config.font = wezterm.font({
		family = "CommitMono",
	})
	config.font_size = 19
	config.adjust_window_size_when_changing_font_size = false
	config.front_end = "WebGpu"
	config.default_cursor_style = "SteadyBlock"

	config.window_background_opacity = 0.75
	-- config.macos_window_background_blur = 50
	config.window_decorations = "RESIZE"
	config.enable_tab_bar = true
	-- config.show_tabs_in_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = true
	config.tab_bar_at_bottom = true
	config.show_new_tab_button_in_tab_bar = true
	config.use_fancy_tab_bar = false
	config.colors = {
		tab_bar = {
			background = "none",
			active_tab = { bg_color = "none", fg_color = wezterm.color.parse("#FF0000"):lighten(0.15) },
			inactive_tab = { bg_color = "none", fg_color = "#ffffff" },
			inactive_tab_hover = { bg_color = "#2b2040", fg_color = "#c0c0c0" },
		},
	}
end
return module
