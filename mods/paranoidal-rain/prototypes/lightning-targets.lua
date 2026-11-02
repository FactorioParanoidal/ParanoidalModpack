-- Lightning target priorities (data-final-fixes stage), from Dynamic Rain lightning-priorities.lua.
-- Returns { ids = {[name] = bonus}, types = {[type] = bonus}, search_types = {...}, tops = {[name] = y} }:
--   ids/types   bonus of an entity = ids[name] + types[type]; the strike goes to the best target near its point
--   search_types  entity types worth looking for (anything with a bonus)
--   tops        y offset (tiles, from the entity position) of the point the bolt hits on tall entities
-- Unlike Dynamic Rain nothing is written into other prototypes (no hit_visualization_box changes).
local function wooden_name(name)
  for word in string.gmatch(name, "[%a%d]+") do
    if word == "wood" or word == "wooden" or word == "timber" or word == "lumber" then return true end
  end
  return false
end

local ids, types, wanted = {}, {}, {}
local function add_id(kind, name, bonus)
  ids[name] = (ids[name] or 0) + bonus
  wanted[kind] = true
end

for type_name, bonus in pairs({
  ["character"] = 20, ["tree"] = 40, ["pipe"] = 20, ["pipe-to-ground"] = 20, ["pump"] = 20,
  ["storage-tank"] = 20, ["radar"] = 320, ["roboport"] = 319, ["elevated-straight-rail"] = 301,
  ["elevated-curved-rail-a"] = 301, ["elevated-curved-rail-b"] = 301, ["rail-support"] = 301,
  ["unit-spawner"] = 20, ["unit"] = 15, ["construction-robot"] = 10, ["logistic-robot"] = 10,
  ["ammo-turret"] = 15, ["artillery-turret"] = 30, -- their ammunition may cook off (paranoidal-flammable-fluids)
}) do
  types[type_name] = bonus
  wanted[type_name] = true
end

local VANILLA = {
  { "electric-pole", "big-electric-pole", 300 },
  { "electric-pole", "substation", 280 },
  { "electric-pole", "medium-electric-pole", 260 },
  { "electric-pole", "small-electric-pole", 240 },
  { "container", "wooden-chest", 10 },
  { "container", "crash-site-spaceship", 100 },
  { "rocket-silo", "rocket-silo", 110 },
  { "turret", "small-worm-turret", 20 },
  { "turret", "medium-worm-turret", 20 },
  { "turret", "big-worm-turret", 20 },
  { "turret", "behemoth-worm-turret", 20 },
}
local vanilla = {}
for _, entry in ipairs(VANILLA) do
  if data.raw[entry[1]] and data.raw[entry[1]][entry[2]] then
    add_id(entry[1], entry[2], entry[3])
    vanilla[entry[2]] = true
  end
end

local function flagged(entity, flag)
  for _, f in pairs(entity.flags or {}) do
    if f == flag then return true end
  end
  return false
end

local wooden = {}
for kind, entities in pairs(data.raw) do
  if kind ~= "tree" then
    for name, entity in pairs(entities) do
      if type(entity) == "table" and not vanilla[name] and type(entity.max_health) == "number" and entity.max_health > 0
          and entity.selection_box and wooden_name(name) and not flagged(entity, "not-flammable") then
        wooden[name] = true
        add_id(kind, name, 10)
      end
    end
  end
end

local BUILDING_TYPES = {
  ["accumulator"] = true, ["agricultural-tower"] = true, ["ammo-turret"] = true, ["arithmetic-combinator"] = true,
  ["artillery-turret"] = true, ["assembling-machine"] = true, ["beacon"] = true, ["boiler"] = true,
  ["burner-generator"] = true, ["constant-combinator"] = true, ["container"] = true, ["decider-combinator"] = true,
  ["electric-energy-interface"] = true, ["electric-pole"] = true, ["electric-turret"] = true, ["fluid-turret"] = true,
  ["furnace"] = true, ["generator"] = true, ["heat-interface"] = true, ["heat-pipe"] = true, ["inserter"] = true,
  ["lab"] = true, ["lamp"] = true, ["logistic-container"] = true, ["mining-drill"] = true, ["offshore-pump"] = true,
  ["pipe"] = true, ["pipe-to-ground"] = true, ["power-switch"] = true, ["pump"] = true, ["reactor"] = true,
  ["rocket-silo"] = true, ["selector-combinator"] = true, ["solar-panel"] = true, ["storage-tank"] = true,
  ["train-stop"] = true, ["turret"] = true,
}

local function coordinate(point, axis)
  return point[axis] or point[axis == "x" and 1 or 2]
end

local function sprite_info(sprite)
  -- returns height (tiles) and top (y offset) of the tallest non-shadow layer
  if type(sprite) ~= "table" or sprite.draw_as_shadow then return 0, nil end
  if sprite.layers or sprite[1] then
    local height, top = 0, nil
    for _, layer in ipairs(sprite.layers or sprite) do
      local h, t = sprite_info(layer)
      if h > height then height = h end
      if t and (not top or t < top) then top = t end
    end
    return height, top
  end
  if sprite.animation then return sprite_info(sprite.animation) end
  if sprite.north or sprite.east or sprite.south or sprite.west then
    local height, top = 0, nil
    for _, direction in ipairs({ "north", "east", "south", "west" }) do
      local h, t = sprite_info(sprite[direction])
      if h > height then height = h end
      if t and (not top or t < top) then top = t end
    end
    return height, top
  end
  local size = sprite.size
  local pixels = type(size) == "table" and size[2] or size or sprite.height
  if type(pixels) ~= "number" then return 0, nil end
  local scale = sprite.scale or 1
  local shift = sprite.shift or { 0, 0 }
  local h = pixels * scale / 32
  return h, coordinate(shift, "y") - pixels * scale / 64
end

local tops = {}
for kind, entities in pairs(data.raw) do
  if BUILDING_TYPES[kind] then
    for name, entity in pairs(entities) do
      local box = entity.selection_box
      if type(entity.max_health) == "number" and entity.max_health > 0 and box then
        local top = box.left_top or box[1]
        local bottom = box.right_bottom or box[2]
        local box_top = coordinate(top, "y") - (entity.drawing_box_vertical_extension or 0)
        local height = coordinate(bottom, "y") - box_top
        local picture_height, picture_top = sprite_info(entity.picture or entity.pictures)
        local graphics = entity.graphics_set
        local anim_height, anim_top = sprite_info(graphics and graphics.animation)
        height = math.max(height, picture_height, anim_height)
        local y = math.min(box_top, picture_top or math.huge, anim_top or math.huge)
        if kind == "electric-pole" or height >= 9 then
          tops[name] = y + 0.3
          if not vanilla[name] and not wooden[name] then
            -- capped: a huge sprite must not outweigh poles and radars (Dynamic Rain had no cap)
            local bonus = math.min(300, math.floor(height * 15 + 0.5))
            if kind == "electric-pole" then bonus = bonus + 200 end
            add_id(kind, name, bonus)
          end
        end
      end
    end
  end
end

-- Entity types to search around a strike point: every type with a type bonus or a named bonus.
local search_types = {}
for kind in pairs(wanted) do search_types[#search_types + 1] = kind end
table.sort(search_types)

return { ids = ids, types = types, search_types = search_types, tops = tops }
