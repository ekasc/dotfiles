-- Right: agent status across the herd, from `herdr agent list`,
-- plus T3 Code agents, read from its local sqlite projection
-- (`~/.t3/userdata/statev2.sqlite`, read-only: active runs mapped to
-- working, waiting runs / pending approvals mapped to blocked).
-- Statuses: idle | working | blocked | done | unknown.
-- The label lists only non-empty states in priority order, e.g.
-- `1 blocked · 2 working`, and is capped by max_chars so a large or malformed
-- herd can never stretch the bar.
--
-- Interaction: hover brightens the label; click focuses the agent that most
-- needs attention (blocked > working > done > idle).
--
-- Motion (living indicator): while the highest-priority state is `working`,
-- the robot glyph breathes between the accent ramp's trough and peak. Every
-- other state holds a static colour and glides there on change. macOS
-- "Reduce motion" disables the breathing (the glyph then holds base accent).
local colors = require("colors")
local settings = require("settings")

local HERDR = "/opt/homebrew/bin/herdr"
local POLL_TICKS = 5        -- poll herdr every N one-second routine ticks
local BREATH_FRAMES = 60    -- 60 frames = 1s per half-breath at 60Hz
local GLIDE_FRAMES = 18     -- state-change colour transition
local MAX_LABEL = 56        -- hard cap on label length
local POLL_STALE_TICKS = 20 -- drop a poll whose callback never returned

