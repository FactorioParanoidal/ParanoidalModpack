require "util"
local fire = util.table.deepcopy(data.raw.fire["fire-flame"])
fire.initial_lifetime = 3000
fire.name="oil-fire-flame"
fire.damage_per_tick = {amount = 1, type = "fire"}
-- Paranoidal: scorch marks stay for 3 minutes, burning oil smokes up the chunk.
fire.burnt_patch_lifetime = 3 * 60 * 60
fire.emissions_per_second = {pollution = 0.2}
---@diagnostic disable-next-line: assign-type-mismatch
data:extend({fire})

--note: 
--base pipes have 100 hp and 70% fire resist
--undergrounds have 150 hp and 80% fire resist
--as such we need 150 / (1 - 0.8) = 750 fire amage do guarantee destruction



local fuel_values = {
  ["crude-oil"] = "0.4MJ",
  ["light-oil"] = "0.9MJ",
  ["heavy-oil"] = "0.45MJ",
  ["petroleum-gas"] = "0.45MJ",
  ["diesel-fuel"] = "1.1MJ",
  }
local emissions = {
  ["crude-oil"] = 1.4,
  ["light-oil"] = 1.2,
  ["heavy-oil"] = 1.3,
  ["petroleum-gas"] = 1,
  ["diesel-fuel"] = 0.8,
  ["molten-tiberium"] = 2.1,
  ["tiberium-waste"] = 1.2,
  ["tiberium-sludge"] = 1.7,
  ["tiberium-slurry"] = 1.8,
  ["liquid-tiberium"] = 4,
  ["tiberium-slurry-blue"] = 3,
}

for k, fluid in pairs (data.raw.fluid) do
  if not fluid.fuel_value or fluid.fuel_value == "0J" then --All fluids have 0J fuel value by default
    fluid.fuel_value = fuel_values[fluid.name]
end
if not    
      fluid.emissions_multiplier and fluid.emissions_multiplier ~= 1.0 then --All fluids have 1.0 multiplier by default
    fluid.emissions_multiplier = emissions[fluid.name]
  end
end

---------------------------------------------------------------------------------------------------
-- Paranoidal additions (see PARANOIDAL-CHANGES.md)

-- Long fire thrown around by a tank catastrophe.
local long_fire = util.table.deepcopy(fire)
long_fire.name = "flo-long-fire"
long_fire.initial_lifetime = 2 * 60 * 60
long_fire.maximum_lifetime = 3 * 60 * 60
long_fire.emissions_per_second = {pollution = 0.5}

-- Flames licking an overheating tank: almost harmless, they do not spread, do not stack damage
-- and do not kill the tank before its timer (about 8 flames at once: ~2.4 HP/s on a 500 HP tank).
local tank_fire = util.table.deepcopy(data.raw.fire["fire-flame"])
tank_fire.name = "flo-tank-fire"
tank_fire.initial_lifetime = 240
tank_fire.maximum_spread_count = 0
tank_fire.spawn_entity = nil
tank_fire.damage_per_tick = {amount = 0.005, type = "fire"}
tank_fire.maximum_damage_multiplier = 1
tank_fire.emissions_per_second = {pollution = 0.3}
tank_fire.localised_name = {"entity-name.oil-fire-flame"}

-- Thick black smoke of a tank about to blow up (black like the Paranoidal locomotive smoke).
local smoke = util.table.deepcopy(data.raw["trivial-smoke"]["train-smoke"])
smoke.name = "flo-black-smoke"
smoke.color = {r = 0, g = 0, b = 0, a = 0.75}
smoke.duration = 600
smoke.fade_in_duration = 30
smoke.fade_away_duration = 300
smoke.spread_duration = 300
smoke.start_scale = 1.5
smoke.end_scale = 6
smoke.affected_by_wind = true
smoke.show_when_smoke_off = true

data:extend({long_fire, tank_fire, smoke})

