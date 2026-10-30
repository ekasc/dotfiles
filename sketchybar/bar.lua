local colors = require("colors")
local settings = require("settings")

sbar.bar({
  height = settings.bar_height,
  color = colors.bg,
  position = "bottom",
  margin = 0,
  y_offset = 0,
  corner_radius = 0,
  border_width = 0,
  blur_radius = 0,
  shadow = false,
  sticky = true,
  padding_left = settings.bar_pad,
  padding_right = settings.bar_pad,
})
