-- Helpers and setting values shared by the data stage files.

local shared = {}

local startup = settings.startup

shared.MOD = "__paranoidal-tank-platoon__"
shared.icons = shared.MOD .. "/graphics/icons/"
shared.technology_icons = shared.MOD .. "/graphics/technology/"

-- Tier 0 is always present; MK2 requires MK1.
local mk1 = startup["tankplatoon-tank-t1-enable"].value
shared.tiers = {0}
if mk1 then
  table.insert(shared.tiers, 1)
  if startup["tankplatoon-tank-t2-enable"].value then
    table.insert(shared.tiers, 2)
  end
end

function shared.tier_enabled(tier)
  for _, enabled in pairs(shared.tiers) do
    if enabled == tier then return true end
  end
  return false
end

function shared.tank_name(class, tier)
  return tier == 0 and ("Schall-tank-" .. class) or ("Schall-tank-" .. class .. "-mk" .. tier)
end

function shared.setting(name)
  return startup["tankplatoon-" .. name].value
end

-- Grid size settings have the form "WxH".
function shared.grid_size(tier)
  local value = shared.setting("tank-t" .. tier .. "-grid")
  local width, height = value:match("^(%d+)x(%d+)$")
  return tonumber(width), tonumber(height)
end

shared.tier_icon = {
  [1] = {icon = shared.icons .. "mk1.png", icon_size = 128},
  [2] = {icon = shared.icons .. "mk2.png", icon_size = 128},
}
shared.caliber_icon = {
  H1 = {icon = shared.icons .. "H1.png", icon_size = 128},
  H2 = {icon = shared.icons .. "H2.png", icon_size = 128},
}
shared.tank_equipment_icon = {icon = shared.icons .. "tank-equipment.png", icon_size = 128}

-- Multiplies volume of a Sound definition in place (single file or variations).
function shared.scale_sound(sound, factor)
  if type(sound) ~= "table" then return end
  if sound.volume then sound.volume = sound.volume * factor end
  local variations = sound.variations or (sound.filename == nil and sound) or nil
  if variations then
    for _, variation in pairs(variations) do
      if type(variation) == "table" and variation.volume then
        variation.volume = variation.volume * factor
      end
    end
  end
end

-- Vectors may be written as {x, y} or {x = x, y = y}.
function shared.scale_vector(vector, factor)
  if type(vector) ~= "table" then return vector end
  if vector.x or vector.y then
    return {x = (vector.x or 0) * factor, y = (vector.y or 0) * factor}
  end
  return {(vector[1] or 0) * factor, (vector[2] or 0) * factor}
end

local function is_sprite_layer(layer)
  return layer.filename ~= nil or layer.filenames ~= nil or layer.stripes ~= nil
end

-- Rescales sprites/animations in place: scale and shift of every layer.
function shared.rescale_sprite(definition, factor)
  if type(definition) ~= "table" then return end
  if is_sprite_layer(definition) then
    definition.scale = (definition.scale or 1) * factor
    definition.shift = shared.scale_vector(definition.shift, factor)
    return
  end
  for _, child in pairs(definition) do
    shared.rescale_sprite(child, factor)
  end
end

-- Tints colour layers. Shadows, lights and runtime-tinted masks keep their look;
-- glowing layers are tinted only when include_glow is set (explosions).
function shared.tint_sprite(definition, tint, include_glow)
  if type(definition) ~= "table" then return end
  if is_sprite_layer(definition) then
    local skip = definition.draw_as_shadow or definition.draw_as_light or definition.apply_runtime_tint
      or (definition.draw_as_glow and not include_glow)
    if not skip then definition.tint = tint end
    return
  end
  for _, child in pairs(definition) do
    shared.tint_sprite(child, tint, include_glow)
  end
end

function shared.unlock(technology_name, recipe_name)
  local technology = data.raw.technology[technology_name]
  if not technology then
    log("[paranoidal-tank-platoon] technology " .. technology_name .. " not found; " .. recipe_name .. " has no unlock")
    return false
  end
  technology.effects = technology.effects or {}
  for _, effect in pairs(technology.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == recipe_name then return true end
  end
  table.insert(technology.effects, {type = "unlock-recipe", recipe = recipe_name})
  return true
end

return shared
