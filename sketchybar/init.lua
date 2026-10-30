-- Load each module in isolation: a runtime error in one item must not abort
-- the whole config (which would leave SketchyBar on its default bar). The
-- error goes to stderr and the remaining items still load.
local function load(name)
  local ok, err = pcall(require, name)
  if not ok then
    io.stderr:write("[sketchybar] " .. name .. " failed: " .. tostring(err) .. "\n")
  end
  return ok
end

load("bar")
load("default")

-- Left: workspaces, separator, focused app/title.
load("items.focused")

-- Right: first-added docks far-right, so clock first, then Herdr.
load("items.clock")
load("items.herdr")
