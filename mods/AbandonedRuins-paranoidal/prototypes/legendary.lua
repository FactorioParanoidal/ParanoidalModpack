-- Prototypes of the legendary ruins: the untouchable wall, levers, guardian bolts and the relics.
-- Runs in data-updates: every mod's data.lua is done, so prototypes of other mods can be copied.
-- Relics are copies of existing buildings with a changed name, energy and stats; they have no
-- recipe (they are found only in legendary ruins) and are not recycled.

local function raw(type_name, name)
  return data.raw[type_name] and data.raw[type_name][name]
end

local function copy(type_name, name, fallback_type, fallback_name)
  local p = raw(type_name, name) or (fallback_type and raw(fallback_type, fallback_name))
  return p and table.deepcopy(p) or nil
end

-- Tint of sprites inside graphics fields; shadows, lights and glows keep their colours.
local GRAPHIC_FIELDS = {
  "graphics_set", "picture", "pictures", "animation", "animations", "on_animation", "off_animation",
  "base_picture", "base", "base_patch", "base_animation", "folded_animation", "preparing_animation",
  "prepared_animation", "attacking_animation", "folding_animation", "energy_glow_animation",
  "cannon_barrel_pictures", "cannon_base_pictures", "picture_off", "integration_patch",
  "door_animation_up", "door_animation_down", "recharging_animation",
}

local function tint_node(node, tint, depth)
  if type(node) ~= "table" or depth > 14 then return end
  if node.filename or node.filenames or node.stripes then
    if not (node.draw_as_shadow or node.draw_as_light or node.draw_as_glow) then node.tint = tint end
    return
  end
  for key, value in pairs(node) do
    local skip = type(key) == "string" and (key:find("sound", 1, true) or key:find("light", 1, true))
    if type(value) == "table" and not skip then tint_node(value, tint, depth + 1) end
  end
end

local function tint_entity(entity, tint)
  for _, field in ipairs(GRAPHIC_FIELDS) do
    if entity[field] then tint_node(entity[field], tint, 0) end
  end
end

local STAR = raw("virtual-signal", "signal-star")

