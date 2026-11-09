local util = require("util")
local config = require("features.flamethrower-fuels.config")
local source = data.raw["fluid-turret"]["flamethrower-turret"]
if not source then return end
local enabled = settings.startup[config.setting].value

local function find(node, predicate)
  if type(node) ~= "table" then return end
  if predicate(node) then return node end
  for _, value in pairs(node) do
    local result = find(value, predicate)
    if result then return result end
  end
end

local function native_parameters()
  local delivery = find(source.attack_parameters.ammo_type, function(v) return v.type == "stream" and v.stream end)
  local stream = delivery and data.raw.stream[delivery.stream]
  if not stream then return end
  local hit = find(stream.action, function(v) return v.type == "damage" and v.damage.type == "fire" end)
  local floor = find(stream.action, function(v) return v.type == "create-fire" end)
  local burn = find(stream.action, function(v) return v.type == "create-sticker" end)
  local fire = floor and data.raw.fire[floor.entity_name]
  local sticker = burn and data.raw.sticker[burn.sticker]
  if not (hit and fire and sticker) then return end
  return {stream = stream.name, fire = fire.name, sticker = sticker.name, impact_damage = hit.damage.amount,
    ground_dps = fire.damage_per_tick.amount * 60,
    burn_dps = sticker.damage_per_tick.amount * 60 / (sticker.damage_interval or 1),
    ground_initial_ticks = fire.initial_lifetime, ground_max_ticks = fire.maximum_lifetime,
    ground_extend_ticks = fire.lifetime_increase_by, burn_ticks = sticker.duration_in_ticks,
    maximum_damage_multiplier = fire.maximum_damage_multiplier,
    particle_spawn_interval = stream.particle_spawn_interval}
end

local native = native_parameters()
if enabled then assert(native, "Flamethrower fuel balance requires a native fire stream; disable the startup setting to restore the source attack") end
local original = table.deepcopy(source.attack_parameters.fluids)
local profiles, order, whitelist, turrets = {}, {}, {}, {}
if enabled then
  for _, entry in ipairs(config.fuels) do
    local fluid = data.raw.fluid[entry.name]
    local p = fluid and config.calculate(entry.name, util.parse_energy(fluid.fuel_value or "0J"), native)
    if p then
      profiles[entry.name], order[#order + 1] = p, entry.name
      whitelist[#whitelist + 1] = {type = entry.name, damage_modifier = p.damage_modifier}
      local text = {"paranoidal-flame.fluid-profile", string.format("%.3f", p.damage_modifier),
        string.format("%g", p.burn_seconds), string.format("%g", p.ground_initial_seconds),
        string.format("%g", p.ground_max_ticks / 60)}
      fluid.localised_description = fluid.localised_description and {"", fluid.localised_description, "\n", text} or text
    end
  end
else
  whitelist = original
  for _, entry in ipairs(original) do
    local fluid = data.raw.fluid[entry.type]
    if fluid then
      profiles[entry.type] = config.describe(entry.type, util.parse_energy(fluid.fuel_value or "0J"), entry.damage_modifier or 1, native)
      order[#order + 1] = entry.type
    end
  end
end

for name, turret in pairs(data.raw["fluid-turret"]) do
  if name == "flamethrower-turret" or name == "flamethrower-wagon-turret"
    or name:match("^hero%-turret%-%d+%-for%-flamethrower%-turret$")
    or name:match("^hero%-turret%-%d+%-for%-flamethrower%-wagon%-turret$") then
    turrets[name] = true
    if enabled then
      turret.attack_parameters.fluids = table.deepcopy(whitelist)
      turret.localised_description = {"", turret.localised_description or "", "\n", {"paranoidal-flame.turret-description"}}
    end
  end
end
local wagon = data.raw["mod-data"]["flamethrower-wagon-reforged"]
if enabled and wagon then
  wagon.data.fuels = {}
  for name in pairs(profiles) do wagon.data.fuels[name] = true end
end
data:extend{{type = "mod-data", name = "paranoidal-flamethrower-fuels",
  data = {version = 2, mode = "native", enabled = enabled, reference_joules = config.reference_joules,
    profiles = profiles, order = order, turrets = turrets, native = native, original_fluids = original}}}
