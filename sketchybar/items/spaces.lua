-- Left: compact numeric workspaces, i3bar-style.
-- No pills, no icons. The current space carries a 2px underline; a full-height
-- rule separates displays. Only slots that actually changed are painted.
--
-- Multi-display: macOS gives every display its own set of Spaces and numbers
-- `position` GLOBALLY across all of them, so a single flat 1..8 strip (the old
-- rendering) mixed two displays into one row with one underline per display --
-- there was no way to tell which display a number belonged to, and clicking
-- "3" could yank focus onto the other monitor. Spaces are therefore grouped
-- by their display and numbered 1..N WITHIN that display, which is the only
-- numbering a user can hold in their head.
--
-- Visual hierarchy, in order of how much attention it earns:
--   1 2 3 │ 1 2 3 4 5 6 │ Ghostty -- ~/src/rovr
--   ^^^^^ active display, full contrast       ^^^^^ other displays, one grade back
--         ▔▔▔ accent underline = current Space (accent) or another display's
--            current Space (muted)
--         │ rule between displays, click to jump to that display's Space
-- The rule shares glyph, colour and padding with the app-cluster separator, so
-- one rhythm carries both.
--
-- Motion (tactile): a Space switch takes 200-400ms in macOS, so a click is
-- answered OPTIMISTICALLY -- the row moves to the new state at once, and the
-- daemon's own event lands on the same values a moment later, which the delta
-- renderer treats as a no-op. State changes glide instead of blinking: the old
-- underline retracts into the bar colour while the new one grows out of it, and
-- labels glide with them. macOS "Reduce motion" turns every glide into an
-- instant swap, so none of this is load-bearing.
--
-- A single display needs none of the grouping: with one group the rule items
-- stay hidden and the row is exactly the old `1 2 3 4` strip.
--
-- Rule items are interleaved between the slots (created in bar order) and
-- hidden items take no width, so any distribution of up to MAX_SLOTS Spaces
-- across any number of displays renders gap-free.
local colors = require("colors")
local settings = require("settings")

local ROVR = "/usr/local/bin/rovr"
local MAX_SLOTS = 12

-- ~10 frames at 60Hz is ~250ms: long enough to read as motion, short enough
-- that the row is never still gliding when the next real change arrives.
-- (Measured on the live bar: 14 frames lands at ~370ms, which overstays.)
local GLIDE_FRAMES = 10
local RETRACT_FRAMES = 8 -- the old underline lets go first, so the accent
local HOVER_FRAMES = 6   -- reads as travelling to the new space, not swapping

-- Pure Mach event, created without an NSDistributedNotification name.
-- rovrd triggers this natively; the old com.rovr.state.changed path is gone.
sbar.add("event", "rovr_state")

-- Reduce motion: the same check herdr makes. Read once; every glide degrades
-- to an instant swap while it is on.
local reduce_motion = false
sbar.exec("defaults read com.apple.universalaccess reduceMotion 2>/dev/null", function(res)
  reduce_motion = (type(res) == "number" and res == 1)
    or (type(res) == "string" and res:match("^%s*1%s*$") ~= nil)
end)

-- Apply a change now, or glide to it when motion is allowed.
local function glide(frames, apply_fn)
  if reduce_motion then
    apply_fn()
  else
    sbar.animate("sin", frames, apply_fn)
  end
end

local slots = {}      -- [slot] -> number item
local rules = {}      -- [slot] -> display divider item (shown between groups)
local slot_space = {} -- [slot] -> current space id (for click-to-focus)
local rule_space = {} -- [slot] -> that group's current space id (click-to-jump)
local slot_color = {} -- [slot] -> base label colour, so hover can restore it
local rule_color = {} -- [slot] -> base divider colour, so hover can restore it
local hovered = {}    -- [slot] -> pointer is over the item
local applied = {}    -- [slot] -> last painted target (delta renderer)
local retracted = {}  -- [slot] -> os.time() when its underline started gliding out
local id_slot = {}    -- [space id] -> slot

-- Forward declarations: the item loop below closes over these, and Lua would
-- otherwise bind those closures to (nil) globals.
local render, paint, target

