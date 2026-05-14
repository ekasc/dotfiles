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

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

function module.apply_to_config(config)
	config.default_prog = tmux

	config.leader = { key = "a", mods = "CTRL" }

	config.keys = config.keys or {}

	table.insert(config.keys, {
		key = "y",
		mods = "LEADER",
		action = act.SwitchToWorkspace({
			name = "default",
		}),
	})

	table.insert(config.keys, {
		key = "u",
		mods = "LEADER",
		action = act.SwitchToWorkspace({
			name = "monitoring",
			spawn = {
				args = { "top" },
			},
		}),
	})

	table.insert(config.keys, {
		key = "i",
		mods = "LEADER",
		action = act.SwitchToWorkspace,
	})

	table.insert(config.keys, {
		key = "9",
		mods = "LEADER",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	})
end

return module
