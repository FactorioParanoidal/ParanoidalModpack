math2d = require "__core__.lualib.math2d"
search_signals = require "__FactorySearch__.scripts.search-signals"

local Search = {}

local default_surface_data = { consumers = {}, producers = {}, storage = {}, logistics = {}, modules = {}, requesters = {}, ground_items = {}, entities = {}, signals = {}, map_tags = {} }

local function extend(t1, t2)
  local t1_len = #t1
  local t2_len = #t2
  for i=1, t2_len do
    t1[t1_len + i] = t2[i]
  end
end

local function signal_eq(sig1, sig2)
  return sig1 and sig2 and sig1.type == sig2.type and sig1.name == sig2.name
end

-- Some entities are secretly swapped around by their mod. This allows all entities associated
-- with an item to be found by 'Entity' search
local mod_placeholder_entities = {
  ['sp-spidertron-dock'] =  -- SpidertronPatrols
    {'sp-spidertron-dock-0', 'sp-spidertron-dock-30', 'sp-spidertron-dock-80', 'sp-spidertron-dock-100'},

  ['po-interface'] =  -- PowerOverload
    {'po-interface', 'po-interface-north', 'po-interface-east', 'po-interface-south'},

  ['raw-rare-metals'] = 'rare-metals',  -- Krastorio2
  ['raw-imersite'] = 'imersite',  -- Krastorio2
  ['bitumen'] = 'bitumen-seep',  -- Pyanodons

  ['offshore-pump-0'] = 'offshore-pump-0',  -- P-U-M-P-S
  ['offshore-pump-1'] = 'offshore-pump-1',
  ['offshore-pump-2'] = 'offshore-pump-2',
  ['offshore-pump-3'] = 'offshore-pump-3',
  ['offshore-pump-4'] = 'offshore-pump-4',

  ['burner-offshore-pump'] = 'burner-offshore-pump',  -- BurnerOffshorePump
  ['electric-offshore-pump'] = 'electric-offshore-pump',
  ['se-core-fragment-omni'] = {'se-core-fragment-omni', 'se-core-fragment-omni-sealed'},
  ['se-core-fragment-iron-ore'] = {'se-core-fragment-iron-ore', 'se-core-fragment-iron-ore-sealed'},
  ['se-core-fragment-copper-ore'] = {'se-core-fragment-copper-ore', 'se-core-fragment-copper-ore-sealed'},
  ['se-core-fragment-coal'] = {'se-core-fragment-coal', 'se-core-fragment-coal-sealed'},
  ['se-core-fragment-stone'] = {'se-core-fragment-stone', 'se-core-fragment-stone-sealed'},
  ['se-core-fragment-uranium-ore'] = {'se-core-fragment-uranium-ore', 'se-core-fragment-uranium-ore-sealed'},
  ['se-core-fragment-crude-oil'] = {'se-core-fragment-crude-oil', 'se-core-fragment-crude-oil-sealed'},
  ['se-core-fragment-se-beryllium-ore'] = {'se-core-fragment-beryllium-ore', 'se-core-fragment-beryllium-ore-sealed'},
  ['se-core-fragment-se-cryonite'] = {'se-core-fragment-se-cryonite', 'se-core-fragment-se-cryonite-sealed'},
  ['se-core-fragment-se-holmium-ore'] = {'se-core-fragment-se-holmium-ore', 'se-core-fragment-se-holmium-ore-sealed'},
  ['se-core-fragment-se-iridium-ore'] = {'se-core-fragment-se-iridium-ore', 'se-core-fragment-se-iridium-ore-sealed'},
  ['se-core-fragment-se-vulcanite'] = {'se-core-fragment-se-vulcanite', 'se-core-fragment-se-vulcanite-sealed'},
  ['se-core-fragment-se-vitemelange'] = {'se-core-fragment-se-vitemelange', 'se-core-fragment-se-vitemelange-sealed'},
}