local order = {}      -- flat array of {id, number, occupied, group, display_id}
local starts_group = {}-- [slot] -> true when a new display's group starts here
local groups = 0      -- number of display groups in the current render
local observed_current = {} -- [display id] -> the space macOS reports focused there
local active_display = nil -- display holding keyboard focus (from the daemon)
local active_space = nil  -- that display's current Space (from the daemon)

for i = 1, MAX_SLOTS do
  local slot = i
  -- The divider precedes its group's numbers, so bar order is rule, then numbers.
  local rule = sbar.add("item", "ws.rule." .. i, {
    position = "left",
    drawing = false,
    label = {
      string = "│", -- U+2502, present in SF Mono (verified via CoreText)
      color = colors.faint,
      font = { family = settings.font_mono, style = "Regular", size = settings.font_small },
    },
    padding_left = settings.sep_pad_l,
    padding_right = settings.sep_pad_r,
  })
  rule:subscribe("mouse.entered", function()
    rule:set({ label = { color = colors.text } })
  end)
  rule:subscribe("mouse.exited", function()
    rule:set({ label = { color = rule_color[slot] or colors.faint } })
  end)
  rule:subscribe("mouse.clicked", function()
    -- Jump to that display's current Space: focusing a Space on another
    -- display is what switches the active display in macOS.
    local id = rule_space[slot]
    if id then
      local entry = order[slot]
      -- Optimistic: claim the target state now, let the daemon confirm it.
      if entry then
        active_display = entry.display_id
        active_space = id
        render()
      end
      sbar.exec(ROVR .. " space focus " .. tostring(id))
    end
  end)
  rules[i] = rule

  local item = sbar.add("item", "ws." .. i, {
    position = "left",
    drawing = false,
    label = {
      string = tostring(i),
      color = colors.dim,
      font = { family = settings.font_mono, style = "Medium", size = settings.font_size },
    },
    -- Seeded to the bar colour: a space's first underline then grows out of
    -- nothing, and a retract returns to invisible instead of a stray accent.
    background = { drawing = false, color = colors.bg, height = 2, y_offset = -12, corner_radius = 0 },
    padding_left = settings.ws_pad,
    padding_right = settings.ws_pad,
  })
  item:subscribe("mouse.entered", function()
    hovered[slot] = true
    if applied[slot] then applied[slot].label_color = colors.text end
    glide(HOVER_FRAMES, function()
      item:set({ label = { color = colors.text } })
    end)
  end)
  item:subscribe("mouse.exited", function()
    hovered[slot] = nil
    local base = slot_color[slot] or colors.dim
    if applied[slot] then applied[slot].label_color = base end
    glide(HOVER_FRAMES, function()
      item:set({ label = { color = base } })
    end)
  end)
  item:subscribe("mouse.clicked", function()
    local id = slot_space[slot]
    if id then
      local entry = order[slot]
      -- Optimistic focus: the row answers now; the daemon's event arrives with
      -- the same values once the Space switch lands, and changes nothing.
      if entry then
        active_display = entry.display_id
        active_space = id
        render()
      end
      sbar.exec(ROVR .. " space focus " .. tostring(id))
    end
  end)
  slots[i] = item
end

-- What a slot should show right now.
target = function(i, s)
  -- One current Space per display. The daemon's value wins on the display it
  -- reports on -- it is what `rovr space next/prev` acts on and what the
  -- reactive event carries -- because macOS routinely names a different Space
  -- mid-transition; every other display keeps what macOS observed.
  local current = active_space
  if active_display == nil or s.display_id ~= active_display or current == nil then
    current = observed_current[s.display_id]
  end
  local is_focused = current == s.id
  -- Inactive displays step back exactly one grade rather than fading to
  -- nothing: the row must stay readable, just not compete for the eye.
  local active = active_display == nil or s.display_id == active_display
  local color
  if is_focused then
    color = active and colors.text or colors.muted
  else
    color = active and (s.occupied and colors.muted or colors.dim) or colors.dim
  end
  -- Accent means "this is your current Space"; muted means "this is that
  -- display's current Space" -- same marker, one grade of insistence.
  local underline = is_focused and (active and colors.accent or colors.muted) or nil
  return {
    label = tostring(s.number),
    label_color = hovered[i] and colors.text or color,
    underline = underline,
    current = current,
    -- Divider only BETWEEN groups: a leading rule would read as a bracket.
    rule = starts_group[i] == true and groups > 1 and s.group > 1,
    rule_color = active and colors.muted or colors.faint,
  }