local function relic_icons(source, tint)
  local icons
  if source and source.icons then
    icons = table.deepcopy(source.icons)
  elseif source and source.icon then
    icons = { { icon = source.icon, icon_size = source.icon_size or 64 } }
  else
    icons = { { icon = "__base__/graphics/icons/signal/signal-star.png", icon_size = 64 } }
  end
  for _, layer in ipairs(icons) do
    if not layer.tint then layer.tint = tint end
  end
  if STAR and STAR.icon then
    icons[#icons + 1] = { icon = STAR.icon, icon_size = STAR.icon_size or 64, scale = 0.25, shift = { 9, -9 } }
  end
  return icons
end

-- Common relic entity settings.
local function finish(entity, name, tint, source_item)
  entity.name = name
  entity.minable = { mining_time = 1, result = name }
  entity.placeable_by = nil
  entity.next_upgrade = nil
  entity.fast_replaceable_group = nil
  entity.factoriopedia_simulation = nil
  entity.localised_name = nil
  entity.localised_description = nil
  entity.hidden = nil
  entity.hidden_in_factoriopedia = nil
  entity.max_health = math.max(entity.max_health or 300, 800)
  entity.flags = { "placeable-neutral", "placeable-player", "player-creation" }
  if tint then tint_entity(entity, tint) end
  entity.icons = relic_icons(source_item or entity, tint)
  entity.icon, entity.icon_size = nil, nil
  return entity
end

local relics, items = {}, {}

local function add(entity, order)
  relics[#relics + 1] = entity
  items[#items + 1] = {
    type = "item",
    name = entity.name,
    icons = table.deepcopy(entity.icons),
    subgroup = "pd-legendary-relics",
    order = order,
    place_result = entity.name,
    stack_size = 1,
    auto_recycle = false,
  }
end

local VOID = { type = "void" }
local function item_of(name) return raw("item", name) end

-- 1. Daedalus workshop: assembling machine without power, fast, never adds defects
do
  local e = copy("assembling-machine", "assembling-machine-2")
  if e then
    finish(e, "pd-relic-daedalus-workshop", { 1, 0.85, 0.5 }, item_of("assembling-machine-2"))
    e.energy_source = table.deepcopy(VOID)
    e.crafting_speed = 2
    e.module_slots = 2
    add(e, "a")
  end
end

-- 2. Minelayer: a chest that plants land mines around itself (script)
do
  local e = copy("container", "iron-chest")
  if e then
    finish(e, "pd-relic-minelayer", { 0.7, 0.3, 0.3 }, item_of("land-mine") or item_of("iron-chest"))
    e.inventory_size = 16
    add(e, "b")
  end
end

-- 3, 15. Sun obelisk and the heart of the reactor: constant electric power
local function power_relic(name, power, tint, order)
  local e = copy("electric-energy-interface", "RITEG-1", "electric-energy-interface", "electric-energy-interface")
  if not e then return end
  finish(e, name, tint, item_of("RITEG-1") or item_of("accumulator"))
  e.energy_source = {
    type = "electric", usage_priority = "primary-output", buffer_capacity = power:gsub("W$", "J"),
    input_flow_limit = "0kW", output_flow_limit = power, render_no_power_icon = false,
  }
  e.energy_production = power
  e.energy_usage = "0kW"
  e.gui_mode = "none"
  add(e, order)
end
power_relic("pd-relic-sun-obelisk", "1MW", { 1, 0.9, 0.4 }, "c")
power_relic("pd-relic-heart-of-reactor", "5MW", { 0.5, 1, 0.5 }, "o")

-- 4, 20. Radars without power: the All-seeing Eye (live view far around) and the Star telescope
local function radar_relic(name, sectors, nearby, tint, order)
  local e = copy("radar", "radar")
  if not e then return end
  finish(e, name, tint, item_of("radar"))
  e.energy_source = table.deepcopy(VOID)
  e.energy_usage = "1MW"
  e.max_distance_of_sector_revealed = sectors
  e.max_distance_of_nearby_sector_revealed = nearby
  add(e, order)
end
radar_relic("pd-relic-all-seeing-eye", 20, 10, { 0.7, 0.8, 1 }, "d")
radar_relic("pd-relic-star-telescope", 48, 4, { 0.6, 0.5, 1 }, "t")
radar_relic("pd-relic-rescue-beacon", 14, 3, { 1, 0.6, 0.3 }, "s")

-- 5. Deep drill: no power, 9 x 9 area
do
  local e = copy("mining-drill", "electric-mining-drill")
  if e then
    finish(e, "pd-relic-deep-drill", { 0.85, 0.7, 0.5 }, item_of("electric-mining-drill"))
    e.energy_source = table.deepcopy(VOID)
    e.mining_speed = 1
    e.resource_searching_radius = 4.49
    add(e, "e")
  end
end

-- 6. Forerunner gate: a pad you can stand on; gates of a force form a ring of teleports (script)
do
  local mine = raw("land-mine", "teleporter") or raw("land-mine", "land-mine")
  local picture = mine and table.deepcopy(mine.picture_safe) or nil
  local e = {
    type = "simple-entity-with-owner",
    name = "pd-relic-forerunner-gate",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 1, result = "pd-relic-forerunner-gate" },
    max_health = 800,
    collision_box = { { -0.9, -0.9 }, { 0.9, 0.9 } },
    selection_box = { { -1, -1 }, { 1, 1 } },
    collision_mask = { layers = {} },
    render_layer = "floor",
    picture = picture,
  }
  if picture then tint_node(e.picture, { 0.6, 0.8, 1 }, 0) end
  e.icons = relic_icons(item_of("teleporter") or item_of("land-mine"), { 0.6, 0.8, 1 })
  add(e, "f")
end

-- 7. Archive of the Forerunners: lab without power, double speed, half the science
do
  local e = copy("lab", "lab")
  if e then
    finish(e, "pd-relic-archive", { 0.6, 0.75, 1 }, item_of("lab"))
    e.energy_source = table.deepcopy(VOID)
    e.researching_speed = 2
    e.science_pack_drain_rate_percent = 50
    add(e, "g")
  end
end

-- 8. Prism turret: laser turret without power
do
  local e = copy("electric-turret", "laser-turret")
  if e then
    finish(e, "pd-relic-prism-turret", { 0.6, 1, 1 }, item_of("laser-turret"))
    e.energy_source = table.deepcopy(VOID)
    e.max_health = 1500
    add(e, "h")
  end
end

-- 9, 10. Time anchor and the Scales of Themis: chests with scripted effects
do
  local e = copy("container", "steel-chest")
  if e then
    finish(e, "pd-relic-time-anchor", { 0.75, 0.55, 1 }, item_of("steel-chest"))
    e.inventory_size = 160
    add(e, "i")
  end
  e = copy("container", "steel-chest")
  if e then
    finish(e, "pd-relic-themis-scales", { 1, 0.85, 0.4 }, item_of("steel-chest"))
    e.inventory_size = 32
    add(e, "j")
  end
end

-- 11. Forge of Hephaestus: furnace without fuel, very fast
do
  local e = copy("furnace", "steel-furnace", "furnace", "stone-furnace")
  if e then
    finish(e, "pd-relic-hephaestus-forge", { 1, 0.6, 0.4 }, item_of("steel-furnace") or item_of("stone-furnace"))
    e.energy_source = table.deepcopy(VOID)
    e.crafting_speed = 5
    add(e, "k")
  end
end

-- 12, 17. Champion's banner and the healing spring: always-lit lamps with scripted auras
local function lamp_relic(name, base, color, tint, order)
  local e = copy("lamp", base, "lamp", "small-lamp")
  if not e then return end
  finish(e, name, tint, item_of(base) or item_of("small-lamp"))
  e.energy_source = table.deepcopy(VOID)
  e.always_on = true
  if type(e.light) == "table" then
    e.light.color = color
    e.light.size = 30
    e.light.intensity = 0.9
  end
  e.light_when_colored = nil
  add(e, order)
end
lamp_relic("pd-relic-champion-banner", "small-lamp", { 1, 0.6, 0.2 }, { 1, 0.5, 0.3 }, "l")
lamp_relic("pd-relic-healing-spring", "deadlock-large-lamp", { 0.4, 1, 0.6 }, { 0.5, 1, 0.7 }, "q")

-- 13. Xeno-incubator: raises alien artifacts from fish, no power
local ARTIFACT = raw("item", "bob-alien-artifact") and "bob-alien-artifact" or "raw-fish"
data:extend({
  { type = "recipe-category", name = "pd-relic-xeno" },
  { type = "recipe-category", name = "pd-relic-sprout" },
  {
    type = "recipe", name = "pd-relic-xeno-culture", category = "pd-relic-xeno", enabled = true,
    energy_required = 30, hide_from_player_crafting = true, allow_productivity = false, auto_recycle = false,
    ingredients = { { type = "item", name = "raw-fish", amount = 10 } },
    results = { { type = "item", name = ARTIFACT, amount = ARTIFACT == "raw-fish" and 12 or 1 } },
  },
  {
    type = "recipe", name = "pd-relic-sprout-growth", category = "pd-relic-sprout", enabled = true,
    energy_required = 10, hide_from_player_crafting = true, allow_productivity = false, auto_recycle = false,
    ingredients = {},
    results = { { type = "item", name = "wood", amount = 4 } },
  },
})
local function fixed_machine(name, base, fallback, recipe, category, tint, order, emissions)
  local e = copy("assembling-machine", base, "assembling-machine", fallback)
  if not e then return end
  finish(e, name, tint, item_of(base) or item_of(fallback))
  e.energy_source = { type = "void", emissions_per_minute = emissions }
  e.crafting_categories = { category }
  e.fixed_recipe = recipe
  e.crafting_speed = 1
  e.module_slots = 0
  e.allowed_effects = nil
  add(e, order)
end
fixed_machine("pd-relic-xeno-incubator", "bi-bio-reactor", "chemical-plant", "pd-relic-xeno-culture", "pd-relic-xeno",
  { 0.7, 1, 0.5 }, "m", nil)
-- 21. Sprout of Yggdrasil: grows wood from nothing and cleans the air
fixed_machine("pd-relic-yggdrasil-sprout", "bi-bio-greenhouse", "assembling-machine-1", "pd-relic-sprout-growth", "pd-relic-sprout",
  { 0.6, 1, 0.6 }, "u", { pollution = -120 })

-- 14. Director's hive: roboport without power
do
  local e = copy("roboport", "roboport")
  if e then
    finish(e, "pd-relic-director-hive", { 1, 0.5, 0.5 }, item_of("roboport"))
    e.energy_source = table.deepcopy(VOID)
    add(e, "n")
  end
end

-- 16. Eternal spring: a storage tank that fills itself with crude oil (script)
do
  local e = copy("storage-tank", "storage-tank")
  if e then
    finish(e, "pd-relic-eternal-spring", { 0.45, 0.4, 0.4 }, item_of("storage-tank"))
    add(e, "p")
  end
end

-- 18. The Hammer: artillery that loads its own shells (script)
do
  local e = copy("artillery-turret", "artillery-turret")
  if e then
    finish(e, "pd-relic-hammer", { 0.7, 0.6, 0.55 }, item_of("artillery-turret"))
    add(e, "r")
  end
end

-- 22. Funeral bell: the force respawns next to it (script)
do
  local speaker = raw("programmable-speaker", "programmable-speaker")
  local e = {
    type = "simple-entity-with-owner",
    name = "pd-relic-funeral-bell",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 1, result = "pd-relic-funeral-bell" },
    max_health = 800,
    collision_box = { { -0.3, -0.3 }, { 0.3, 0.3 } },
    selection_box = { { -0.5, -2.2 }, { 0.5, 0.5 } },
    picture = speaker and table.deepcopy(speaker.sprite) or nil,
  }
  if e.picture then tint_node(e.picture, { 0.7, 0.75, 0.9 }, 0) end
  e.icons = relic_icons(item_of("programmable-speaker"), { 0.7, 0.75, 0.9 })
  add(e, "v")