local list_to_map = util.list_to_map
local ingredient_entities = list_to_map{ "assembling-machine", "furnace", "mining-drill", "boiler", "burner-generator", "generator", "reactor", "inserter", "lab", "car", "spider-vehicle", "locomotive" }
local item_ammo_ingredient_entities = list_to_map{ "artillery-turret", "artillery-wagon", "ammo-turret" }  -- spider-vehicle, character
local fluid_ammo_ingredient_entities = list_to_map { "fluid-turret" }
local product_entities = list_to_map{ "assembling-machine", "furnace", "offshore-pump", "mining-drill" }  -- TODO add rocket-silo
local item_storage_entities = list_to_map{ "container", "logistic-container", "linked-container", "roboport", "character", "car", "artillery-wagon", "cargo-wagon", "spider-vehicle" }
local neutral_item_storage_entities = list_to_map{ "character-corpse" }  -- force = "neutral"
local fluid_storage_entities = list_to_map{ "storage-tank", "fluid-wagon" }
local modules_entities = list_to_map{ "assembling-machine", "furnace", "rocket-silo", "mining-drill", "lab", "beacon" }
local request_entities = list_to_map{ "logistic-container", "character", "spider-vehicle", "item-request-proxy" }
local item_logistic_entities = list_to_map{ "transport-belt", "splitter", "underground-belt", "loader", "loader-1x1", "inserter", "logistic-robot", "construction-robot" }
local fluid_logistic_entities = list_to_map{ "pipe", "pipe-to-ground", "pump" }
local ground_entities = list_to_map{ "item-entity" }  -- force = "neutral"
local signal_entities = list_to_map{ "roboport", "train-stop", "arithmetic-combinator", "decider-combinator", "constant-combinator", "accumulator", "rail-signal", "rail-chain-signal", "wall" }

local function add_entity_type(type_list, to_add_list)
  for name, _ in pairs(to_add_list) do
    type_list[name] = true
  end
end

local function map_to_list(map)
  local i = 1
  local list = {}
  for name, _ in pairs(map) do
    list[i] = name
    i = i + 1
  end
  return list
end

local function generate_distance_data(surface_data, player_position)
  local distance = math2d.position.distance
  for _, entity_groups in pairs(surface_data) do
    for _, groups in pairs(entity_groups) do
      for _, group in pairs(groups) do
        group.distance = distance(group.avg_position, player_position)
      end
      table.sort(groups, function (k1, k2) return k1.distance < k2.distance end)
    end
  end
end

