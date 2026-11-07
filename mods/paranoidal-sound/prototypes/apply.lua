-- Exact base-prototype targets, applied once in data before downstream copies.
local sounds = require("prototypes.library")
local raw = data.raw
local function assign(kind, names, field, value)
    for name in names:gmatch("%S+") do raw[kind][name][field] = value end
end
local function sound_effect(sound)
    return {type = "play-sound", sound = sound}
end
local function replace_sound_effects(effects, replacements)
    local next_sound = 1
    for i, effect in ipairs(effects) do
        if effect.type == "play-sound" then
            effects[i] = replacements[next_sound]
            next_sound = next_sound + 1
            if next_sound > #replacements then return end
        end
    end
    error("Paranoidal Sound: expected base sound effects are missing")
end

raw["combat-robot"].defender.attack_parameters.sound = sounds.defender_shot_sound
raw["smoke-with-trigger"]["poison-cloud"].created_effect[1].action_delivery.target_effects[2].sound.variations = sounds.poison_smoke_sound
raw.capsule.grenade.capsule_action.attack_parameters.ammo_type.action[2].action_delivery.target_effects[1].sound = sounds.throwing_sound
assign("fire", "crash-site-fire-flame fire-flame fire-flame-on-tree", "working_sound", sounds.fire_flame_sound)
raw.reactor["nuclear-reactor"].working_sound.sound = sounds.nuclear_reactor_sound

local locomotive, cargo = raw.locomotive.locomotive, raw["cargo-wagon"]["cargo-wagon"]
locomotive.close_sound, locomotive.open_sound = sounds.train_door_close_sound, sounds.train_door_open_sound
locomotive.working_sound, cargo.working_sound = sounds.train_engine_working_sound, sounds.train_wagon_working_sound
replace_sound_effects(locomotive.stop_trigger, {sound_effect(sounds.train_brakes_sound), sound_effect(sounds.train_brakes_screech_sound)})
for _, kind in ipairs{"straight-rail", "half-diagonal-rail", "curved-rail-a", "curved-rail-b"} do
    raw[kind][kind].walking_sound = sounds.rail_walk_over_sound
end
local utility = raw["utility-sounds"].default
utility.switch_gun = sounds.switch_gun_sound
utility.axe_mining_ore.variations = sounds.pickaxe_mining_ore_sound
assign("armor", "modular-armor power-armor power-armor-mk2", "open_sound", sounds.armor_open_sound)
assign("armor", "modular-armor power-armor power-armor-mk2", "close_sound", sounds.armor_close_sound)
for _, row in ipairs{
    {"small-biter", sounds.biter_roar_sound, sounds.biter_die_sound},
    {"medium-biter", sounds.biter_mid_roar_sound, sounds.biter_die_sound},
    {"big-biter", sounds.biter_big_roar_sound, sounds.biter_big_die_sound},
} do
    local unit = raw.unit[row[1]]
    unit.attack_parameters.sound, unit.dying_sound = row[2], row[3]
end
for _, name in ipairs{"big-biter", "behemoth-biter"} do raw.unit[name].walking_sound.variations = sounds.biter_big_walking_sound end
raw.unit["small-spitter"].dying_sound = sounds.spitter_die_sound
for name, sound in pairs{["biter-spawner"] = sounds.spawner_live_sound, ["spitter-spawner"] = sounds.spawner_spitter_live_sound} do
    raw["unit-spawner"][name].dying_sound = sounds.spawner_die_sound
    raw["unit-spawner"][name].working_sound.sound = sound
end
assign("tree", "dead-dry-hairy-tree dead-grey-trunk dead-tree-desert dry-hairy-tree dry-tree tree-01 tree-02 tree-02-red tree-03 tree-04 tree-05 tree-06 tree-06-brown tree-07 tree-08 tree-08-brown tree-08-red tree-09 tree-09-brown tree-09-red", "vehicle_impact_sound", sounds.car_impact_wood_sound)
assign("cliff", "cliff", "vehicle_impact_sound", sounds.car_impact_stone_sound)
assign("simple-entity", "big-rock huge-rock big-sand-rock", "vehicle_impact_sound", sounds.car_impact_stone_sound)