end

data:extend({ { type = "item-subgroup", name = "pd-legendary-relics", group = "production", order = "zz-relics" } })
data:extend(relics)
data:extend(items)

-- Structure of the ruins ------------------------------------------------------------------

-- Untouchable wall: stone wall look, full-tile collision box (characters of minime can squeeze
-- between ordinary walls), no item, cannot be mined.
do
  local wall = copy("wall", "stone-wall")
  wall.name = "pd-legend-wall"
  wall.collision_box = { { -0.49, -0.49 }, { 0.49, 0.49 } }
  wall.minable = nil
  wall.placeable_by = nil
  wall.next_upgrade = nil
  wall.fast_replaceable_group = nil
  wall.factoriopedia_simulation = nil
  wall.flags = { "placeable-neutral", "not-blueprintable", "not-deconstructable", "not-repairable" }
  wall.max_health = 2000
  wall.hidden_in_factoriopedia = true
  wall.create_ghost_on_death = false
  data:extend({ wall })
end

-- Lever: an old post that is "pulled" by mining it (the script reacts and puts it back).
do
  local speaker = raw("programmable-speaker", "programmable-speaker")
  data:extend({
    {
      type = "simple-entity-with-owner",
      name = "pd-legend-lever",
      icons = relic_icons(item_of("programmable-speaker"), { 1, 0.8, 0.5 }),
      flags = { "placeable-neutral", "not-blueprintable", "not-deconstructable" },
      minable = { mining_time = 1 },
      max_health = 500,
      collision_box = { { -0.3, -0.3 }, { 0.3, 0.3 } },
      selection_box = { { -0.5, -2.2 }, { 0.5, 0.5 } },
      picture = speaker and table.deepcopy(speaker.sprite) or nil,
      hidden_in_factoriopedia = true,
      create_ghost_on_death = false,
    },
  })
end

-- Guardian bolts: like a cannon shell they stop at the first wall or creature in their path.
local function bolt(name, physical, explosion)
  local p = copy("projectile", "cannon-projectile")
  if not p then return end
  p.name = name
  p.collision_box = { { -0.1, -0.25 }, { 0.1, 0.25 } }
  p.piercing_damage = 1
  p.action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        { type = "damage", damage = { amount = physical, type = "physical" } },
        { type = "damage", damage = { amount = explosion, type = "explosion" } },
        { type = "create-entity", entity_name = "explosion" },
      },
    },
  }
  if type(p.animation) == "table" then p.animation.tint = { 1, 0.35, 0.25 } end
  data:extend({ p })
end
bolt("pd-legend-bolt", 45, 20)
bolt("pd-legend-bolt-light", 25, 10)
