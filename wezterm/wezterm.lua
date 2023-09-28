local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "UltraDark"

config.font = wezterm.font({
	family = "MesloLGS NF",
})
config.font_size = 19
config.adjust_window_size_when_changing_font_size = false
config.front_end = "Software"
config.default_cursor_style = "SteadyBlock"

config.window_background_opacity = 0.75
config.macos_window_background_blur = 5
config.window_decorations = "RESIZE"
config.show_tabs_in_tab_bar = true
config.enable_tab_bar =true
config.hide_tab_bar_if_only_one_tab = true

config.ssh_domains = {
	{
		-- This name identifies the domain
		name = "ekasc",
		-- The hostname or address to connect to. Will be used to match settings
		-- from your ssh config file
		remote_address = "192.168.1.13",
		-- The username to use on the remote host
		username = "ekasc",
	},
	{
		-- This name identifies the domain
		name = "ganeev-hp",
		-- The hostname or address to connect to. Will be used to match settings
		-- from your ssh config file
		remote_address = "192.168.1.10",
		-- The username to use on the remote host
		username = "ganeevkc",
	},
}
config.launch_menu = {
	{
		args = { "top" },
	},
	{
		-- Optional label to show in the launcher. If omitted, a label
		-- is derived from the `args`
		label = "Bash",
		-- The argument array to spawn.  If omitted the default program
		-- will be used as described in the documentation above
		args = { "bash", "-l" },

		-- You can specify an alternative current working directory;
		-- if you don't specify one then a default based on the OSC 7
		-- escape sequence will be used (see the Shell Integration
		-- docs), falling back to the home directory.
		-- cwd = "/some/path"

		-- You can override environment variables just for this command
		-- by setting this here.  It has the same semantics as the main
		-- set_environment_variables configuration option described above
		-- set_environment_variables = { FOO = "bar" },
	},
}

return config
