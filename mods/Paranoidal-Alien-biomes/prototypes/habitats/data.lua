local catalog = require("prototypes/habitats/catalog")
local sounds = require("__base__/prototypes/entity/sounds")
require("prototypes/habitats/noise")

local economy = settings.startup["alien-biomes-reforged-atlas"].value == "economy"
local vegetation = settings.startup["alien-biomes-disable-vegetation"].value ~= "Enabled"
local deco = data.raw["optimized-decorative"]
local base_rocks = {}
for _, rock in ipairs(require("prototypes/decorative/rocks-base")) do base_rocks[rock.name] = rock end
local metadata = {version = 1, habitats = {}, entities = {}, decoratives = {}}
local nauvis = data.raw.planet.nauvis
local placement = nauvis.map_gen_settings.autoplace_settings

local function tint_pictures(pictures, tint)
  if not tint then return end
  for _, picture in ipairs(pictures) do
    if picture.layers then tint_pictures(picture.layers, tint) else picture.tint = tint end
  end
end

local function decorative_source(name)
  if deco[name] then return deco[name] end
  local base_name = name:gsub("%-[%a]+$", "")
  if base_rocks[base_name] then return base_rocks[base_name] end
  -- AB can omit coloured plants entirely. Keep our saved IDs in that case;
  -- the fallback uses the same bases and tints as decorative/vegetation.lua.
  local plant_tints = {
    ["asterisk-mini-blue"] = {51/255,89/255,166/255,1},
    ["asterisk-mini-turquoise"] = {79/255,112/255,81/255,1},
    ["small-grass-green"] = {90/255,125/255,39/255,1},
    ["bush-mini-olive"] = {132/255,139/255,46/255,1},
    ["pita-mini-red"] = {175/255,46/255,46/255,1},
  }
  if plant_tints[name] then
    for _, plant in ipairs(require("prototypes/decorative/vegetation-base")) do
      if plant.name == base_name then
        local copy = table.deepcopy(plant)
        tint_pictures(copy.pictures, plant_tints[name])
        if economy then
          local kept = {}
          for i = 1, #copy.pictures, 3 do kept[#kept+1] = copy.pictures[i] end
          copy.pictures = kept
        end
        return copy
      end
    end
  end
  error("Missing habitat source: " .. name)
end

local function colony_visuals()
  -- Light-only motes: no new textures, no particle entities, no Lua scheduler.
  -- Darkness gating is native; these do not turn a forest into a lamp field.
  return {
    {
      count = 1,
      light = {intensity = 0.12, size = 1.8, color = {0.30, 0.65, 0.55}, minimum_darkness = 0.35,
               flicker_interval = 90, flicker_min_modifier = 0.7, flicker_max_modifier = 1,
               offset_flicker = true},
    },
    {
      count = economy and 1 or 3, period = 300, particle_tick_offset = 73,
      light = {intensity = 0.20, size = 0.55, color = {0.38, 0.80, 0.68}, minimum_darkness = 0.35},
      offset_x = {-0.5, 0.5}, offset_y = {-0.35, 0.35}, offset_z = {0.1, 0.6},
      speed_x = {-0.002, 0.002}, speed_y = {-0.001, 0.001}, speed_z = {0.001, 0.003},
      fade_in_progress_duration = 0.25, fade_out_progress_duration = 0.35,
      affected_by_wind = true, can_lay_on_the_ground = false,
    },
  }
end

local function ambient(source, volume, pause)
  local result = table.deepcopy(source)
  for _, variation in ipairs(result.sound.variations) do
    variation.volume = (variation.volume or 1) * volume
  end
  result.average_pause_seconds = pause
  return result
end