function Search.process_found_entities(entities, state, surface_data, target_item)
  local target_name = target_item.name
  local target_type = target_item.type
  local target_is_item = target_type == "item"
  local target_is_fluid = target_type == "fluid"
  local target_is_virtual = target_type == "virtual"

  for _, entity in pairs(entities) do
    local entity_type = entity.type

    -- Signals
    if state.signals then
      if signal_entities[entity_type] then
        local control_behavior = entity.get_control_behavior()
        if control_behavior then
          if entity_type == "constant-combinator" then
            -- If prototype's `item_slot_count = 0` then .parameters will be nil
            for _, parameter in pairs(control_behavior.parameters or {}) do
              if signal_eq(parameter.signal, target_item) then
                SearchResults.add_entity_signal(entity, surface_data.signals, parameter.count)
              end
            end
          elseif entity_type == "arithmetic-combinator" or entity_type == "decider-combinator" then
            local signal_count = control_behavior.get_signal_last_tick(target_item)
            if signal_count ~= nil then
              SearchResults.add_entity_signal(entity, surface_data.signals, signal_count)
            end
          elseif entity_type == "roboport" then
            for _, signal in pairs({ control_behavior.available_logistic_output_signal, control_behavior.total_logistic_output_signal, control_behavior.available_construction_output_signal, control_behavior.total_construction_output_signal }) do
              if signal_eq(signal, target_item) then
                SearchResults.add_entity(entity, surface_data.signals)
                break
              end
            end
          elseif entity_type == "train-stop" then
            if signal_eq(control_behavior.stopped_train_signal, target_item) or signal_eq(control_behavior.trains_count_signal, target_item) then
              SearchResults.add_entity(entity, surface_data.signals)
            end
          elseif entity_type == "accumulator" or entity_type == "wall" then
            if signal_eq(control_behavior.output_signal, target_item) then
              SearchResults.add_entity(entity, surface_data.signals)
            end
          elseif entity_type == "rail-signal" then
            for _, signal in pairs({ control_behavior.red_signal, control_behavior.orange_signal, control_behavior.green_signal }) do
              if signal_eq(signal, target_item) then
                SearchResults.add_entity(entity, surface_data.signals)
                break
              end
            end
          elseif entity_type == "rail-chain-signal" then
            for _, signal in pairs({ control_behavior.red_signal, control_behavior.orange_signal, control_behavior.green_signal, control_behavior.blue_signal }) do
              if signal_eq(signal, target_item) then
                SearchResults.add_entity(entity, surface_data.signals)
                break
              end
            end
          end
        end
      end
    end
    if target_is_virtual then
      -- We've done all processing that there is to be done on virtual signals
      goto continue
    end

    -- Ingredients / Consumers
    if state.consumers then
      local recipe
      if entity_type == "assembling-machine" then
        recipe = entity.get_recipe()
      elseif entity_type == "furnace" then
        recipe = entity.get_recipe()
        if recipe == nil then
          -- Even if the furnace has stopped smelting, this records the last item it was smelting
          recipe = entity.previous_recipe
        end
      end
      if recipe then
        local ingredients = recipe.ingredients
        for _, ingredient in pairs(ingredients) do
          local name = ingredient.name
          if name == target_name then
            SearchResults.add_entity_product(entity, surface_data.consumers, recipe)
          end
        end
      end
      if target_is_item and entity_type == "lab" then
        local item_count = entity.get_item_count(target_name)
        if item_count > 0 then
          SearchResults.add_entity(entity, surface_data.consumers)
        end
      end
      if target_is_fluid and entity_type == "generator" then
        local fluid_count = entity.get_fluid_count(target_name)
        if fluid_count > 0 then
          SearchResults.add_entity(entity, surface_data.consumers)
        end
      end
      local burner = entity.burner
      if burner then
        local currently_burning = burner.currently_burning
        if currently_burning then
          if currently_burning.name == target_name then
            SearchResults.add_entity(entity, surface_data.consumers)
          end
        end
      end

      -- Consuming ammo
      if target_is_item and (entity_type == "artillery-turret" or entity_type == "artillery-wagon" or entity_type == "ammo-turret") then
        local item_count = entity.get_item_count(target_name)
        if item_count > 0 then
          SearchResults.add_entity_storage(entity, surface_data.consumers, item_count)
        end
      elseif target_is_fluid and entity_type == "fluid-turret" then
        local fluid_count = entity.get_fluid_count(target_name)
        if fluid_count > 0 then
          SearchResults.add_entity_storage_fluid(entity, surface_data.consumers, fluid_count)
        end
      end
    end

    -- Producers
    if state.producers then
      local recipe
      if entity_type == "assembling-machine" then
        recipe = entity.get_recipe()
      elseif entity_type == "furnace" then
        recipe = entity.get_recipe()
        if recipe == nil then
          -- Even if the furnace has stopped smelting, this records the last item it was smelting
          recipe = entity.previous_recipe
        end
      elseif entity_type == "mining-drill" then
        local mining_target = entity.mining_target
        if mining_target and mining_target.name == target_name then
          SearchResults.add_entity(entity, surface_data.producers)
        end
      elseif target_is_fluid and entity_type == "offshore-pump" then
        if entity.get_fluid_count(target_name) > 0 then
          SearchResults.add_entity(entity, surface_data.producers)
        end
      end
      if recipe then
        local products = recipe.products
        for _, product in pairs(products) do
          local name = product.name
          if name == target_name then
            SearchResults.add_entity_product(entity, surface_data.producers, recipe)
          end
        end
      end
    end

    -- Storage
    if state.storage then
      if target_is_fluid and (entity_type == "storage-tank" or entity_type == "fluid-wagon") then
        local fluid_count = entity.get_fluid_count(target_name)
        if fluid_count > 0 then
          SearchResults.add_entity_storage_fluid(entity, surface_data.storage, fluid_count)
        end
      elseif target_is_item and (entity_type == "character-corpse" or item_storage_entities[entity_type]) then
        -- Entity is an inventory entity
        local item_count = entity.get_item_count(target_name)
        if item_count > 0 then
          SearchResults.add_entity_storage(entity, surface_data.storage, item_count)
        end
      end
    end

    -- Modules
    if state.modules then
      if target_is_item and modules_entities[entity_type] then
        local inventory
        if entity_type == "beacon" then
          inventory = entity.get_inventory(defines.inventory.beacon_modules)
        elseif entity_type == "lab" then
          inventory = entity.get_inventory(defines.inventory.lab_modules)
        elseif entity_type == "mining-drill" then
          inventory = entity.get_inventory(defines.inventory.mining_drill_modules)
        elseif entity_type == "assembling-machine" or entity_type == "furnace" or entity_type == "rocket-silo" then
          inventory = entity.get_inventory(defines.inventory.assembling_machine_modules)
        end
        if inventory then
          local item_count = inventory.get_item_count(target_name)
          if item_count > 0 then
            SearchResults.add_entity_module(entity, surface_data.modules, item_count)
          end
        end
      end
    end

    -- Requesters
    if target_is_item and state.requesters then
      -- Buffer and Requester chests
      if entity_type == "logistic-container" then
        for i=1, entity.request_slot_count do
          local request = entity.get_request_slot(i)
          if request and request.name == target_name then
            local count = request.count
            if count then
              SearchResults.add_entity_request(entity, surface_data.requesters, count)
            end
          end
        end
      elseif entity_type == "character" then
        for i=1, entity.request_slot_count do
          local request = entity.get_personal_logistic_slot(i)
          if request and request.name == target_name then
            local count = request.min
            if count and count > 0 then
              SearchResults.add_entity_request(entity, surface_data.requesters, request.min)
            end
          end
        end
      elseif entity_type == "spider-vehicle" then
        for i=1, entity.request_slot_count do
          local request = entity.get_vehicle_logistic_slot(i)
          if request and request.name == target_name then
            local count = request.min
            if count and count > 0 then
              SearchResults.add_entity_request(entity, surface_data.requesters, request.min)
            end
          end
        end
      elseif entity_type == "item-request-proxy" then
        local request_count = entity.item_requests[target_name]
        if request_count ~= nil then
          SearchResults.add_entity_request(entity.proxy_target, surface_data.requesters, request_count)
        end
      end
    end

    -- Ground
    if target_is_item and state.ground_items then
      if entity_type == "item-entity" and entity.name == "item-on-ground" then
        if entity.stack.name == target_name then
          SearchResults.add_entity(entity, surface_data.ground_items)
        end
      end
    end

    -- Logistics
    if state.logistics then
      if item_logistic_entities[entity_type] then
        if entity_type == "inserter" then
          local held_stack = entity.held_stack
          if held_stack and held_stack.valid_for_read and held_stack.name == target_name then
            SearchResults.add_entity_storage(entity, surface_data.logistics, held_stack.count)
          end
        else
          local item_count = entity.get_item_count(target_name)
          if item_count > 0 then
            SearchResults.add_entity_storage(entity, surface_data.logistics, item_count)
          end
        end
      elseif fluid_logistic_entities[entity_type] then
        -- So target.type == "fluid"
        local fluid_count = entity.get_fluid_count(target_name)
        if fluid_count > 0 then
          SearchResults.add_entity_storage_fluid(entity, surface_data.logistics, fluid_count)
        end
      end
    end
    ::continue::
  end
