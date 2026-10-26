-- Buildings of the citadel ("city of robots"): floor tiles, walls and gates, power, lamps and the
-- module buildings. Graphics are the base buildings recoloured; the buildings are passive
-- simple-entity-with-owner (no engine update) unless they need power or radar scanning.
local S = require("lib.shared")
local G = require("prototypes.gfx")
local E = S.entity
local raw = data.raw

local STEEL = {r = 0.62, g = 0.52, b = 0.52}      -- buildings: dark steel with a red cast
local DARK = {r = 0.45, g = 0.38, b = 0.4}        -- walls, floor
local MAP = {r = 0.55, g = 0.1, b = 0.15}

local RESIST = {
  {type = "physical", decrease = 5, percent = 30},
  {type = "explosion", decrease = 10, percent = 30},
  {type = "fire", percent = 80},
  {type = "acid", percent = 40},
  {type = "laser", percent = 20},
  {type = "electric", percent = 20},
  {type = "poison", percent = 100},
}
local WALL_RESIST = {
  {type = "physical", decrease = 5, percent = 45},
  {type = "explosion", decrease = 15, percent = 45},
  {type = "fire", percent = 100},
  {type = "acid", percent = 70},
  {type = "laser", percent = 60},
  {type = "electric", percent = 60},
  {type = "poison", percent = 100},
}
S.structure_resistances = RESIST

local FLAGS = {"placeable-enemy", "not-rotatable", "not-blueprintable", "not-deconstructable", "not-flammable"}

local function base_entity(t, n)
  return raw[t] and raw[t][n]
end

--- Common fields of a citadel building.
local function common(p, w, h, health, icon_from)
  local col, sel = G.boxes(w, h)
  p.flags = FLAGS
  p.max_health = health
  p.collision_box = col
  p.selection_box = sel
  p.resistances = p.resistances or RESIST
  p.minable = nil
  p.placeable_by = nil
  p.fast_replaceable_group = nil
  p.next_upgrade = nil
  p.hidden_in_factoriopedia = true
  p.factoriopedia_simulation = nil
  p.map_color = MAP
  p.enemy_map_color = MAP
  p.friendly_map_color = MAP
  p.dying_explosion = p.dying_explosion or (w >= 4 and "big-explosion" or "medium-explosion")
  p.corpse = (w >= 4 and "big-remnants") or (w >= 2 and "medium-remnants") or "small-remnants"
  p.icons = G.icons(icon_from, STEEL)
  p.icon = nil
  p.icon_size = nil
  p.subgroup = "enemies"
  p.order = "z[replicators]-" .. p.name
  return p
end

--- A passive building from an animation (animated when its layers can be matched, else its first frame).
local function building(name, source, scale, tint, health, opts)
  opts = opts or {}
  local size = S.size[name]
  local gfx = G.tint_all(G.scale(G.copy(source), scale), tint)
  local p = {type = "simple-entity-with-owner", name = name, render_layer = "object",
    is_military_target = opts.military == true, random_variation_on_create = false}
  local anim = (not opts.static) and G.animation(gfx)
  if anim and opts.animated ~= false then p.animations = anim else p.picture = G.first_frame(gfx) end
  common(p, size[1], size[2], health, opts.icon)
  return p
end

local function first(x)
  if not x then return nil end
  return x.north or x
end

local am3 = base_entity("assembling-machine", "assembling-machine-3")
local roboport = base_entity("roboport", "roboport")
local reactor = base_entity("reactor", "nuclear-reactor")
local lab = base_entity("lab", "lab")
local furnace = base_entity("furnace", "electric-furnace")
local turbine = base_entity("generator", "steam-turbine")
local chem = base_entity("assembling-machine", "chemical-plant")
local refinery = base_entity("assembling-machine", "oil-refinery")
local centrifuge = base_entity("assembling-machine", "centrifuge")
local accumulator = base_entity("accumulator", "accumulator")
local radar = base_entity("radar", "radar")
local big_pole = base_entity("electric-pole", "big-electric-pole")
local substation = base_entity("electric-pole", "substation")
local chest = base_entity("container", "steel-chest")
local lamp = base_entity("lamp", "small-lamp")

