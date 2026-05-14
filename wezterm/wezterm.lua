local wezterm = require("wezterm")
local mux = wezterm.mux

local config = {}
-- local workspace = require("workspace")
local styles = require("styles")

config.max_fps = 120
config.animation_fps = 60
config.front_end = "WebGpu"

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- workspace.apply_to_config(config)
styles.apply_to_config(config)

return config