end

local function same(a, b)
  return a.label == b.label
    and a.label_color == b.label_color
    and a.underline == b.underline
    and a.rule == b.rule
    and a.rule_color == b.rule_color
end

paint = function(i, s, t, prev)
  local item = slots[i]
  if prev == nil or reduce_motion then
    -- First paint, and every paint under reduced motion, land at once.
    item:set({
      drawing = true,
      label = { string = t.label, color = t.label_color },
      background = { drawing = t.underline ~= nil, color = t.underline or colors.bg },
    })
    if t.rule then
      rules[i]:set({ drawing = true, label = { string = "│", color = t.rule_color } })
    else
      rules[i]:set({ drawing = false })
    end
    retracted[i] = nil
    return
  end

  if prev.label ~= t.label then
    -- Digits never animate: only colour and the underline move.
    item:set({ label = { string = t.label } })
  end
  if prev.label_color ~= t.label_color then
    glide(GLIDE_FRAMES, function()
      item:set({ label = { color = t.label_color } })
    end)
  end
  if prev.underline ~= t.underline then
    if t.underline then
      glide(GLIDE_FRAMES, function()
        item:set({ background = { drawing = true, color = t.underline } })
      end)
      retracted[i] = nil
    else
      -- Retract into the bar colour instead of vanishing, so the accent reads
      -- as travelling to the next space. SketchyBar switches a background on
      -- when a colour is set on it, so this leaves an invisible rect behind;
      -- reap_retracts switches it off once the glide is certainly over.
      glide(RETRACT_FRAMES, function()
        item:set({ background = { color = colors.bg } })
      end)
      retracted[i] = os.time()
    end
  end
  if prev.rule ~= t.rule or prev.rule_color ~= t.rule_color then
    if t.rule then
      glide(GLIDE_FRAMES, function()
        rules[i]:set({ drawing = true, label = { string = "│", color = t.rule_color } })
      end)
    else
      rules[i]:set({ drawing = false })
    end
  end
end

-- Switch off the invisible rects a retract leaves behind. A second is far
-- beyond the 8-frame retract, and reaping on EVERY render (not just sync
-- ticks) means a daemon that emits an event per interaction can never starve
-- the cleanup the way tick-only reaping did.
local function reap_retracts()
  local now = os.time()
  for i, at in pairs(retracted) do
    local t = applied[i]
    if now - at >= 1 and t and t.underline == nil then
      slots[i]:set({ background = { drawing = false, color = colors.bg } })
      retracted[i] = nil
    end
  end
end

render = function()
  id_slot = {}
  for i = 1, MAX_SLOTS do
    local s = order[i]
    if not s then
      -- Empty slot: clear once. Re-clearing every tick would put the row on
      -- the critical path of every sync for four slots that are already blank.
      if applied[i] ~= nil then
        applied[i] = nil
        retracted[i] = nil
        slot_space[i] = nil
        rule_space[i] = nil
        rules[i]:set({ drawing = false })
        slots[i]:set({ drawing = false, background = { drawing = false, color = colors.bg } })
      end
    else
      id_slot[s.id] = i
      slot_space[i] = s.id
      local t = target(i, s)
      rule_space[i] = t.current or s.id
      local prev = applied[i]
      if prev == nil or not same(prev, t) then
        applied[i] = t
        paint(i, s, t, prev)
      end
    end
  end

  reap_retracts()
end

