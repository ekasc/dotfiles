local wezterm = require("wezterm")

local config = {}
local workspace = require("workspace")
local styles = require("styles")

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- workspace.apply_to_config(config)
styles.apply_to_config(config)

return config
