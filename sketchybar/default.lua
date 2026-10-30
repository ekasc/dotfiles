local settings = require("settings")
local colors = require("colors")

sbar.default({
  updates = "when_shown",
  icon = {
    drawing = false,
    font = { family = settings.font_mono, style = "Regular", size = settings.font_size },
    color = colors.muted,
    padding_left = 0,
    padding_right = 0,
  },
  label = {
    font = { family = settings.font_mono, style = "Regular", size = settings.font_size },
    color = colors.text,
    padding_left = 0,
    padding_right = 0,
  },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
})