-- Blast tiers: base explosions plus camera shake, a sound heard from afar and, for the biggest,
-- the visual shock wave of the atomic bomb (its damaging parts are not used).
local function add_effects(proto, effects)
  local trigger = {type = "direct", action_delivery = {type = "instant", target_effects = effects}}
  local created = proto.created_effect
  if created == nil then
    proto.created_effect = trigger
  elseif created.type then
    proto.created_effect = {created, trigger}
  else
    table.insert(created, trigger)
  end
end

local function sound(files, volume, distance_modifier)
  local variations = {}
  for _, file in ipairs(files) do
    variations[#variations + 1] = {filename = file, volume = volume}
  end
  return {variations = variations, audible_distance_modifier = distance_modifier}
end

local function shake(strength, duration, max_distance, full_strength)
  return {
    type = "camera-effect", strength = strength, duration = duration, ease_in_duration = 5,
    ease_out_duration = math.floor(duration / 2), max_distance = max_distance,
    full_strength_max_distance = full_strength,
  }
end

local function wave(projectile, radius, count, speed)
  if not data.raw.projectile[projectile] then return nil end
  return {
    type = "nested-result",
    action = {
      type = "area", show_in_tooltip = false, target_entities = false, trigger_from_target = true,
      repeat_count = count, radius = radius,
      action_delivery = {type = "projectile", projectile = projectile, starting_speed = speed, starting_speed_deviation = 0.075},
    },
  }
end

local LARGE = {"__base__/sound/fight/large-explosion-1.ogg", "__base__/sound/fight/large-explosion-2.ogg"}
local NUCLEAR = {
  "__base__/sound/fight/nuclear-explosion-1.ogg", "__base__/sound/fight/nuclear-explosion-2.ogg",
  "__base__/sound/fight/nuclear-explosion-3.ogg",
}

local tiers = {
  {
    name = "flo-blast-small", base = "medium-explosion",
    effects = {shake(0.6, 20, 40, 10)},
  },
  {
    name = "flo-blast-medium", base = "big-explosion",
    effects = {
      shake(2, 45, 120, 25),
      {type = "play-sound", sound = sound(LARGE, 0.9, 6), play_on_target_position = true, max_distance = 400},
    },
  },
  {
    name = "flo-blast-huge", base = "massive-explosion",
    effects = {
      shake(5, 90, 250, 50),
      {type = "play-sound", sound = sound(NUCLEAR, 1, 4), play_on_target_position = false, max_distance = 800},
      {type = "play-sound", sound = sound({"__base__/sound/fight/nuclear-explosion-aftershock.ogg"}, 0.8, 4), play_on_target_position = false, max_distance = 800},
      wave("atomic-bomb-wave-spawns-nuke-shockwave-explosion", 8, 600, 0.325),
      wave("atomic-bomb-wave-spawns-fire-smoke-explosion", 4, 300, 0.325),
      wave("atomic-bomb-wave-spawns-cluster-nuke-explosion", 14, 250, 0.3),
    },
  },
}

for _, tier in ipairs(tiers) do
  local base = data.raw.explosion[tier.base]
  if base then
    local proto = util.table.deepcopy(base)
    proto.name = tier.name
    proto.localised_name = {"entity-name." .. tier.base}
    local effects = {}
    for _, effect in pairs(tier.effects) do effects[#effects + 1] = effect end -- drops missing waves
    add_effects(proto, effects)
    data:extend({proto})
  end
end

-- Achievements (unlocked by script).
local function achievement(name, icon, order)
  return {
    type = "achievement",
    name = name,
    icon = "__base__/graphics/achievement/" .. icon .. ".png",
    icon_size = 128,
    order = "z[flammable-oils]-" .. order,
    allowed_without_fight = true,
  }
end

data:extend({
  achievement("flo-fuse", "pyromaniac", "a"),
  achievement("flo-catastrophe", "destroyer-of-worlds", "b"),
  achievement("flo-tank-saved", "you-are-doing-it-right", "c"),
  achievement("flo-cookoff", "raining-bullets", "d"),
  achievement("flo-trap", "watch-your-step", "e"),
  achievement("flo-smog", "eco-unfriendly", "f"),
})
