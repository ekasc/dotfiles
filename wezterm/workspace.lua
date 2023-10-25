local wezterm = require("wezterm")

local module = {}
local act = wezterm.action
local mux = wezterm.mux
local tmux = {}

if wezterm.target_triple == "aarch64-apple-darwin" then
	tmux = { "/opt/homebrew/bin/tmux", "new", "-As0" }
else
	tmux = { "tmux", "new", "-As0" }
end

wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()

	return { default_prog = { "/usr/local/bin/zsh" } }
end)

function module.apply_to_config(config)
	config.leader = { key = "a", mods = "CTRL" }
	config.keys = {
		-- default workspace
		{
			key = "y",
			mods = "LEADER",
			action = act.SwitchToWorkspace({
				name = "default",
			}),
		},
		-- switch to monitoring workspace
		{
			key = "u",
			mods = "LEADER",
			action = act.SwitchToWorkspace({
				name = "monitoring",
				spawn = {
					args = { "top" },
				},
			}),
		},
		-- create a new workspace with a random name and switch to it
		{
			key = "i",
			mods = "LEADER",
			action = act.SwitchToWorkspace,
		},
		{
			key = "9",
			mods = "LEADER",
			action = act.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
	}
end

module.default_prog = tmux
return module
