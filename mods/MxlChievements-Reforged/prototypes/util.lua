-- Data-stage helpers: prototype lookup, availability, icons and texts of achievements.
-- Every lookup tolerates missing prototypes: a missing target only skips the achievement.

local util = {}

util.GRAPHICS = "__MxlChievements-Reforged__/graphics/"
util.FRAMES = {"base.png", "base-silver.png", "base-gold.png"}

-- Product, entity or technology icon inside a tier frame is shrunk to this share of the frame;
-- technology icons are full squares and get a smaller share to stay inside the round frame.
local INNER_SCALE = 0.7
local INNER_SCALE_TECHNOLOGY = 0.5
-- Icons are authored for the expected size of their prototype family; achievements expect 128.
local EXPECTED_SIZE = {item = 64, fluid = 64, entity = 64, quality = 64, technology = 256}

local NUMBER_UNITS = {{1e12, "trillion"}, {1e9, "billion"}, {1e6, "million"}, {1e3, "thousand"}}

local FALLBACK_ITEM_TYPES = {
  "item", "ammo", "armor", "blueprint", "blueprint-book", "capsule", "copy-paste-tool",
  "deconstruction-item", "gun", "item-with-entity-data", "item-with-inventory", "item-with-label",
  "item-with-tags", "module", "rail-planner", "repair-tool", "selection-tool",
  "space-platform-starter-pack", "spidertron-remote", "tool", "upgrade-item",
}

local function type_list(family, fallback)
  local result = {}
  local types = defines and defines.prototypes and defines.prototypes[family]
  if types then
    for name in pairs(types) do table.insert(result, name) end
  else
    result = fallback
  end
  table.sort(result)
  return result
end

local index -- built lazily: everything is final in data-final-fixes

local function build_index()
  index = {item = {}, entity = {}, achievement = {}, producible = {}}
  for _, type_name in ipairs(type_list("item", FALLBACK_ITEM_TYPES)) do
    for name, prototype in pairs(data.raw[type_name] or {}) do
      index.item[name] = index.item[name] or prototype
    end
  end
  -- Without defines.prototypes every table with a collision box counts as an entity type.
  local entity_types = type_list("entity", {})
  if #entity_types == 0 then
    for type_name, prototypes in pairs(data.raw) do
      local _, sample = next(prototypes)
      if type(sample) == "table" and sample.collision_box then table.insert(entity_types, type_name) end
    end
  end
  for _, type_name in ipairs(entity_types) do
    for name, prototype in pairs(data.raw[type_name] or {}) do
      index.entity[name] = index.entity[name] or prototype
    end
  end
  for type_name in pairs(data.raw) do
    if type_name == "achievement" or type_name:find("%-achievement$") then
      for name in pairs(data.raw[type_name]) do index.achievement[name] = true end
    end
  end

  -- Items and fluids that something in the game can actually produce.
  local producible = index.producible
  local function add_results(results)
    for _, result in pairs(results or {}) do
      if type(result) == "table" then
        local name = result.name or result[1]
        if name then producible[name] = true end
      end
    end
  end
  for _, recipe in pairs(data.raw.recipe or {}) do
    add_results(recipe.results)
    if recipe.result then producible[recipe.result] = true end
  end
  for _, prototype in pairs(index.entity) do
    local minable = prototype.minable
    if minable then
      if minable.result then producible[minable.result] = true end
      add_results(minable.results)
    end
    if prototype.type == "boiler" then
      local box = prototype.output_fluid_box
      if box and box.filter then producible[box.filter] = true end
    end
  end
  for _, prototype in pairs(index.item) do
    if prototype.burnt_result then producible[prototype.burnt_result] = true end
    if prototype.spoil_result then producible[prototype.spoil_result] = true end
    add_results(prototype.rocket_launch_products)
  end
  for _, tile in pairs(data.raw.tile or {}) do
    if tile.fluid then producible[tile.fluid] = true end
  end

  -- Entities that a player can place: some item places them.
  index.placeable = {}
  for _, prototype in pairs(index.item) do
    if type(prototype.place_result) == "string" and not prototype.hidden then
      index.placeable[prototype.place_result] = true
    end
  end
  for name, prototype in pairs(index.entity) do
    local by = prototype.placeable_by
    if by then
      if by.item then by = {by} end
      for _, option in ipairs(by) do
        if util.available(index.item[option.item]) then index.placeable[name] = true end
      end
    end
  end
end

local function lookup(family, name)
  if not index then build_index() end
  return index[family][name]
end

function util.item(name) return type(name) == "string" and lookup("item", name) or nil end
function util.entity(name) return type(name) == "string" and lookup("entity", name) or nil end
function util.fluid(name) return type(name) == "string" and data.raw.fluid and data.raw.fluid[name] or nil end
function util.technology(name)
  return type(name) == "string" and data.raw.technology and data.raw.technology[name] or nil
end
function util.quality(name) return type(name) == "string" and data.raw.quality and data.raw.quality[name] or nil end
function util.achievement_exists(name) return lookup("achievement", name) == true end
function util.mark_achievement(name)
  if not index then build_index() end
  index.achievement[name] = true
end

function util.available(prototype)
  return prototype ~= nil and not prototype.hidden
end

function util.producible(name)
  return lookup("producible", name) == true
end

function util.placeable(name)
  return lookup("placeable", name) == true
end