-- Resolve the binary at startup; keep the absolute default if the lookup
-- fails (launchd's PATH is minimal, so `command -v` may legitimately miss).
sbar.exec("command -v herdr 2>/dev/null", function(res)
  local p = type(res) == "string" and res:gsub("%s+$", "") or ""
  if p:sub(1, 1) == "/" then HERDR = p end
end)

local ORDER = { "blocked", "working", "done", "idle", "unknown" }
local STATUS_COLOR = {
  blocked = colors.err,
  working = colors.accent,
  done    = colors.muted,
  idle    = colors.dim,
  unknown = colors.dim,
}

-- T3 Code has no thread CLI, so the sqlite projection is the bridge.
-- WAL mode: readers never block the app. Quoted via $HOME at exec time.
local T3_DB = "$HOME/.t3/userdata/statev2.sqlite"
local T3_QUERY = "SELECT r.thread_id, r.status, EXISTS(SELECT 1 FROM projection_pending_approvals p WHERE p.thread_id = r.thread_id AND p.status = 'pending') FROM orchestration_v2_projection_runs r WHERE r.status IN ('queued','preparing','starting','running','waiting')"
local T3_WORKING = { queued = true, preparing = true, starting = true, running = true }

local reduce_motion = false
sbar.exec("defaults read com.apple.universalaccess reduceMotion 2>/dev/null", function(res)
  reduce_motion = (type(res) == "number" and res == 1)
    or (type(res) == "string" and res:match("^%s*1%s*$") ~= nil)
end)

-- Status names come from herdr, but treat them as untrusted: collapse
-- whitespace, trim edges, and cap length so one odd value cannot blow up
-- the label.
local function status_name(st)
  local s = st:gsub("%s+", " ")
  s = s:match("^%s*(.-)%s*$") or s
  return s:sub(1, 12)
end

-- agents: array of { agent_status = <string> }.
-- Returns { text, color, motion }; motion is "breathe" only when the
-- highest-priority state present is `working`.
local function summarize(agents)
  local counts, total = {}, 0
  for _, a in ipairs(agents) do
    local st = type(a) == "table" and a.agent_status or nil
    if type(st) == "string" and st ~= "" then
      counts[st] = (counts[st] or 0) + 1
      total = total + 1
    end
  end
  if total == 0 then
    return { text = "no agents", color = colors.dim, motion = "none" }
  end

  local parts, top = {}, nil
  for _, st in ipairs(ORDER) do
    if counts[st] then
      parts[#parts + 1] = string.format("%d %s", counts[st], status_name(st))
      if not top then top = st end
    end
  end
  for st, n in pairs(counts) do
    local known = false
    for _, s in ipairs(ORDER) do
      if s == st then known = true break end
    end
    if not known then
      parts[#parts + 1] = string.format("%d %s", n, status_name(st))
    end
  end

  return {
    text = table.concat(parts, " · "),
    color = STATUS_COLOR[top] or colors.muted,
    motion = top == "working" and "breathe" or "none",
  }
end

-- pane_id of the agent that most needs attention, used as the click target.
local function pick_target(agents)
  local best, best_rank = nil, nil
  for _, a in ipairs(agents) do
    if type(a) == "table" and type(a.pane_id) == "string" then
      local rank = #ORDER + 1
      for i, s in ipairs(ORDER) do
        if a.agent_status == s then rank = i break end
      end
      if not best_rank or rank < best_rank then
        best, best_rank = a.pane_id, rank
      end
    end
  end
  return best
end

local item = sbar.add("item", "herdr", {
  position = "right",
  icon = {
    string = utf8.char(0xf06a9), -- nf-md-robot
    drawing = true,
    color = colors.muted,
    font = { family = "Hack Nerd Font", style = "Regular", size = settings.icon_size },
    padding_right = settings.icon_gap,
  },
  label = {
    string = "…",
    color = colors.muted,
    max_chars = MAX_LABEL,
    font = { family = settings.font_mono, style = "Medium", size = settings.font_size },
  },
  padding_left = settings.item_gap,
  padding_right = settings.item_gap,
  update_freq = 1,
})

local state = { text = "…", color = colors.muted, motion = "none" }
local pulse_hi = false
local tick = 0
local in_flight = false
local in_flight_ticks = 0
local click_target = nil
local hovering = false

local function label_color()
  return (hovering and click_target) and colors.text or colors.muted
end

-- Glide the glyph to a state's base colour, unless we are already breathing
-- (then leave the pulse alone so the 5s poll does not hiccup it).
local function apply(s)
  local was_breathing = state.motion == "breathe"
  state = s
  item:set({ label = { string = s.text, color = label_color() } })
  if s.motion ~= "breathe" or not was_breathing then
    sbar.animate("sin", GLIDE_FRAMES, function()
      item:set({ icon = { color = s.color } })
    end)
  end
end

local FALLBACK = { text = "herdr off", color = colors.err, motion = "none" }

-- Merged render: T3 runs become synthetic entries (no pane_id, so
-- pick_target still prefers a herdr pane). Herdr-off + T3-idle keeps the
-- previous "herdr off" fallback.
local herdr_agents = {}
local herdr_ok = false
local t3_entries = {}
local t3_ok = false
local t3_in_flight = false
local t3_in_flight_ticks = 0

local function render()
  local combined = {}
  for _, a in ipairs(herdr_agents) do combined[#combined + 1] = a end
  for _, e in ipairs(t3_entries) do combined[#combined + 1] = e end
  -- Red "herdr off" only when both sources are unreachable. T3 readable but
  -- idle falls through to summarize, which yields a dim "no agents".
  if not herdr_ok and not t3_ok then
    click_target = nil
    apply(FALLBACK)
    return
  end
  click_target = pick_target(combined)
  apply(summarize(combined))
end

-- One line per active run: thread_id|status|has_pending, plus a trailing
-- `t3_ok` sentinel proving the DB was readable (empty output alone cannot
-- distinguish "T3 idle" from "sqlite missing"). Anything malformed is
-- skipped; an empty result means T3 is idle.
local function parse_t3(res)
  local entries = {}
  if type(res) ~= "string" then return entries, false end
  local reachable = false
  for line in res:gmatch("[^\r\n]+") do
    if line:match("^t3_ok%s*$") then reachable = true end
    local st, pend = line:match("^[^|]+|([^|]+)|([^|]+)%s*$")
    if type(st) == "string" then
      st = st:gsub("%s+", ""):sub(1, 12)
      if st ~= "" then
        local blocked = st == "waiting" or pend == "1"
        if blocked or T3_WORKING[st] then
          entries[#entries + 1] = { agent_status = blocked and "blocked" or "working" }
        end
      end
    end
  end
  return entries, reachable
end

local function poll_herdr()
  if in_flight then return end
  in_flight = true
  sbar.exec(HERDR .. " agent list 2>/dev/null", function(res)
    in_flight, in_flight_ticks = false, 0
    -- External data is a boundary: parse it defensively so a shape change
    -- surfaces an error state instead of killing the event thread.
    local ok, agents = pcall(function()
      local a = type(res) == "table" and type(res.result) == "table"
        and res.result.agents or nil
      if type(a) ~= "table" then return nil end
      return a
    end)
    if ok and agents then
      herdr_ok, herdr_agents = true, agents
    else
      herdr_ok, herdr_agents = false, {}
    end
    render()
  end)
end

local function poll_t3()
  if t3_in_flight then return end
  t3_in_flight = true
  sbar.exec("sqlite3 -readonly -separator '|' \"" .. T3_DB .. "\" \"" .. T3_QUERY .. "; SELECT 't3_ok'\" 2>/dev/null", function(res)
    t3_in_flight, t3_in_flight_ticks = false, 0
    local ok, entries, reachable = pcall(parse_t3, res)
    if ok then
      t3_entries = entries or {}
      t3_ok = reachable and true or false
    else
      t3_entries, t3_ok = {}, false
    end
    render()
  end)
end

local function on_tick()
  tick = tick + 1
  -- A callback that never returned (hung herdr) must not freeze polling
  -- forever; after POLL_STALE_TICKS, allow a fresh attempt.
  if in_flight then
    in_flight_ticks = in_flight_ticks + 1
    if in_flight_ticks > POLL_STALE_TICKS then in_flight, in_flight_ticks = false, 0 end
  else
    in_flight_ticks = 0
  end
  if t3_in_flight then
    t3_in_flight_ticks = t3_in_flight_ticks + 1
    if t3_in_flight_ticks > POLL_STALE_TICKS then t3_in_flight, t3_in_flight_ticks = false, 0 end
  else
    t3_in_flight_ticks = 0
  end
  if tick % POLL_TICKS == 1 then poll_herdr() poll_t3() end
  if state.motion == "breathe" and not reduce_motion then
    pulse_hi = not pulse_hi
    local c = pulse_hi and colors.accent_hi or colors.accent_dim
    sbar.animate("sin", BREATH_FRAMES, function()
      item:set({ icon = { color = c } })
    end)
  end
end

item:subscribe("routine", on_tick)
item:subscribe("system_woke", function()
  poll_herdr()
  poll_t3()
end)

-- Hover affordance only when there is something to focus, so the item does
-- not advertise an action it cannot perform.
item:subscribe("mouse.entered", function()
  if not click_target and #t3_entries == 0 then return end
  hovering = true
  item:set({ label = { color = colors.text } })
end)
item:subscribe("mouse.exited", function()
  hovering = false
  item:set({ label = { color = label_color() } })
end)
item:subscribe("mouse.clicked", function()
  if click_target then
    sbar.exec(HERDR .. " agent focus " .. click_target .. " 2>/dev/null")
  elseif #t3_entries > 0 then
    -- T3 has no per-thread focus CLI; best we can do is open the app.
    sbar.exec("open -a 'T3 Code (Nightly)' 2>/dev/null || open -a 'T3 Code' 2>/dev/null")
  end
end)

poll_herdr()
poll_t3()

return { poll = poll_herdr, poll_t3 = poll_t3, on_tick = on_tick, summarize = summarize, pick_target = pick_target }
