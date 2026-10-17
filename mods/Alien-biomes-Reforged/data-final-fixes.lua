local data_util = require('data-util')
local fallback_tile = "landfill"
local transitions = require("prototypes/tile/tile-transitions-static")

require("prototypes/phase-3/collision-common")

-- now that terrains can be larger spread out resources
for _, resource in pairs(data.raw.resource) do
  if resource.coverage then
    resource.coverage = resource.coverage / 2
  end
  if resource.richness_multiplier_distance_bonus then
    resource.richness_multiplier_distance_bonus = 1 + (resource.richness_multiplier_distance_bonus - 1) / 2
  end
  resource.selection_priority = 0
end

-- it may be tempting to completely remove all vegetation entities from the game for this
-- but that would be bad becuase it would affect existing chunks and break mods
if settings.startup["alien-biomes-disable-vegetation"].value == "Enabled" then
  for _, prototype in pairs(data.raw['tree']) do
    prototype.autoplace = nil
  end
  for _, prototype in pairs(data.raw['tile']) do
    if string.find(prototype.name, "grass") then
      prototype.autoplace = nil
    end
  end
  for _, prototype in pairs(data.raw['tile']) do
    if string.find(prototype.name, "grass") then
      prototype.autoplace = nil
    end
  end
  local block_decorative_words = {"grass", "asterisk", "fluff", "garballo", "bush", "croton", "pita", "cane"}
  for _, prototype in pairs(data.raw['optimized-decorative']) do
    for _, word in pairs(block_decorative_words) do
      if string.find(prototype.name, word) then
        prototype.autoplace = nil
      end
    end
  end
  data.raw['fish']['fish'].autoplace = nil
end

data.raw.tile.landfill.map_color = { r = 68, g = 61, b = 55 }
data.raw.tile.landfill.layer = 37
data.raw.tile.landfill.absorptions_per_second={
  pollution = 0.0,
  --pollen = 0.0 --?
}
data.raw.tile.landfill.variants.material_background = {
  picture = "__Alien-biomes-Reforged__/graphics/terrain/landfill.png",
  count = 8,
  scale = 0.5
}
data.raw.tile.landfill.transitions = transitions.cliff_transitions()
data.raw.tile.landfill.transitions_between_transitions = transitions.cliff_transitions_between_transitions()

for _, tile in pairs(data.raw.tile) do
  if not tile.absorptions_per_second then
    tile.absorptions_per_second = {}
  end
  if tile.name == "water" or tile.name == "deepwater" or tile.name == "water-shallow" or tile.name == "water-mud" then
    tile.absorptions_per_second = {
      pollution = 0.0000075,
      --pollen = 0.0000075, --?
    }
  elseif string.find(tile.name, "grass") or string.find(tile.name, "frozen") then
    tile.absorptions_per_second.pollution = math.min(tile.absorptions_per_second.pollution or 0.0000075, 0.0000075)
  elseif string.find(tile.name, "dirt") then
    tile.absorptions_per_second.pollution = math.min(tile.absorptions_per_second.pollution or 0.000005, 0.000005)
  else
    tile.absorptions_per_second.pollution = math.min(tile.absorptions_per_second.pollution or 0.0000025, 0.0000025)
  end
end

local function swap_tile_restriction(prototypes, old_name, new_name)
  for _, prototype in pairs(prototypes) do
    if prototype.autoplace and prototype.autoplace.tile_restriction then
      for _, restriction in pairs(prototype.autoplace.tile_restriction) do
        if restriction == old_name then
            prototype.autoplace.tile_restriction[_] = new_name
        end
      end
    end
  end
end


local function swap_tile_restrictions(old_name, new_name)

  -- decoratives on tiles
  swap_tile_restriction(data.raw["optimized-decorative"], old_name, new_name)

  -- simple-entities on tiles
  swap_tile_restriction(data.raw["simple-entity"], old_name, new_name)

  -- trees on tiles
  swap_tile_restriction(data.raw["tree"], old_name, new_name)

  if data.raw["plant"] then
    -- seeds on tiles
    swap_tile_restriction(data.raw["plant"], old_name, new_name)
  end