for name, sound in pairs{
    ["submachine-gun"] = sounds.smg_sound, pistol = sounds.pistol_sound,
    ["vehicle-machine-gun"] = sounds.car_mg_sound, shotgun = sounds.pump_shotgun_sound,
    ["combat-shotgun"] = sounds.auto_shotgun_sound, ["rocket-launcher"] = sounds.rpg_shot_sound,
    ["artillery-wagon-cannon"] = sounds.arty_turret_shot_sound,
    ["tank-cannon"] = sounds.tank_cannon_sound, ["tank-machine-gun"] = sounds.tank_mg_sound,
} do raw.gun[name].attack_parameters.sound = sound end
raw.gun.flamethrower.attack_parameters.cyclic_sound = sounds.flamethrower_cyclic_sound
local gun_turret, laser = raw["ammo-turret"]["gun-turret"], raw["electric-turret"]["laser-turret"]
gun_turret.attack_parameters.sound = sounds.gun_turret_sound
gun_turret.preparing_sound, gun_turret.folding_sound = sounds.gun_turret_activate_sound, sounds.gun_turret_deactivate_sound
laser.preparing_sound, laser.folding_sound = sounds.laser_turret_activate_sound, sounds.laser_turret_deactivate_sound
raw.beam["laser-beam"].working_sound.sound = sounds.laser_beam_sound
raw["artillery-turret"]["artillery-turret"].rotating_sound.sound = sounds.arty_turret_rotate_sound
raw["artillery-turret"]["artillery-turret"].rotating_stopped_sound = sounds.arty_turret_stop_rotate_sound
for name, tuning in pairs{tank = {0.1, 0.1, 0.2}, car = {0.25, 0.8, 0.15}} do
    local vehicle = raw.car[name]
    vehicle.sound_minimum_speed, vehicle.sound_scaling_ratio, vehicle.stop_trigger_speed = tuning[1], tuning[2], tuning[3]
    vehicle.sound_no_fuel = sounds[name .. "_engine_no_fuel_sound"]
    vehicle.stop_trigger = sounds[name .. "_brake_sound"]
    vehicle.working_sound = sounds[name .. "_engine_working_sound"]
    vehicle.open_sound, vehicle.close_sound = sounds[name .. "_door_open_sound"], sounds[name .. "_door_close_sound"]
end
local nuke = {}
for _, sound in ipairs{sounds.nuke_explosion_sound, sounds.nuke_aftershock_sound} do
    nuke[#nuke + 1] = {type = "play-sound", sound = sound, play_on_target_position = false, max_distance = 1000, audible_distance_modifier = 3}
end
replace_sound_effects(raw.projectile["atomic-rocket"].action.action_delivery.target_effects, nuke)

-- Order is significant: base reuses Sound wrappers between explosions.
-- Preserve the old assignment order and replace only the seven originally absent wrappers.
for _, row in ipairs{
    {"small", "accumulator active-provider-chest arithmetic-combinator"},
    {"medium", "artillery-turret"},
    {"large", "artillery-wagon assembling-machine-1 assembling-machine-2 assembling-machine-3 beacon big-artillery"},
    {"medium", "big-electric-pole"}, {"large", "big"}, {"medium", "boiler"},
    {"small", "buffer-chest burner-inserter burner-mining-drill"}, {"medium", "car"},
    {"large", "cargo-wagon centrifuge chemical-plant"},
    {"small", "constant-combinator construction-robot decider-combinator"},
    {"large", "electric-furnace"}, {"medium", "electric-mining-drill"},
    {"small", "explosion express-splitter"},
    {"small", "express-transport-belt express-underground-belt", true},
    {"small", "fast-inserter fast-splitter fast-transport-belt"},
    {"small", "fast-underground-belt", true}, {"small", "flamethrower-turret"},
    {"large", "fluid-wagon"}, {"small", "gate"},
    {"medium", "grenade ground gun-turret heat-exchanger"},
    {"small", "heat-pipe inserter iron-chest"}, {"medium", "lab"},
    {"small", "lamp land-mine laser-turret"}, {"large", "locomotive"},
    {"small", "logistic-robot long-handed-inserter"}, {"large", "massive"},
    {"small", "medium-electric-pole"}, {"medium", "medium"},
    {"large", "nuclear-reactor nuke"}, {"small", "offshore-pump"},
    {"large", "oil-refinery"}, {"small", "passive-provider-chest"},
    {"small", "pipe pipe-to-ground", true}, {"small", "power-switch programmable-speaker pump"},
    {"large", "pumpjack"}, {"medium", "radar"}, {"small", "rail-chain-signal"},
    {"medium", "rail"}, {"small", "rail-signal requester-chest"},
    {"medium", "roboport"}, {"large", "rocket-silo"},
    {"small", "slowdown-capsule"}, {"medium", "solar-panel"}, {"large", "spidertron"},
    {"small", "splitter"}, {"large", "steam-engine steam-turbine"},
    {"small", "steel-chest"}, {"large", "steel-furnace"}, {"medium", "stone-furnace"},
    {"small", "storage-chest"}, {"large", "storage-tank"}, {"medium", "substation"},
    {"large", "tank"}, {"medium", "train-stop"}, {"small", "transport-belt underground-belt", true},
} do
    for name in row[2]:gmatch("%S+") do
        local explosion = raw.explosion[name == "explosion" and name or name .. "-explosion"]
        -- MIRV2's replacement used to run after Immersive; keep its own explosion audio.
        if not (name == "nuke" and mods.MIRV2) then
            if row[3] then explosion.sound = {} end
            explosion.sound.variations = sounds[row[1] .. "_explosion_sound"]
        end
    end
end
