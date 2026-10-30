-- Far right: 12h clock, h:MM AM/PM.
local colors = require("colors")
local settings = require("settings")

local clock = sbar.add("item", "clock", {
  position = "right",
  label = {
    string = "--:--",
    color = colors.text,
    font = { family = settings.font_mono, style = "Medium", size = settings.font_size },
  },
  padding_left = settings.item_gap,
  padding_right = settings.edge_pad,
  update_freq = 10,
})

local function update()
  -- 12-hour, no leading zero: "1:05 PM".
  local t = os.date("%I:%M %p"):gsub("^0", "")
  clock:set({ label = { string = t } })
end

clock:subscribe({ "routine", "system_woke" }, update)
update()