end

local function remove_from_transitions(remove_tile)
  for _, tile in pairs(data.raw.tile) do
    if tile.transitions then
      for _, transition in pairs(tile.transitions) do
        if transition.to_tiles then
          for _, to_tile in pairs(transition.to_tiles) do
            if to_tile == remove_tile then
              transition.to_tiles[_] = nil
            end
          end
        end
      end
    end
    if tile.next_direction == remove_tile then
      tile.next_direction = nil
    end
  end
end

local function remove_tile(tile_name)
  data.raw.tile[tile_name] = nil
  remove_from_transitions(tile_name)
  swap_tile_restrictions(tile_name, nil)

  for _, character in pairs(data.raw.character) do
    if character.footprint_particles then
      for i, particle in pairs(character.footprint_particles) do
        if particle.tiles and table_size(particle.tiles) > 0 then
          data_util.remove_from_table(particle.tiles, tile_name)
          if table_size(particle.tiles) == 0 then
            table.remove(character.footprint_particles, i)
          end
        end
      end
      if table_size(character.footprint_particles) == 0 then
        character.footprint_particles = nil
      end
    end

    if character.synced_footstep_particle_triggers then
      for i, particle in pairs(character.synced_footstep_particle_triggers) do
        if particle.tiles and table_size(particle.tiles) > 0 then
          data_util.remove_from_table(particle.tiles, tile_name)
          if table_size(particle.tiles) == 0 then
            table.remove(character.synced_footstep_particle_triggers, i)
          end
        end
      end
      if table_size(character.synced_footstep_particle_triggers) == 0 then
        character.synced_footstep_particle_triggers = nil
      end
    end
  end

  for _, car in pairs(data.raw.car) do
    if car.track_particle_triggers then
      for i, particle in pairs(car.track_particle_triggers) do
        if particle.tiles and table_size(particle.tiles) > 0 then
          data_util.remove_from_table(particle.tiles, tile_name)
          if table_size(particle.tiles) == 0 then
            table.remove(car.track_particle_triggers, i)
          end
        end
      end
      if table_size(car.track_particle_triggers) == 0 then
        car.track_particle_triggers = nil
      end
    end
  end

end

local function replace_tile_with_tile(old_name, new_name)

  if data.raw.tile[new_name] then
    -- items that place tiles
    for _, prototype in pairs(data.raw["item"]) do
      if prototype.place_as_tile and prototype.place_as_tile.result == old_name then
          prototype.place_as_tile.result = new_name
      end
    end

    remove_from_transitions(old_name)

    swap_tile_restrictions(old_name, new_name)
  end

end

-- make things use the alien biomes tile if possible.
for old_name, new_name in pairs(alien_biomes.tile_alias) do
  replace_tile_with_tile(old_name, new_name)
end


local function set_decals_to_layer(decal_layer)
  log("Setting decals to layer " .. decal_layer)
  for _, decal in pairs(data.raw['optimized-decorative']) do
    if decal.render_layer == "decals" and decal.tile_layer == default_decal_layer then
      decal.tile_layer = decal_layer
    end
  end
end