-- Entity names matching any Lua pattern of `spec.patterns` (or listed in `spec.names`), restricted
-- to `spec.types` when given. Hidden entities are skipped. Returns a sorted array.
function util.entities(spec)
  if not index then build_index() end
  local types
  if spec.types then
    types = {}
    for _, type_name in ipairs(spec.types) do types[type_name] = true end
  end
  local found = {}
  local function accept(name, prototype)
    -- HeroTurretRedux ranks with built-in ammo are hidden only for the research tooltips
    if prototype and (not prototype.hidden or name:find("^hero%-turret%-%d+%-for%-")) and (not types or types[prototype.type]) then
      if not (spec.exclude and name:find(spec.exclude)) then found[name] = true end
    end
  end
  for _, name in ipairs(spec.names or {}) do accept(name, index.entity[name]) end
  if spec.patterns then
    for name, prototype in pairs(index.entity) do
      for _, pattern in ipairs(spec.patterns) do
        if name:find(pattern) then accept(name, prototype) break end
      end
    end
  end
  local result = {}
  for name in pairs(found) do table.insert(result, name) end
  table.sort(result)
  return result
end

-- First available name of a candidate list (a single name is a list of one).
function util.first(candidates, find, need_producible)
  if type(candidates) ~= "table" then candidates = {candidates} end
  for _, name in ipairs(candidates) do
    local prototype = find(name)
    if util.available(prototype) and (not need_producible or util.producible(name)) then
      return prototype
    end
  end
end

function util.letter(index_number)
  return string.char(96 + index_number)
end

-- 2500000 -> {"mxlr-number.million", "2.5"}
function util.number_text(amount)
  for _, unit in ipairs(NUMBER_UNITS) do
    if amount >= unit[1] then
      local mantissa = string.format("%.2f", amount / unit[1]):gsub("%.?0+$", "")
      return {"mxlr-number." .. unit[2], mantissa}
    end
  end
  return string.format("%d", amount)
end

-- Localised name of an item, fluid, entity, technology or quality prototype.
function util.name_of(prototype, family)
  if prototype.localised_name then return table.deepcopy(prototype.localised_name) end
  local name = prototype.name
  if family == "fluid" then return {"fluid-name." .. name} end
  if family == "quality" then return {"quality-name." .. name} end
  if family == "technology" then
    return {"?", {"technology-name." .. name}, {"technology-name." .. name:gsub("%-%d+$", "")}, name}
  end
  if family == "entity" then
    local result = {"?", {"entity-name." .. name}}
    local item = util.item(name)
    if item then table.insert(result, {"item-name." .. name}) end
    table.insert(result, name)
    return result
  end
  local result = {"?", {"item-name." .. name}}
  if type(prototype.place_result) == "string" then
    table.insert(result, {"entity-name." .. prototype.place_result})
  end
  if type(prototype.place_as_equipment_result) == "string" then
    table.insert(result, {"equipment-name." .. prototype.place_as_equipment_result})
  end
  table.insert(result, name)
  return result
end

-- Rich-text icon followed by the localised name.
function util.text_of(prototype, family, quality)
  local tag = family == "entity" and "entity" or family == "fluid" and "fluid"
    or family == "technology" and "technology" or family == "quality" and "quality" or "item"
  local icon = "[" .. tag .. "=" .. prototype.name .. (quality and ",quality=" .. quality or "") .. "] "
  local name = util.name_of(prototype, family)
  if quality then
    name = {"mxlr.with-quality", name, util.name_of(data.raw.quality[quality], "quality")}
  end
  return {"", icon, name}
end

-- Icon layers of a prototype, converted to the achievement icon scale and shrunk by `inner`.
function util.icon_layers(prototype, family, inner)
  inner = inner or (family == "technology" and INNER_SCALE_TECHNOLOGY or INNER_SCALE)
  local factor = 128 / (EXPECTED_SIZE[family] or 64)
  local sources = prototype.icons
  if not sources then
    if not prototype.icon then return nil end
    sources = {{icon = prototype.icon, icon_size = prototype.icon_size}}
  end
  local layers = {}
  for _, source in ipairs(sources) do
    if type(source.icon) ~= "string" then return nil end
    local layer = table.deepcopy(source)
    layer.icon_size = layer.icon_size or prototype.icon_size or 64
    if layer.scale then
      layer.scale = layer.scale * factor * inner
    else
      layer.scale = 64 / layer.icon_size * inner
    end
    if layer.shift then
      local x, y = layer.shift[1] or layer.shift.x or 0, layer.shift[2] or layer.shift.y or 0
      layer.shift = {x * factor * inner, y * factor * inner}
    end
    layer.draw_background = false
    table.insert(layers, layer)
  end
  if #layers == 0 then return nil end
  return layers
end

-- Tier frame (1 bronze, 2 silver, 3+ gold) with the icon of a prototype or picture inside.
function util.framed(tier, inner_layers)
  local frame = util.FRAMES[math.max(1, math.min(tier, #util.FRAMES))]
  local icons = {{icon = util.GRAPHICS .. frame, icon_size = 128, draw_background = false}}
  for _, layer in ipairs(inner_layers or {}) do table.insert(icons, layer) end
  return icons
end

function util.quality_badge(quality, shift)
  local prototype = data.raw.quality[quality]
  local source = prototype.icons and prototype.icons[1] or prototype
  if type(source.icon) ~= "string" then return nil end
  local size = source.icon_size or prototype.icon_size or 64
  return {icon = source.icon, icon_size = size, scale = 12 / size, shift = shift or {0, 26}}
end

return util