local function refresh()
  -- One exec carries every display's Spaces, the displays themselves (for
  -- grouping and order) and window occupancy, so the routine tick spawns a
  -- single subprocess instead of one per query.
  sbar.exec(ROVR .. " query state", function(state)
    if type(state) ~= "table" or type(state.result) ~= "table" then return end
    local observed = state.result.observed
    if type(observed) ~= "table" then return end
    -- rovrd output is external: parse defensively and keep the last good
    -- render if a shape change throws.
    pcall(function()
      local occupied = {}
      if type(observed.windows) == "table" then
        for _, w in pairs(observed.windows) do
          if type(w) == "table" and type(w.space_id) == "number" then
            occupied[w.space_id] = true
          end
        end
      end

      local spaces = {}
      if type(observed.spaces) == "table" then
        for _, s in pairs(observed.spaces) do
          if type(s) == "table" and type(s.id) == "number"
              and type(s.display_id) == "number" and type(s.position) == "number" then
            spaces[#spaces + 1] = s
          end
        end
      end

      local displays = {}
      if type(observed.displays) == "table" then
        for _, d in pairs(observed.displays) do
          if type(d) == "table" and type(d.id) == "number" then
            displays[#displays + 1] = d
          end
        end
      end
      -- Stable order the row can rely on: main display first, then by physical
      -- position, then by id. Without it the groups reshuffle on every tick.
      table.sort(displays, function(a, b)
        if (a.is_main == true) ~= (b.is_main == true) then return a.is_main == true end
        local ax = type(a.frame) == "table" and a.frame.x or 0
        local bx = type(b.frame) == "table" and b.frame.x or 0
        if ax ~= bx then return ax < bx end
        return a.id < b.id
      end)

      -- A display that owns Spaces but is missing from the display map still
      -- gets its own group (appended last) rather than being silently merged.
      local known = {}
      for _, d in ipairs(displays) do known[d.id] = true end
      local unknown = {}
      for _, s in ipairs(spaces) do
        if not known[s.display_id] then unknown[s.display_id] = true end
      end
      local extra = {}
      for id in pairs(unknown) do extra[#extra + 1] = id end
      table.sort(extra)
      for _, id in ipairs(extra) do
        displays[#displays + 1] = { id = id }
      end

      -- A live event already told us which display has focus; a display that
      -- was unplugged must not leave a stale one behind (it would dim every
      -- group), so forget it when it is gone.
      if active_display ~= nil then
        local present = false
        for _, d in ipairs(displays) do
          if d.id == active_display then present = true break end
        end
        if not present then
          active_display = nil
          active_space = nil
        end
      end
      local focused_display = nil
      for _, d in ipairs(displays) do
        if d.focused == true and (focused_display == nil or d.id < focused_display) then
          focused_display = d.id
        end
      end
      active_display = active_display or focused_display
      for _, d in ipairs(displays) do
        if d.is_main == true then active_display = active_display or d.id break end
      end
      active_display = active_display or (displays[1] and displays[1].id)

      order = {}
      starts_group = {}
      observed_current = {}
      groups = 0
      local slot = 0
      for gi, d in ipairs(displays) do
        local mine = {}
        for _, s in ipairs(spaces) do
          if s.display_id == d.id then mine[#mine + 1] = s end
        end
        table.sort(mine, function(a, b)
          if a.position ~= b.position then return a.position < b.position end
          return a.id < b.id
        end)
        for n, s in ipairs(mine) do
          if slot >= MAX_SLOTS then break end
          slot = slot + 1
          starts_group[slot] = n == 1
          order[slot] = {
            id = s.id,
            number = n,
            occupied = occupied[s.id] or false,
            group = gi,
            display_id = d.id,
          }
          -- One current Space per display, straight from macOS. The daemon's
          -- value overrides this for the active display at render time.
          if s.focused then observed_current[d.id] = s.id end
        end
        if #mine > 0 then groups = groups + 1 end
      end
      render()
    end)
  end)
end

-- Reactive focus update. The daemon reports only the ACTIVE display's current
-- Space, so both values always move together; a display switch simply replaces
-- them.
local function on_event(env)
  local sid = tonumber(env.SPACE)
  local did = tonumber(env.DISPLAY)
  if did then active_display = did end
  if sid then active_space = sid end
  if sid and next(id_slot) ~= nil and id_slot[sid] == nil then
    -- A Space we have no slot for (created or destroyed under us): re-sync now
    -- instead of waiting for the tick.
    refresh()
    return
  end
  render()
end

-- Low-frequency list sync (NOT the focus hot path).
local sync = sbar.add("item", "ws.sync", {
  position = "left",
  drawing = false,
  width = 0,
  updates = "on",
  update_freq = 5,
})
sync:subscribe("routine", refresh)
-- Native macOS space/display switches fire even when rovrd is too busy to
-- emit rovr_state (e.g. right after creating a space), and routine ticks
-- have proven unreliable in this setup, so re-sync on those too.
sync:subscribe("space_change", refresh)
sync:subscribe("display_change", refresh)

return { on_event = on_event, refresh = refresh, start = refresh }
