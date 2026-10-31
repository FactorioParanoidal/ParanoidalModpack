-- Lookups derived from prototypes. They are rebuilt in every Lua state from `prototypes` and the
-- remote-interface lists in `storage`, so they are deterministic and never stored.

local protos = {}

local MAX_ORDER = 4294967295
protos.MAX_ORDER = MAX_ORDER
protos.DEFAULT_COLOR = { r = 0.4, g = 0.4, b = 0.4 }

local pipe_types = { pipe = true, ["pipe-to-ground"] = true, ["infinity-pipe"] = true }
-- Fluid storage that pipes never connect to.
local skip_types = { ["fluid-wagon"] = true }

--- Entity names that own fluidboxes or a fluid energy source.
--- @type table<string, true>
local fluid_names = {}
--- The same names as an array, for find_entities_filtered.
--- @type string[]
local fluid_name_list = {}
--- Prototype types of those entities, for event filters.
--- @type string[]
local fluid_type_list = {}

do
  local seen = {}
  for name, proto in pairs(prototypes.entity) do
    local t = proto.type
    if not skip_types[t] and (#proto.fluidbox_prototypes > 0 or proto.fluid_energy_source_prototype) then
      fluid_names[name] = true
      fluid_name_list[#fluid_name_list + 1] = name
      if not seen[t] then
        seen[t] = true
        fluid_type_list[#fluid_type_list + 1] = t
      end
    end
  end
end

protos.fluid_names = fluid_names
protos.fluid_name_list = fluid_name_list
protos.fluid_type_list = fluid_type_list

-- Built-in compatibility: Fluid Must Flow ducts are drawn like pipes.
local builtin_pipes = {}
if script.active_mods["FluidMustFlow"] then
  for _, name in pairs({ "duct", "duct-cross", "duct-curve", "duct-long", "duct-small", "duct-t-junction" }) do
    builtin_pipes[name] = true
  end
end

--- @class PvEntityInfo
--- @field pipe boolean Drawn as a pipe sprite (connection mask) instead of a box with arrows.
--- @field black boolean Blacklisted through the remote interface: never drawn or crossed.
--- @field w integer Tile width of the prototype.
--- @field h integer Tile height of the prototype.

--- @type table<string, PvEntityInfo|false>
local info_cache = {}

--- @param name string
--- @return PvEntityInfo|false
local function compute(name)
  if not fluid_names[name] then
    return false
  end
  local proto = prototypes.entity[name]
  local t = proto.type
  local pipelist = storage.pipelist
  local complexlist = storage.complexlist
  local blacklist = storage.blacklist
  local pipe = pipe_types[t] or builtin_pipes[name] or (pipelist and pipelist[t] and pipelist[t][name]) or false
  if complexlist and complexlist[t] and complexlist[t][name] then
    pipe = false
  end
  return {
    pipe = pipe and true or false,
    black = (blacklist and blacklist[name]) and true or false,
    w = proto.tile_width,
    h = proto.tile_height,
  }
end

--- Info about a fluid entity name, or false for names without fluid.
--- @param name string
--- @return PvEntityInfo|false
function protos.info(name)
  local info = info_cache[name]
  if info == nil then
    info = compute(name)
    info_cache[name] = info
  end
  return info
end

--- Drops the cache after the remote-interface lists change.
function protos.invalidate()
  info_cache = {}
end

-- Colours ----------------------------------------------------------------------------------------

--- @param c Color
local function rgb_to_hsv(c)
  local r, g, b = c.r or 0, c.g or 0, c.b or 0
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local d = max - min
  local h = 0
  local s = max == 0 and 0 or d / max
  if max ~= min then
    if max == r then
      h = (g - b) / d
      if g < b then
        h = h + 6
      end
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, max
end

local function hsv_to_rgb(h, s, v, a)
  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
  i = i % 6
  local r, g, b
  if i == 0 then
    r, g, b = v, t, p
  elseif i == 1 then
    r, g, b = q, v, p
  elseif i == 2 then
    r, g, b = p, v, t
  elseif i == 3 then
    r, g, b = p, q, v
  elseif i == 4 then
    r, g, b = t, p, v
  else
    r, g, b = v, p, q
  end
  return { r = r, g = g, b = b, a = a }
end

--- Fluid colours at full brightness and the fluid order used to pick an entity's main colour.
--- @type table<string, Color>
local fluid_color = {}
--- @type table<string, integer>
local fluid_order = {}
do
  local i = 0
  for name, fluid in pairs(prototypes.fluid) do
    i = i + 1
    fluid_order[name] = i
    local base = fluid.base_color
    local h, s = rgb_to_hsv(base)
    fluid_color[name] = hsv_to_rgb(h, s, 1, base.a or 1)
  end
end
protos.fluid_color = fluid_color
protos.fluid_order = fluid_order

--- 72 distinct system colours: 12 hues at 6 saturations. Used cyclically.
--- @type Color[]
local palette = {}
for k = 0, 5 do
  local s = 0.8 - k * 0.1
  for h = 0, 330, 30 do
    palette[#palette + 1] = hsv_to_rgb(h / 360, s, 1, 1)
  end
end
protos.palette = palette

return protos