end

function Search.blocking_search(force, state, target_item, surface_list, type_list, neutral_type_list, player)
  local target_name = target_item.name
  local target_type = target_item.type
  local target_is_item = target_type == "item"
  local target_is_fluid = target_type == "fluid"
  local target_is_virtual = target_type == "virtual"

  local data = {}

  for _, surface in pairs(surface_list) do
    local surface_data = table.deepcopy(default_surface_data)

    local entities = {}
    if next(type_list) then
      entities = surface.find_entities_filtered{
        type = type_list,
        force = force,
      }
    end

    -- Corpses and items on ground don't have a force: find seperately
    if next(neutral_type_list) then
      local neutral_entities = surface.find_entities_filtered{
        type = neutral_type_list,
      }
      extend(entities, neutral_entities)
    end

    Search.process_found_entities(entities, state, surface_data, target_item)

    -- Map tags
    if state.map_tags then
      local tags = force.find_chart_tags(surface.name)
      for _, tag in pairs(tags) do
        local tag_icon = tag.icon
        if tag_icon and tag_icon.type == target_type and tag_icon.name == target_name then
          SearchResults.add_tag(tag, surface_data.map_tags)
        end
      end
    end

    -- Entities
    if (target_is_item or target_is_fluid) and state.entities then
      local target_entity_name = mod_placeholder_entities[target_name]

      if not target_entity_name then
        local item_prototype = game.item_prototypes[target_name]
        target_entity_name = target_name
        if item_prototype and item_prototype.place_result then
          target_entity_name = item_prototype.place_result.name
        end
      end

      local entity_prototype = game.entity_prototypes[target_entity_name]
      local is_resource = false
      if entity_prototype and (entity_prototype.infinite_resource ~= nil) then
        is_resource = true
      end

      entities = surface.find_entities_filtered{
        name = target_entity_name,
        force = { force, "neutral" },
      }
      for _, entity in pairs(entities) do
        if is_resource then
          local amount
          if entity.initial_amount then
            amount = entity.amount / 3000  -- Calculate yield from amount
          else
            amount = entity.amount
          end
          SearchResults.add_entity_resource(entity, surface_data.entities, amount)
        else
          SearchResults.add_entity(entity, surface_data.entities)
        end
      end
    end
    if surface == player.surface then
      generate_distance_data(surface_data, player.position)
    end
    data[surface.name] = surface_data
  end
  return data
