local shared = require("shared")

-- The blob that falls on the outpost is drawn by script, and what it splashes out is this: thick spit the colour of the
-- creep that lands as a splatter and infects nothing itself, as what it hits is decided by script.
local splash = table.deepcopy(data.raw.stream["acid-stream-worm-big"])
splash.name = "beast-splash"
splash.special_neutral_target_damage = nil
splash.particle.tint = shared.creep_tint
splash.spine_animation.tint = shared.creep_tint
-- The game's blood is purple, and its fountains are more of it.
local blood = table.deepcopy(data.raw["optimized-particle"]["blood-particle"])
blood.name = "beast-blood-particle"
blood.pictures.sheet.tint = {r = 1, g = 0.25, b = 0.25}
data:extend{blood}

for _, size in pairs{"big", "huge"} do
  local explosion = table.deepcopy(data.raw.explosion["blood-explosion-" .. size])
  explosion.name = "beast-splash-explosion-" .. size
  local spray = explosion.created_effect.action_delivery.target_effects[1]
  spray.particle_name = blood.name
  explosion.created_effect.action_delivery.target_effects = {spray}
  data:extend{explosion}
end

splash.initial_action =
{
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {type = "create-entity", entity_name = "beast-splash-explosion-big"},
        {type = "create-trivial-smoke", smoke_name = "beast-spores", repeat_count = 6, offset_deviation = {{-1, -1}, {1, 1}}, speed_from_center = 0.04}
      }
    }
  }
}
data:extend{splash}

-- Spore shells: the base game's artillery shell in the creep's colours, which infects where it lands (outbreak.lua, the
-- last research stage) instead of doing damage.
local shell = data.raw["artillery-projectile"] and data.raw["artillery-projectile"]["artillery-projectile"]
if shell then
  local spores = table.deepcopy(shell)
  spores.name = "beast-spore-shell"
  spores.hidden = true
  spores.reveal_map = false
  for _, key in pairs{"picture", "chart_picture"} do
    local sprite = spores[key]
    for _, layer in pairs(sprite and (sprite.layers or {sprite}) or {}) do layer.tint = {r = 0.9, g = 0.15, b = 0.4} end
  end
  spores.action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {type = "script", effect_id = "beast-spore-hit"},
        {type = "create-entity", entity_name = "beast-splash-explosion-big"},
        {type = "create-trivial-smoke", smoke_name = "beast-spores", repeat_count = 10, offset_deviation = {{-3, -3}, {3, 3}}, speed_from_center = 0.05}
      }
    }
  }
  spores.final_action = nil
  data:extend{spores}
end

-- The lair's core, which the outbreak founds once it has withdrawn. A biter spawner's shape in the creep's colours, as
-- it's the base game's at this point. It has no resistance to fire at all. Its death ends the outbreak.
local spawner = data.raw["unit-spawner"]["biter-spawner"]
local core_look = spawner and spawner.graphics_set and spawner.graphics_set.animations and table.deepcopy(spawner.graphics_set.animations)
if core_look then
  for _, animation in pairs(core_look) do
    for _, layer in pairs(animation.layers or {}) do
      if not layer.draw_as_shadow then
        layer.tint = {r = 0.75, g = 0.12, b = 0.3}
        layer.apply_runtime_tint = nil
      end
    end
  end
end
data:extend
{
  {
    type = "simple-entity-with-force",
    name = "beast-lair-core",
    localised_name = {"entity-name.beast-lair-core"},
    localised_description = {"entity-description.beast-lair-core"},
    icon = "__base__/graphics/icons/signal/signal-skull.png",
    flags = {"placeable-off-grid", "not-repairable", "not-blueprintable", "not-deconstructable", "not-flammable"},
    hidden_in_factoriopedia = true,
    max_health = math.floor(30000 * settings.startup["the-beast-health-multiplier"].value),
    is_military_target = true,
    create_ghost_on_death = false,
    resistances =
    {
      {type = "physical", percent = 40},
      {type = "explosion", percent = 30},
      {type = "acid", percent = 60},
      {type = "poison", percent = 90},
      {type = "fire", percent = 0}
    },
    collision_box = {{-2, -2}, {2, 2}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    map_color = {r = 0.7, g = 0.1, b = 0.6},
    dying_explosion = "beast-splash-explosion-huge",
    render_layer = "object",
    animations = core_look,
    picture = not core_look and {filename = "__Paranoidal-Protomolecule-Beast__/graphics/creep/patch.png", size = 192, scale = 0.5, tint = shared.creep_tint} or nil
  }
}

data:extend
{
  -- What's actually infecting a thing, which turrets can shoot off without hitting what's underneath. What you see of it is
  -- drawn by infection.lua, as that depends on what it's on.
  {
    type = "simple-entity-with-force",
    name = "beast-infection",
    localised_name = {"entity-name.beast-infection"},
    icon = "__base__/graphics/icons/signal/signal-skull.png",
    hidden = true,
    flags = {"placeable-off-grid", "not-on-map", "not-repairable", "not-deconstructable", "not-blueprintable", "not-rotatable"},
    collision_mask = {layers = {}},
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selectable_in_game = false,
    -- How much shooting it takes to clear one off, a startup setting.
    max_health = settings.startup["the-beast-infection-health"].value,
    resistances = {{type = "physical", percent = 80}},
    alert_when_damaged = false,
    picture =
    {
      filename = "__core__/graphics/empty.png",
      size = 1
    }
  },
  -- One tile wide at a scale of 1, see tools/make_sprites.py.
  {
    type = "sprite",
    name = "beast-creep-patch",
    filename = "__Paranoidal-Protomolecule-Beast__/graphics/creep/patch.png",
    size = 192,
    scale = 1 / 6,
    flags = {"no-crop"}
  },
  {
    type = "sprite",
    name = "beast-creep-streak",
    filename = "__Paranoidal-Protomolecule-Beast__/graphics/creep/streak.png",
    width = 128,
    height = 192,
    scale = 1 / 4,
    flags = {"no-crop"}
  },
  {
    type = "trivial-smoke",
    name = "beast-spores",
    duration = 90,
    fade_in_duration = 15,
    fade_away_duration = 45,
    spread_duration = 90,
    start_scale = 0.3,
    end_scale = 0.8,
    color = {r = 0.55, g = 0.05, b = 0.25, a = 0.5},
    cyclic = true,
    affected_by_wind = true,
    animation =
    {
      filename = "__base__/graphics/entity/smoke-fast/smoke-fast.png",
      priority = "high",
      width = 50,
      height = 50,
      frame_count = 16,
      animation_speed = 16 / 90,
      scale = 0.5
    }
  }
}
