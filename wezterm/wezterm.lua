local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = 'UltraDark'

config.font = wezterm.font('MesloLGS NF')
config.font_size = 21

config.window_background_opacity = 0.75
config.macos_window_background_blur = 5
config.window_decorations = "RESIZE"
config.show_tabs_in_tab_bar = true
config.enable_tab_bar = false

config.ssh_domains = {
	{
		-- This name identifies the domain
		name = 'ekasc-mac',
		-- The hostname or address to connect to. Will be used to match settings
		-- from your ssh config file
		remote_address = '192.168.1.10',
		-- The username to use on the remote host
		username = 'ekasc',
	},
}


return config