end

function Search.non_blocking_search(force, state, target_item, surface_list, type_list, neutral_type_list, player)
  search_data = {
    force = force,
    state = state,
    target_item = target_item,
    type_list = type_list,
    neutral_type_list = neutral_type_list,
    player = player,
    data = {},
    not_started_surfaces = surface_list,
    completed_surfaces = {}
  }

  global.current_searches[player.index] = search_data
end

function Search.on_tick()
  local player_index, search_data = next(global.current_searches)
  if not search_data then return end

  if search_data.search_complete then
    local player_data = global.players[player_index]
    local refs = player_data.refs
    Gui.build_results(search_data.data, refs.result_flow)
    global.current_searches[player_index] = nil
  end

  local current_surface = search_data.current_surface
  if not current_surface or not current_surface.valid then
    -- Start next surface
    current_surface = table.remove(search_data.not_started_surfaces)
    if not current_surface then
      -- All surfaces are complete
      local player = search_data.player
      local surface_data = search_data.data[player.surface.name]
      if surface_data then
        generate_distance_data(surface_data, player.position)
      end
      search_data.search_complete = true
      return
    end

    if not current_surface.valid then return end  -- Will try another surface next tick

    -- Setup next surface data
    search_data.current_surface = current_surface
    search_data.surface_data = table.deepcopy(default_surface_data)
    search_data.chunk_iterator = current_surface.get_chunks()

    -- Update results
    local player_data = global.players[player_index]
    local refs = player_data.refs
    Gui.build_results(search_data.data, refs.result_flow, false, true)
    Gui.add_loading_results(refs.result_flow)
    return  -- Start next surface processing on next tick
  end


  local chunk_iterator = search_data.chunk_iterator
  if not chunk_iterator.valid then
    search_data.current_surface = nil
    return
  end
  local chunks_processed = 0
  local chunks_per_tick = settings.global["fs-chunks-per-tick"].value
  while chunks_processed < chunks_per_tick do
    local chunk = chunk_iterator()
    if not chunk then
      -- Surface is complete
      search_data.data[current_surface.name] = search_data.surface_data
      search_data.current_surface = nil
      return
    end

    if current_surface.is_chunk_generated(chunk) then
      chunks_processed = chunks_processed + 1
    else
      goto continue
    end

    local target_item = search_data.target_item
    local target_name = target_item.name
    local target_type = target_item.type
    local target_is_item = target_type == "item"
    local target_is_fluid = target_type == "fluid"
    local target_is_virtual = target_type == "virtual"

    local state = search_data.state
    local surface_data = search_data.surface_data
    local force = search_data.force

    local chunk_area = chunk.area

    local entities = {}
    if next(search_data.type_list) then
      entities = current_surface.find_entities_filtered{
        area = chunk_area,
        type = search_data.type_list,
        force = force,
      }
    end

    -- Corpses and items on ground don't have a force: find seperately
    if next(search_data.neutral_type_list) then
      local neutral_entities = current_surface.find_entities_filtered{
        area = chunk_area,
        type = search_data.neutral_type_list,
      }
      extend(entities, neutral_entities)
    end

    Search.process_found_entities(entities, state, surface_data, target_item)

    -- Map tags
    if state.map_tags then
      local tags = force.find_chart_tags(current_surface.name, chunk_area)
      for _, tag in pairs(tags) do
        local tag_icon = tag.icon
        if tag_icon and tag_icon.type == target_type and tag_icon.name == target_name then
          SearchResults.add_tag(tag, surface_data.map_tags)
        end
      end
    end

    -- Entities
    if (target_is_item or target_is_fluid) and state.entities then
      local target_entity_name = mod_placeholder_entities[target_name]

      if not target_entity_name then
        local item_prototype = game.item_prototypes[target_name]
        target_entity_name = target_name
        if item_prototype and item_prototype.place_result then
          target_entity_name = item_prototype.place_result.name
        end
      end

      local entity_prototype = game.entity_prototypes[target_entity_name]
      local is_resource = false
      if entity_prototype and (entity_prototype.infinite_resource ~= nil) then
        is_resource = true
      end

      entities = current_surface.find_entities_filtered{
        area = chunk_area,
        name = target_entity_name,
        force = { force, "neutral" },
      }
      for _, entity in pairs(entities) do
        if is_resource then
          local amount
          if entity.initial_amount then
            amount = entity.amount / 3000  -- Calculate yield from amount
          else
            amount = entity.amount
          end
          SearchResults.add_entity_resource(entity, surface_data.entities, amount)
        else
          SearchResults.add_entity(entity, surface_data.entities)
        end
      end
    end
    ::continue::
  end