-- there are lots of terrain layers now
-- most constructed tiles / flooring do not expect that and have a layer that is too low
-- sort the layers
local function sort_tile_layers()
  -- See TileRenderLayer type;
  local tile_render_layers = {
    ["zero"] = {max_layers = 64, tile_count = 0, proto_defined_layers = {}, ab_chosen_layer = {},
      overrides = {
        ["out-of-map"] = 0,
        ["tile-unknown"] = 0,
        ["empty-space"] = 0,
      }
    },
    ["water"] = {max_layers = 16, tile_count = 0, proto_defined_layers = {}, ab_chosen_layer = {},
      overrides = {
        ["water"] = 3, --previously AB overrode this to 1
        ["water-green"] = 3, --previously AB overrode this to 1
        ["deepwater"] = 3, --previously AB overrode this to 2
        ["deepwater-green"] = 3, --previously AB overrode this to 2
        ["wetland-jellynut"] = 3,
        ["oil-ocean-deep"] = 3,
        ["ammoniacal-ocean"] = 3,
        ["ammoniacal-ocean-2"] = 3,
        ["lava-hot"] = 5,
      }
    },
    ["water-overlay"] = {max_layers = 64, tile_count = 0, proto_defined_layers = {}, ab_chosen_layer = {},
      overrides = {
        ["wetland-blue-slime"] = 1,
        ["gleba-deep-lake"] = 1,
        ["wetland-yumako"] = 3,
        ["wetland-pink-tentacle"] = 5,
        ["wetland-red-tentacle"] = 5,
        ["lava"] = 6,
        ["wetland-green-slime"] = 6,
        ["wetland-light-green-slime"] = 6,
        ["wetland-dead-skin"] = 7,
        ["wetland-light-dead-skin"] = 7,
        ["lowland-brown-blubber"] = 33,
        ["lowland-pale-green"] = 34,
        ["lowland-olive-blubber-2"] = 35,
        ["lowland-olive-blubber"] = 36,
        ["lowland-cream-cauliflower-2"] = 37,
        ["lowland-cream-cauliflower"] = 38,
        ["lowland-red-vein-dead"] = 39,
        ["lowland-olive-blubber-3"] = 40,
        ["lowland-cream-red"] = 43,
        ["lowland-red-vein-2"] = 44,
        ["lowland-red-vein"] = 45,
        ["lowland-red-vein-3"] = 46,
        ["lowland-red-vein-4"] = 47,
        ["lowland-red-infection"] = 48,
      }
    },
    ["ground-natural"] = {max_layers = 256, tile_count = 0, proto_defined_layers = {}, ab_chosen_layer = {},
      overrides = {
        ["water-wube"] = 2,
        ["oil-ocean-shallow"] = 4,
        ["fulgoran-paving"] = 5,
        ["fulgoran-dust"] = 6,
        ["fulgoran-dunes"] = 7,
        ["sand-1"] = 8,
        ["fulgoran-sand"] = 8,
        ["sand-2"] = 9,
        ["fulgoran-rock"] = 9,
        ["sand-3"] = 10,
        ["fulgoran-walls"] = 10,
        ["fulgoran-conduit"] = 11,
        ["fulgoran-machinery"] = 12,
        ["red-desert-1"] = 14,
        ["red-desert-2"] = 15,
        ["space-platform-foundation"] = 15,
        ["red-desert-3"] = 16,
        ["dry-dirt"] = 18,
        ["dirt-1"] = 19,
        ["dirt-2"] = 20,
        ["dirt-3"] = 21,
        ["dirt-4"] = 22,
        ["dirt-5"] = 23,
        ["dirt-6"] = 24,
        ["dirt-7"] = 25,
        ["grass-1"] = 26, --previously AB overrode this to either 4, 5 or 6
        ["grass-2"] = 28,
        ["grass-3"] = 29,
        ["grass-4"] = 30,
        ["red-desert-0"] = 31,
        ["nuclear-ground"] = 33,
        ["landfill"] = 37,
        ["volcanic-smooth-stone-warm"] = 40,
        ["volcanic-smooth-stone"] = 41,
        ["volcanic-cracks-hot"] = 42,
        ["volcanic-cracks-warm"] = 43,
        ["volcanic-cracks"] = 44,
        ["volcanic-jagged-ground"] = 45,
        ["volcanic-ash-cracks"] = 46,
        ["volcanic-soil-dark"] = 47,
        ["volcanic-soil-light"] = 48,
        ["volcanic-ash-soil"] = 51,
        ["ice-platform"] = 51,
        ["volcanic-ash-flats"] = 52,
        ["ice-smooth"] = 52,
        ["volcanic-ash-dark"] = 53,
        ["ice-rough"] = 53,
        ["volcanic-ash-light"] = 54,
        ["snow"] = 54,
        ["snow-flat"] = 54,
        ["volcanic-pumice-stones"] = 55,
        ["snow-2"] = 55,
        ["snow-crests"] = 55,
        ["volcanic-folds-flat"] = 56,
        ["snow-lumpy"] = 56,
        ["volcanic-folds-warm"] = 57,
        ["snow-patchy"] = 57,
        ["volcanic-folds"] = 58,
        ["pit-rock"] = 64,
        ["midland-cracked-lichen-dark"] = 65,
        ["midland-cracked-lichen"] = 73,
        ["midland-cracked-lichen-dull"] = 74,
        ["midland-turquoise-bark-2"] = 75,
        ["midland-turquoise-bark"] = 76,
        ["midland-yellow-crust-3"] = 77,
        ["midland-yellow-crust-2"] = 78,
        ["midland-yellow-crust"] = 79,
        ["midland-yellow-crust-4"] = 80,
        ["highland-dark-rock"] = 81,
        ["highland-dark-rock-2"] = 82,
        ["highland-yellow-rock"] = 83,
        ["natural-yumako-soil"] = 85,
        ["natural-jellynut-soil"] = 86,
        ["artificial-yumako-soil"] = 87,
        ["artificial-jellynut-soil"] = 88,
        ["overgrowth-yumako-soil"] = 89,
        ["overgrowth-jellynut-soil"] = 90,
      }
    },
    ["ground-artificial"] = {max_layers = 128, tile_count = 0, proto_defined_layers = {}, ab_chosen_layer = {},
      overrides = {
        ["tutorial-grid"] = 5,
        ["foundation"] = 9,
        ["stone-path"] = 11,
        ["concrete"] = 13,
        ["frozen-concrete"] = 14,
        ["hazard-concrete-left"] = 15,
        ["hazard-concrete-right"] = 15,
        ["frozen-hazard-concrete-left"] = 16,
        ["frozen-hazard-concrete-right"] = 16,
        ["refined-concrete"] = 17,
        ["frozen-refined-concrete"] = 18,
        ["refined-hazard-concrete-left"] = 19,
        ["refined-hazard-concrete-right"] = 19,
        ["frozen-refined-hazard-concrete-left"] = 20,
        ["frozen-refined-hazard-concrete-right"] = 20,
        ["lab-dark-1"] = 25,
        ["lab-dark-2"] = 25,
        ["red-refined-concrete"] = 28,
        ["green-refined-concrete"] = 29,
        ["blue-refined-concrete"] = 30,
        ["orange-refined-concrete"] = 31,
        ["yellow-refined-concrete"] = 32,
        ["pink-refined-concrete"] = 33,
        ["purple-refined-concrete"] = 34,
        ["black-refined-concrete"] = 35,
        ["brown-refined-concrete"] = 36,
        ["cyan-refined-concrete"] = 37,
        ["acid-refined-concrete"] = 38,
        ["lab-white"] = 70,
      }
    },
    ["top"] = {max_layers = 1, tile_count = 0, proto_defined_layers = {}, ab_chosen_layer = {},
      overrides = {        
      }
    },
  }

  for group, data in pairs(tile_render_layers) do
    local group_start_layer = 0
    for tile, layer_id in pairs(data.overrides) do
      group_start_layer = math.max(group_start_layer, layer_id)
    end
    data.next_layer = group_start_layer
  end

  local ab_by_name = alien_biomes.all_tiles()

  for _, tile in pairs(data.raw.tile) do
    local layer_group = tile.layer_group and tile.layer_group or "ground-natural"
    local layer = tile.layer and tile.layer or -1

    tile_render_layers[layer_group] = tile_render_layers[layer_group] and tile_render_layers[layer_group] or {tile_count = 0, proto_defined_layers = {}}
    tile_render_layers[layer_group].tile_count = tile_render_layers[layer_group].tile_count + 1
    tile_render_layers[layer_group].proto_defined_layers[layer] = tile_render_layers[layer_group].proto_defined_layers[layer] and tile_render_layers[layer_group].proto_defined_layers[layer] or {}

    local ab_layer = layer -- Ensure non-AB tiles without a layer defined don't crash _our_ code.
    if not tile_render_layers[layer_group].overrides[tile.name] then
      -- Let tiles that have layers defined retain them. But enforce the __base__ / __space-age__ tile definition layers as we might build off of them.
      if tile.layer then
        ab_layer = tile.layer
      -- AB tiles only get their layers defined here so they are in a defined order relative to each other, and above the __base__ / __space-age__ tiles.
      elseif ab_by_name[tile.name] then
        ab_layer = tile_render_layers[layer_group].next_layer
        tile_render_layers[layer_group].next_layer = ab_layer + 1
      end
    else
      ab_layer = tile_render_layers[layer_group].overrides[tile.name]
    end
    tile_render_layers[layer_group].ab_chosen_layer[ab_layer] = tile_render_layers[layer_group].ab_chosen_layer[ab_layer] and tile_render_layers[layer_group].ab_chosen_layer[ab_layer] or {}
    table.insert(tile_render_layers[layer_group].proto_defined_layers[layer], tile.name)
    table.insert(tile_render_layers[layer_group].ab_chosen_layer[ab_layer], tile.name)
    tile.layer = ab_layer

    --log("Added tile " .. tile.name .. " to group " .. layer_group .. " with layer " .. layer)
    --log(serpent.block(tile_render_layers[layer_group]))
  end

  -- set decals to final terrain layer
  set_decals_to_layer(tile_render_layers["ground-natural"].next_layer)