local list = {}
local function add(p) list[#list + 1] = p end

---------------------------------------------------------------------------------------------------
-- Core: the roboport body with its blinking lights, 7x7.
---------------------------------------------------------------------------------------------------
do
  local layers = {}
  local base = G.copy(roboport.base)
  for _, l in pairs(base.layers or {base}) do layers[#layers + 1] = l end
  layers[#layers + 1] = G.copy(roboport.base_animation)
  local core = building(E.core, {layers = layers}, 1.75, STEEL, 25000, {military = true, icon = roboport})
  core.resistances = WALL_RESIST
  core.dying_explosion = "massive-explosion"
  add(core)
end

---------------------------------------------------------------------------------------------------
-- Droid foundries: the assembling machine 3, 5x5, one colour per foundry.
---------------------------------------------------------------------------------------------------
local FOUNDRY_TINT = {
  light = {r = 0.75, g = 0.6, b = 0.6},
  assault = {r = 0.85, g = 0.35, b = 0.3},
  fire = {r = 1.0, g = 0.55, b = 0.2},
  sniper = {r = 0.6, g = 0.75, b = 0.45},
  energy = {r = 0.45, g = 0.6, b = 1.0},
  air = {r = 0.45, g = 0.9, b = 0.9},
  terminator = {r = 0.35, g = 0.3, b = 0.35},
}
for _, f in pairs(S.foundries) do
  add(building(E["foundry_" .. f], first(am3.graphics_set.animation), 5 / 3, FOUNDRY_TINT[f], 6000,
    {military = true, icon = am3}))
end

---------------------------------------------------------------------------------------------------
-- Module buildings.
---------------------------------------------------------------------------------------------------
add(building(E.assembler, first(am3.graphics_set.animation), 1, DARK, 1500, {icon = am3}))
add(building(E.turbine, turbine.horizontal_animation, 1, STEEL, 1500, {icon = turbine}))
add(building(E.depot, first(refinery.graphics_set.animation), 1, STEEL, 5000, {military = true, icon = refinery}))
add(building(E.repair_bay, first(chem.graphics_set.animation), 1, {r = 0.6, g = 0.9, b = 0.6}, 4000,
  {military = true, icon = chem}))
add(building(E.recycler, centrifuge.graphics_set.idle_animation, 1, {r = 0.8, g = 0.7, b = 0.5}, 4000,
  {military = true, icon = centrifuge}))
add(building(E.armory, first(furnace.graphics_set.animation), 4 / 3, {r = 0.7, g = 0.7, b = 0.8}, 5000,
  {military = true, icon = furnace}))
add(building(E.arsenal, lab.on_animation, 1, {r = 1.0, g = 0.4, b = 0.35}, 4000, {military = true, icon = lab}))
add(building(E.targeting, radar.pictures, 1, {r = 0.5, g = 1.0, b = 0.5}, 4000,
  {military = true, static = true, icon = radar}))
add(building(E.ai_core, lab.on_animation, 5 / 3, {r = 0.4, g = 0.55, b = 1.0}, 6000, {military = true, icon = lab}))
add(building(E.jammer, lab.on_animation, 4 / 3, {r = 0.75, g = 0.4, b = 1.0}, 4000, {military = true, icon = lab}))
add(building(E.relay, big_pole.pictures, 1.4, {r = 1.0, g = 0.8, b = 0.4}, 3000,
  {military = true, static = true, icon = big_pole}))
add(building(E.shield_node, accumulator.chargable_graphics.picture, 1, {r = 0.4, g = 0.9, b = 1.0}, 3000,
  {military = true, icon = accumulator}))
add(building(E.mine_control, substation.pictures, 1, {r = 1.0, g = 0.6, b = 0.3}, 3000,
  {military = true, static = true, icon = substation}))
add(building(E.crate, chest.picture, 1, STEEL, 300, {icon = chest}))

---------------------------------------------------------------------------------------------------
-- Power: reactors (electric energy interfaces that produce), accumulators, the hub pylon of every
-- module (supplies the whole chunk, wired to the hubs of the neighbour modules), lamps without power.
---------------------------------------------------------------------------------------------------
do
  local p = {
    type = "electric-energy-interface", name = E.reactor,
    energy_source = {type = "electric", buffer_capacity = "20MJ", usage_priority = "primary-output",
      input_flow_limit = "0W", output_flow_limit = "20MW"},
    energy_production = "20MW",
    energy_usage = "0W",
    gui_mode = "none",
    is_military_target = true,
    picture = G.tint_all(G.scale(G.copy(reactor.picture), 0.8), STEEL),
  }
  common(p, 4, 4, 5000, reactor)
  add(p)
end

do
  local p = G.copy(accumulator)
  p.name = E.accumulator
  p.energy_source = {type = "electric", buffer_capacity = "20MJ", usage_priority = "tertiary",
    input_flow_limit = "2MW", output_flow_limit = "2MW"}
  p.chargable_graphics = G.tint_all(p.chargable_graphics, STEEL)
  p.circuit_connector = nil
  p.circuit_wire_max_distance = nil
  p.default_output_signal = nil
  p.is_military_target = true
  common(p, 2, 2, 2500, accumulator)
  add(p)
end

do
  local p = G.copy(radar)
  p.name = E.radar
  p.pictures = G.tint_all(p.pictures, {r = 1.0, g = 0.5, b = 0.45})
  p.energy_usage = "300kW"
  p.max_distance_of_sector_revealed = 2
  p.max_distance_of_nearby_sector_revealed = 2
  p.is_military_target = true
  p.circuit_connector = nil
  p.circuit_wire_max_distance = nil
  common(p, 3, 3, 4000, radar)
  add(p)
end

do
  local p = G.copy(big_pole)
  p.name = E.pylon
  p.pictures = G.tint_all(p.pictures, STEEL)
  p.supply_area_distance = 16
  p.maximum_wire_distance = 33
  p.draw_copper_wires = true
  common(p, 2, 2, 1500, big_pole)
  add(p)
end

do
  local p = G.copy(lamp)
  p.name = E.lamp
  p.energy_source = {type = "void"}
  p.always_on = true
  p.light = {intensity = 0.9, size = 28, color = {r = 1.0, g = 0.3, b = 0.25}}
  p.light_when_colored = nil
  p.glow_size = 6
  p.circuit_connector = nil
  p.circuit_wire_max_distance = nil
  common(p, 1, 1, 300, lamp)
  p.dying_explosion = "lamp-explosion"
  add(p)
end

---------------------------------------------------------------------------------------------------
-- Walls and gates.
---------------------------------------------------------------------------------------------------
do
  local wall = G.copy(raw.wall["stone-wall"])
  wall.name = E.wall
  wall.pictures = G.tint_all(wall.pictures, DARK)
  wall.resistances = WALL_RESIST
  wall.circuit_connector = nil
  wall.circuit_wire_max_distance = nil
  common(wall, 1, 1, 1500, raw.wall["stone-wall"])
  wall.collision_box = {{-0.29, -0.29}, {0.29, 0.29}}
  wall.resistances = WALL_RESIST
  wall.dying_explosion = "wall-explosion"
  wall.corpse = "wall-remnants"
  add(wall)

  local gate = G.copy(raw.gate.gate)
  gate.name = E.gate
  for _, k in pairs({"vertical_animation", "horizontal_animation", "vertical_rail_animation_left",
    "vertical_rail_animation_right", "horizontal_rail_animation_left", "horizontal_rail_animation_right",
    "vertical_rail_base", "horizontal_rail_base", "wall_patch"}) do
    if gate[k] then gate[k] = G.tint_all(gate[k], DARK) end
  end
  common(gate, 1, 1, 1500, raw.gate.gate)
  gate.flags = {"placeable-enemy", "not-blueprintable", "not-deconstructable", "not-flammable"}
  gate.collision_box = {{-0.29, -0.29}, {0.29, 0.29}}
  gate.resistances = WALL_RESIST
  gate.dying_explosion = "gate-explosion"
  gate.corpse = "gate-remnants"
  add(gate)
end

---------------------------------------------------------------------------------------------------
-- Floor tiles (not minable: the city is paved, its ruins stay).
---------------------------------------------------------------------------------------------------
do
  local function tile(name, from, tint)
    local t = G.copy(raw.tile[from])
    t.name = name
    t.tint = tint
    t.minable = nil
    t.placeable_by = nil
    t.next_direction = nil
    t.map_color = {r = 0.32, g = 0.12, b = 0.14}
    t.hidden_in_factoriopedia = true
    t.order = "z[replicators]-" .. name
    return t
  end
  add(tile(S.tile_floor, "refined-concrete", {r = 0.5, g = 0.42, b = 0.44}))
  add(tile(S.tile_road, "refined-hazard-concrete-left", {r = 0.75, g = 0.4, b = 0.4}))
end

---------------------------------------------------------------------------------------------------
-- Replicator core: dropped by the key buildings; taken apart into parts (recipe unlocked by the
-- control script for every player force once the citadel appears).
---------------------------------------------------------------------------------------------------
add({
  type = "item",
  name = S.core_item,
  icons = {
    {icon = "__base__/graphics/icons/processing-unit.png", icon_size = 64, tint = {r = 1, g = 0.45, b = 0.4}},
    {icon = "__base__/graphics/icons/signal/signal-skull.png", icon_size = 64, scale = 0.25, shift = {8, 8}},
  },
  subgroup = "robotarmy-droids",
  order = "z[replicator-core]",
  stack_size = 50,
})
add({
  type = "recipe",
  name = S.decrypt_recipe,
  category = "crafting",
  enabled = false,
  energy_required = 8,
  ingredients = {{type = "item", name = S.core_item, amount = 1}},
  -- More parts are added in data-final-fixes from the items of the build (prototypes/loot.lua).
  results = {
    {type = "item", name = "advanced-circuit", amount = 3},
    {type = "item", name = "processing-unit", amount = 1, probability = 0.5},
    {type = "item", name = "steel-plate", amount = 5},
  },
  icons = {
    {icon = "__base__/graphics/icons/processing-unit.png", icon_size = 64, tint = {r = 1, g = 0.45, b = 0.4}},
    {icon = "__base__/graphics/icons/signal/signal-skull.png", icon_size = 64, scale = 0.25, shift = {8, 8}},
  },
  subgroup = "robotarmy-droids",
  order = "z[replicator-core]",
  allow_productivity = false,
  auto_recycle = false,
})

data:extend(list)