end
event.on_tick(Search.on_tick)

function Search.find_machines(target_item, force, state, player, override_surface)
  local data = {}
  local target_name = target_item.name
  if target_name == nil then
    -- 'Unknown signal selected'
    return data
  end
  local target_type = target_item.type
  local target_is_item = target_type == "item"
  local target_is_fluid = target_type == "fluid"
  local target_is_virtual = target_type == "virtual"

  local entity_types = {}
  local neutral_entity_types = {}
  if (target_is_item or target_is_fluid) and state.consumers then
    add_entity_type(entity_types, ingredient_entities)

    -- Only add turrets if target is ammo
    if target_is_item and game.get_filtered_item_prototypes({{filter = "type", type = "ammo"}})[target_name] then
      add_entity_type(entity_types, item_ammo_ingredient_entities)
    elseif target_is_fluid then
      add_entity_type(entity_types, fluid_ammo_ingredient_entities)
    end
  end
  if (target_is_item or target_is_fluid) and state.producers then
    add_entity_type(entity_types, product_entities)
  end
  if target_is_item and state.storage then
    add_entity_type(entity_types, item_storage_entities)
    add_entity_type(neutral_entity_types, neutral_item_storage_entities)
  end
  if target_is_fluid and state.storage then
    add_entity_type(entity_types, fluid_storage_entities)
  end
  if target_is_item and state.requesters then
    add_entity_type(entity_types, request_entities)
  end
  if target_is_item and state.modules then
    add_entity_type(entity_types, modules_entities)
  end
  if target_is_item and state.logistics then
    add_entity_type(entity_types, item_logistic_entities)
  end
  if target_is_fluid and state.logistics then
    add_entity_type(entity_types, fluid_logistic_entities)
  end
  if target_is_item and state.ground_items then
    add_entity_type(neutral_entity_types, ground_entities)
  end
  if state.signals then
    add_entity_type(entity_types, signal_entities)
  end
  local type_list = map_to_list(entity_types)
  local neutral_type_list = map_to_list(neutral_entity_types)

  local surface_list = filtered_surfaces(override_surface, player.surface)

  local non_blocking_search = settings.global["fs-non-blocking-search"].value
  if non_blocking_search == "on" or (non_blocking_search == "multiplayer" and game.is_multiplayer()) then
    -- Do non blocking search
    Search.non_blocking_search(force, state, target_item, surface_list, type_list, neutral_type_list, player)
    data = { non_blocking_search = true }
  else
    data = Search.blocking_search(force, state, target_item, surface_list, type_list, neutral_type_list, player)
  end

  return data
end

return Search