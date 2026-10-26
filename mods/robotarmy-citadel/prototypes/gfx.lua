-- Graphics helpers: the citadel reuses the sprites of the base game (and of the mods that reskin
-- them), recoloured and rescaled. Every helper works on a deep copy.
local util = require("util")

local G = {}

G.copy = util.table.deepcopy

local function is_layer(t)
  return t.filename ~= nil or t.filenames ~= nil or t.stripes ~= nil
end

--- Calls fn(layer) once for every sprite layer inside a Sprite / Animation / RotatedSprite table
--- (deepcopy keeps shared subtables shared, so a layer may be reachable twice).
function G.each_layer(t, fn, seen)
  if type(t) ~= "table" then return end
  seen = seen or {}
  if seen[t] then return end
  seen[t] = true
  if is_layer(t) then
    fn(t)
    return
  end
  if t.layers then
    for _, l in pairs(t.layers) do G.each_layer(l, fn, seen) end
  end
  if t.sheets then
    for _, l in pairs(t.sheets) do G.each_layer(l, fn, seen) end
  end
  if t.sheet then G.each_layer(t.sheet, fn, seen) end
end

local function mul(a, b)
  a = a or {1, 1, 1, 1}
  local ar, ag, ab, aa = a.r or a[1] or 1, a.g or a[2] or 1, a.b or a[3] or 1, a.a or a[4] or 1
  return {r = ar * (b.r or 1), g = ag * (b.g or 1), b = ab * (b.b or 1), a = aa * (b.a or 1)}
end

--- Recolours the body layers (not shadows, glows and lights).
function G.tint(t, color)
  G.each_layer(t, function(l)
    if not (l.draw_as_shadow or l.draw_as_glow or l.draw_as_light) then
      l.tint = mul(l.tint, color)
    end
  end)
  return t
end

local SKIP = {sound = true, sounds = true, working_sound = true, open_sound = true, close_sound = true,
  rotating_sound = true, preparing_sound = true, folding_sound = true, prepared_sound = true,
  attacking_sound = true, prepared_alternative_sound = true}

--- Recolours every sprite layer found anywhere inside a graphics table, each layer once (sounds are
--- skipped). Pass the same `seen` table for graphics that may share layers (a unit's run and attack
--- animations are often one table).
function G.tint_all(t, color, seen)
  if type(t) ~= "table" then return t end
  seen = seen or {}
  if seen[t] then return t end
  seen[t] = true
  if is_layer(t) then
    if not (t.draw_as_shadow or t.draw_as_glow or t.draw_as_light) then t.tint = mul(t.tint, color) end
    return t
  end
  for k, v in pairs(t) do
    if type(v) == "table" and not SKIP[k] then G.tint_all(v, color, seen) end
  end
  return t
end

--- Scales every layer (size and shift).
function G.scale(t, k)
  G.each_layer(t, function(l)
    l.scale = (l.scale or 1) * k
    if l.shift then
      local x, y = l.shift.x or l.shift[1] or 0, l.shift.y or l.shift[2] or 0
      l.shift = {x * k, y * k}
    end
  end)
  return t
end

--- An animation whose layers all last the same number of frames (static layers get a repeat count).
--- Returns nil if the layers cannot be matched.
function G.animation(anim)
  local a = G.copy(anim)
  local longest = 1
  G.each_layer(a, function(l)
    local n = (l.frame_count or 1) * (l.repeat_count or 1)
    if n > longest then longest = n end
  end)
  local ok, speed = true, nil
  G.each_layer(a, function(l)
    if (l.frame_count or 1) > 1 and not speed then speed = l.animation_speed or 1 end
  end)
  G.each_layer(a, function(l)
    local frames = l.frame_count or 1
    local n = frames * (l.repeat_count or 1)
    if n ~= longest then
      if longest % frames == 0 then l.repeat_count = longest / frames else ok = false end
    end
    if speed then l.animation_speed = speed end -- the layers run in step
  end)
  return ok and a or nil
end

local FRAME_KEYS = {
  "frame_count", "repeat_count", "line_length", "lines_per_file", "animation_speed", "run_mode",
  "frame_sequence", "max_advance", "direction_count", "axially_symmetrical", "back_equals_front",
  "allow_low_quality_rotation", "counterclockwise", "apply_projection", "slice", "slice_x", "slice_y",
  "generate_sdf", "stripes", "filenames",
}

--- The first frame of an Animation or RotatedSprite as a Sprite (layers kept).
function G.first_frame(t)
  local s = G.copy(t)
  G.each_layer(s, function(l)
    if l.filenames then l.filename = l.filenames[1] end
    if l.stripes then
      local stripe = l.stripes[1]
      l.filename = stripe.filename
    end
    for _, k in pairs(FRAME_KEYS) do l[k] = nil end
  end)
  return s
end

--- Collision and selection boxes of a w x h tiles building (slightly smaller than the tiles).
function G.boxes(w, h)
  local x, y = w / 2 - 0.1, h / 2 - 0.1
  return {{-x, -y}, {x, y}}, {{-w / 2, -h / 2}, {w / 2, h / 2}}
end

--- Icon layers of a base entity / item recoloured.
function G.icons(proto, color)
  if not proto then return {{icon = "__base__/graphics/icons/signal/signal-skull.png", icon_size = 64, tint = color}} end
  if proto.icons then
    local icons = G.copy(proto.icons)
    for _, i in pairs(icons) do i.tint = mul(i.tint, color) end
    return icons
  end
  return {{icon = proto.icon, icon_size = proto.icon_size or 64, tint = color}}
end

return G