for _, habitat in ipairs(catalog) do
  local geology = habitat.resource and ("alien-biomes-geology-" .. habitat.resource)
  -- Geology off or a resource absent: no misleading outcrop hints in that configuration.
  local available = not habitat.resource or (data.raw.resource[habitat.resource] ~= nil and data.raw["noise-expression"][geology] ~= nil)
  -- Keep every prototype even when its generation is disabled: changing a startup
  -- setting must not delete previously placed entities from a saved map.
  do
    local tiles = alien_biomes.list_tiles(alien_biomes.require_tag(alien_biomes.all_tiles(), habitat.tags))
    local record = {field = habitat.field, resource = habitat.resource, components = {}}
    metadata.habitats[habitat.id] = record
    for _, component in ipairs(habitat.components) do
      local name = "ab-habitat-" .. component.id
      local entity = component.rock or component.entity
      local prototype
      if component.rock then
        prototype = table.deepcopy(base_rocks["big-rock"])
        -- An outcrop is a clue, never an alternate ore generator or loot jackpot.
        prototype.minable = {mining_time = 0.8, result = "stone", count = 5}
        prototype.loot = nil
        prototype.max_health = 100
      elseif component.entity then
        prototype = {
          type = "simple-entity", flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
          icon = "__base__/graphics/icons/wood.png", icon_size = 64,
          subgroup = "grass", order = "z[habitat]-a[colony]", max_health = 20,
          collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
          collision_mask = {layers = {object = true, water_tile = true, resource = true}},
          selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
          render_layer = "decorative", count_as_rock_for_filtered_deconstruction = true,
          minable = {mining_time = 0.3, result = "wood", count = 1},
          -- One stable variation in both atlas modes; saved graphics_variation stays valid.
          pictures = {table.deepcopy(decorative_source(component.source).pictures[1])},
        }
      else
        prototype = table.deepcopy(decorative_source(component.source))
      end
      -- Ground deposits may lie under vegetation. Entity/decorative collisions at
      -- chunk edges otherwise punch order-dependent holes in a shared crater field.
      -- Match base ground decals: keep water exclusion and RSO's separate mask.
      if not entity and prototype.render_layer == "decals" then
        prototype.collision_mask = {layers = {water_tile = true}, colliding_with_tiles_only = true}
      end
      prototype.name = name
      prototype.localised_name = {"ab-habitats." .. (habitat.resource and "outcrop" or component.id)}
      if entity then
        prototype.localised_description = {"ab-habitats." .. (habitat.resource and "outcrop-description" or component.id .. "-description")}
        if habitat.resource then
          prototype.localised_name = {"ab-habitats.outcrop", {"entity-name." .. habitat.resource}}
          prototype.localised_description = {"ab-habitats.outcrop-description", {"entity-name." .. habitat.resource}}
        end
      elseif habitat.resource then
        prototype.localised_name = {"ab-habitats.fragments", {"entity-name." .. habitat.resource}}
      end
      if habitat.resource and not available then
        prototype.localised_name = {"ab-habitats." .. (entity and "inactive-outcrop" or "inactive-fragments")}
        if entity then prototype.localised_description = {"ab-habitats.inactive-outcrop-description"} end
      end
      tint_pictures(prototype.pictures, component.tint)
      local probability = string.format("%g * %s * (%s)", component.density, habitat.field, component.shape or "1")
      if geology and available then probability = probability .. " * clamp(var('" .. geology .. "') - 1, 0, 1)" end
      if not available or habitat.vegetation and not vegetation or #tiles == 0 then probability = "0" end
      prototype.autoplace = {
        default_enabled = false,
        order = "a[habitat]-" .. component.id,
        probability_expression = probability, richness_expression = 1,
        tile_restriction = #tiles > 0 and tiles or nil,
      }
      if component.colony then
        prototype.stateless_visualisation_variations = {}
        for i = 1, #prototype.pictures do prototype.stateless_visualisation_variations[i] = colony_visuals() end
        prototype.ambient_sounds = {
          ambient(sounds.tree_ambient, 0.65, 16),
          ambient(sounds.tree_insects_night, 0.50, 18),
          ambient(sounds.tree_ambient_leaves, 0.60, 9),
        }
      end
      data:extend({prototype})
      local kind = entity and "entity" or "decorative"
      placement[kind].settings[name] = {}
      local list = entity and metadata.entities or metadata.decoratives
      list[#list + 1] = name
      record.components[#record.components + 1] = name
    end
  end
end

-- One shared owner, including Bio Industries copies already created in data.lua.
-- No new tree species, reproduction rules, minable results or variations are introduced.
for name, tree in pairs(data.raw.tree) do
  if name:match("^tree%-wetland%-") or name:match("^bio%-tree%-tree%-wetland%-") then
    if not tree.ambient_sounds and not tree.ambient_sounds_group then
      tree.ambient_sounds_group = "ab-habitat-root-colony"
    end
  end
end

data:extend({{type = "mod-data", name = "ab-habitats", data_type = "alien-biomes.habitats", data = metadata}})
require("prototypes/habitats/interaction")
