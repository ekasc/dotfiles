-- Left, after workspaces: `│  App   title`.
-- App name semibold/bright, title regular/muted. No icons, no ids.
local colors = require("colors")
local settings = require("settings")
local spaces = require("items.spaces")

local ROVR = "/usr/local/bin/rovr"

local sep = sbar.add("item", "sep", {
  position = "left",
  label = {
    string = "│", -- U+2502: same rule as the workspace divider, one rhythm
    color = colors.faint,
    font = { family = settings.font_mono, style = "Regular", size = settings.font_small },
  },
  padding_left = settings.sep_pad_l,
  padding_right = settings.sep_pad_r,
})

local app = sbar.add("item", "focus.app", {
  position = "left",
  label = {
    string = "",
    color = colors.text,
    font = { family = settings.font_mono, style = "Semibold", size = settings.font_size },
  },
  padding_left = 2,
  padding_right = 8,
})

local title = sbar.add("item", "focus.title", {
  position = "left",
  label = {
    string = "",
    color = colors.muted,
    max_chars = 64,
    font = { family = settings.font_mono, style = "Regular", size = settings.font_size },
  },
  padding_left = 0,
  padding_right = 4,
})

local function on_event(env)
  sep:set({ drawing = true })
  local a = tostring(env.APP or "")
  local t = tostring(env.TITLE or "")
  if a == "" then
    app:set({ label = { string = "Desktop" } })
    title:set({ drawing = false })
  else
    app:set({ label = { string = a } })
    if t == "" then
      title:set({ drawing = false })
    else
      title:set({ drawing = true, label = { string = t } })
    end
  end
end

sep:subscribe("rovr_state", function(env)
  spaces.on_event(env)
  on_event(env)
end)

-- On a failed or malformed query (rovr missing, bad JSON), hide the whole
-- focus cluster rather than leave a stray separator or a stale label.
local function hide_focus()
  sep:set({ drawing = false })
  app:set({ label = { string = "" } })
  title:set({ drawing = false })
end

-- One-time startup init (reactive events don't replay for late SketchyBar).
sbar.exec(ROVR .. " query --current", function(cur)
  local ok = pcall(function()
    if type(cur) ~= "table" then hide_focus() return end
    local w = cur.window
    if type(w) ~= "table" then
      on_event({ APP = "", TITLE = "" })
    else
      on_event({ APP = w.app or "", TITLE = w.title or "" })
    end
  end)
  if not ok then hide_focus() end
end)

spaces.start()

return { on_event = on_event }