end
sort_tile_layers()

local function log_tiles()
  log("logging tile layers")
  local log_data = {}
  for _, tile in pairs(data.raw.tile) do
    log_data["layer " .. tile.layer] = log_data["layer " .. tile.layer] and log_data["layer " .. tile.layer] .. ", " .. tile.name or tile.name
  end
  log( serpent.block( log_data, {comment = false, numformat = '%1.8g' } ) )
end
--log_tiles()

local function tiles_enabled(tile_name)
  if data.raw.tile[tile_name] then
    return true
  else
    return false
  end
end

local function update_nauvis_autoplace()
  local nauvis = data.raw.planet.nauvis
  local nauvis_tile_settings
  if    nauvis
    and nauvis.map_gen_settings
    and nauvis.map_gen_settings.autoplace_settings
    and nauvis.map_gen_settings.autoplace_settings.tile
  then
    nauvis_tile_settings = nauvis.map_gen_settings.autoplace_settings.tile.settings
  end

  if nauvis_tile_settings then
    for old_name, new_name in pairs(alien_biomes.tile_alias) do
      if nauvis_tile_settings[old_name] and tiles_enabled(new_name) then
        nauvis_tile_settings[new_name] = nauvis_tile_settings[old_name]
        nauvis_tile_settings[old_name] = nil
      elseif nauvis_tile_settings[old_name] then
        nauvis_tile_settings[old_name] = nil
      end
    end
    for name, _tile in pairs(alien_biomes.all_tiles()) do
      if not nauvis_tile_settings[name] and data.raw.tile[name].autoplace ~= nil then
        nauvis_tile_settings[name] = {}
      end
    end
  end

  local nauvis_controls
  if nauvis and nauvis.map_gen_settings and nauvis.map_gen_settings then
    nauvis_controls = nauvis.map_gen_settings.autoplace_controls
  end
  if nauvis_controls then
    -- Add the hot and cold controls to nauvis
    nauvis_controls["cold"] = {}
    nauvis_controls["hot"] = {}
  end
end
update_nauvis_autoplace()

data.raw["utility-constants"].default.entity_renderer_search_box_limits.bottom = 6 -- reduce tall tree pop

--log( serpent.block( data.raw, {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw["tree"], {comment = false, numformat = '%1.8g' } ) )

--log( serpent.block( data.raw["noise-layer"], {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw, {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( alien_biomes.all_tiles(), {comment = false, numformat = '%1.8g' } ) )

--log( serpent.block( data.raw["simple-entity"], {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw["optimized-decorative"], {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw["optimized-decorative"]['cracked-mud-decal'], {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw["optimized-decorative"]['light-mud-decal'], {comment = false, numformat = '%1.8g' } ) )
--log( serpent.block( data.raw["optimized-decorative"]['stone-decal-tan'], {comment = false, numformat = '%1.8g' } ) )
