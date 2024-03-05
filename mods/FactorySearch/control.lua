util = require "__core__.lualib.util"
event = require "scripts.event"
CustomInput = require "scripts.custom-input"
Search = require "scripts.search"
SearchResults = require "scripts.search-results"
ResultLocation = require "scripts.result-location"
Gui = require "scripts.gui"

function filtered_surfaces(override_surface, player_surface)
  if override_surface then
    return {player_surface}
  end

  -- Skip certain modded surfaces that won't have assemblers/chests placed on them
  local surfaces = {}
  for _, surface in pairs(game.surfaces) do
    local surface_name = surface.name
    if string.sub(surface_name, -12) ~= "-transformer"  -- Power Overload
        and string.sub(surface_name, 1, 17) ~= "nullius-landfill-"  -- Nullius
        and string.sub(surface_name, 0, 8) ~= "starmap-"  -- Space Exploration
        and string.sub(surface_name, 0, 15) ~= "EE_TESTSURFACE_"  -- Editor Extensions
        and string.sub(surface_name, 0, 10) ~= "BPL_TheLab"  -- Blueprint Designer Lab
        and string.sub(surface_name, 0, 9) ~= "bpsb-lab-"  -- Blueprint Sandboxes
        and surface.name ~= "IR-limbo"  -- Industrial Revolution 2/3
        and surface_name ~= "aai-signals"  -- AAI Signals
        and surface_name ~= "secret_companion_surface_please_dont_touch"  -- Companion Drones
      then
      table.insert(surfaces, surface)
    end
  end
  return surfaces
end

local function update_surface_count()
  -- Hides 'All surfaces' button
  local multiple_surfaces = #filtered_surfaces() > 1

  if multiple_surfaces ~= global.multiple_surfaces then
    for _, player_data in pairs(global.players) do
      local all_surfaces = player_data.refs.all_surfaces
      all_surfaces.visible = multiple_surfaces
    end
  end

  global.multiple_surfaces = multiple_surfaces
end

script.on_event({defines.events.on_surface_created, defines.events.on_surface_deleted}, update_surface_count)

local function update_resource_names()
  local resources = game.get_filtered_entity_prototypes({{filter = "type", type = "resource"}})
  local item_to_resources = {}
  for _, resource in pairs(resources) do
    local properties = resource.mineable_properties
    if properties.minable and properties.products then
      for _, item in pairs(resource.mineable_properties.products) do
        local associated_resources = item_to_resources[item.name] or {}
        table.insert(associated_resources, resource.name)
        item_to_resources[item.name] = associated_resources
      end
    end
  end

  -- Hardcode some Pyanodons associations
  if game.active_mods["pypetroleumhandling"] then
    --  or {} in case something removed those items or playing an older version of Py
    table.insert(item_to_resources["raw-gas"] or {}, "bitumen-seep")
    table.insert(item_to_resources["tar"] or {}, "bitumen-seep")
    table.insert(item_to_resources["crude-oil"] or {}, "bitumen-seep")
  end

  global.items_from_resources = item_to_resources
end

script.on_init(
  function()
    global.players = {}
    global.current_searches = {}
    global.multiple_surfaces = false
    update_surface_count()
    update_resource_names()
  end
)

script.on_configuration_changed(
  function()
    -- Destroy all GUIs
    for player_index, player_data in pairs(global.players) do
      local player = game.get_player(player_index)
      if player then
        Gui.destroy(player, player_data)
      else
        global.players[player_index] = nil
      end
    end

    -- Stop in-progress non-blocking searches
    global.current_searches = {}

    global.multiple_surfaces = false
    update_surface_count()
    update_resource_names()
  end
)