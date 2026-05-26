math2d = require "math2d"

local Search = {}

---@return SurfaceData
local function get_default_surface_data()
  return {
    consumers = {}, producers = {}, storage = {}, logistics = {}, modules = {}, requesters = {}, ground_items = {}, entities = {}, signals = {}, map_tags = {},
  }
end

local function extend(t1, t2)
  local t1_len = #t1
  local t2_len = #t2
  for i=1, t2_len do
    t1[t1_len + i] = t2[i]
  end
end

---@param sig1 SignalID
---@param sig2 SignalID
---@return boolean
local function signal_eq(sig1, sig2)
  if not (sig1 and sig2) then return false end
  if (sig1.type or "item") ~= (sig2.type or "item") then return false end
  if sig1.quality ~= "any" and sig2.quality ~= "any" and (sig1.quality or "normal") ~= (sig2.quality or "normal") then return false end
  return sig1.name == sig2.name
end

---@param target SignalID
---@param other {name: string, type: string?}
---@return boolean
local function target_eq(target, other)
  return target.name == other.name and (target.type or "item") == (other.type or "item")
end

local quality_names = {}
for name, _ in pairs(prototypes.quality) do
  table.insert(quality_names, name)
end

---@param inventory LuaInventory|LuaLogisticNetwork
---@param target_item_and_quality ItemIDAndQualityIDPair
---@return number
local function get_item_count(inventory, target_item_and_quality)
  if target_item_and_quality.quality == "any" then
    local count = 0
    for _, quality in pairs(quality_names) do
      count = count + inventory.get_item_count({name = target_item_and_quality.name, quality = quality})
    end
    return count
  else
    return inventory.get_item_count(target_item_and_quality)
  end
end

---@param control_behavior LuaCombinatorControlBehavior
---@param target_item SignalID
---@return number?
local function get_signal_last_tick(control_behavior, target_item)
  if target_item.quality == "any" then
    local count = 0
    for _, quality in pairs(quality_names) do
      count = count + (control_behavior.get_signal_last_tick({name = target_item.name, type = target_item.type, quality = quality}) or 0)
    end
    return count
  else
    return control_behavior.get_signal_last_tick(target_item)
  end
end

-- Mod-specific overrides for "Entity" search
local mod_placeholder_entities = {
  ['ff-ferrous-nodule'] = {'ff-seamount'},  -- Freight Forwarding
  ['ff-cupric-nodule'] = {'ff-seamount'},
  ['ff-cobalt-crust'] = {'ff-seamount'},

  ['ff-hot-titansteel-plate'] =  -- Freight Forwarding
    {'ff-lava-pool', 'ff-lava-pool-small'},

  ['se-core-fragment-omni'] = {'se-core-fragment-omni', 'se-core-fragment-omni-sealed'},  -- space-exploration
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
local ingredient_entities = list_to_map{ "assembling-machine", "furnace", "mining-drill", "boiler", "burner-generator", "generator", "fusion-reactor", "fusion-generator", "reactor", "inserter", "lab", "car", "spider-vehicle", "locomotive", "thruster" } -- TODO agricultural tower
local item_ammo_ingredient_entities = list_to_map{ "artillery-turret", "artillery-wagon", "ammo-turret" }  -- spider-vehicle, character
local fluid_ammo_ingredient_entities = list_to_map { "fluid-turret" }
local product_entities = list_to_map{ "assembling-machine", "furnace", "offshore-pump", "mining-drill", "fusion-generator" }  -- TODO add rocket-silo
local item_storage_entities = list_to_map{ "container", "logistic-container", "linked-container", "temporary-container", "roboport", "character", "car", "artillery-wagon", "cargo-wagon", "spider-vehicle", "cargo-landing-pad", "space-platform-hub" }
local neutral_item_storage_entities = list_to_map{ "character-corpse" }  -- force = "neutral"
local fluid_storage_entities = list_to_map{ "storage-tank", "fluid-wagon" }
local modules_entities = list_to_map{ "assembling-machine", "furnace", "rocket-silo", "mining-drill", "lab", "beacon" }
local request_entities = list_to_map{ "logistic-container", "character", "spider-vehicle", "roboport", "space-platform-hub", "cargo-landing-pad", "item-request-proxy" }
local item_logistic_entities = list_to_map{ "transport-belt", "splitter", "underground-belt", "linked-belt", "lane-splitter", "loader", "loader-1x1", "inserter", "logistic-robot", "construction-robot" }
local fluid_logistic_entities = list_to_map{ "pipe", "pipe-to-ground", "pump", "valve" }
local ground_entities = list_to_map{ "item-entity" }  -- force = "neutral"
local signal_entities = list_to_map{ "assembling-machine", "furnace", "roboport", "train-stop", "arithmetic-combinator", "decider-combinator", "selector-combinator", "constant-combinator", "accumulator", "rail-signal", "rail-chain-signal", "wall", "container", "logistic-container", "inserter", "storage-tank", "mining-drill" }

local function add_entity_type(type_list, to_add_list)
  for name, _ in pairs(to_add_list) do
    type_list[name] = true
  end
end

---@param surface_data SurfaceData
---@param player_position MapPosition
local function generate_distance_data(surface_data, player_position)
  local distance = math2d.position.distance
  for _, groups in pairs(surface_data) do
    for _, group in pairs(groups) do
      group.distance = distance(group.avg_position, player_position)
    end
  end
end

local function to_chunk_position(map_position)
  return { math.floor(map_position.x / 32), math.floor(map_position.y / 32) }
end

---@param entity LuaEntity
---@param entity_type string
---@return boolean
local function is_wire_connected(entity, entity_type)
  if entity_type == "arithmetic-combinator" or entity_type == "decider-combinator" then
    return not not (entity.get_circuit_network(defines.wire_connector_id.combinator_output_red) or entity.get_circuit_network(defines.wire_connector_id.combinator_output_green))
  else
    return not not (entity.get_circuit_network(defines.wire_connector_id.circuit_red) or entity.get_circuit_network(defines.wire_connector_id.circuit_green))
  end
end

---@param entities LuaEntity[]
---@param state SearchGuiState
---@param surface_data SurfaceData
---@param surface_statistics SurfaceStatistics
---@param target_item SignalID
---@param force? LuaForce
function Search.process_found_entities(entities, state, surface_data, surface_statistics, target_item, force)
  -- Not used for Entity and Tag search modes
  -- Only provide `force` if you want to filter out uncharted entities
  local target_name = target_item.name  ---@cast target_name -?
  local target_type = target_item.type or "item"
  local target_is_item = target_type == "item"
  local target_is_fluid = target_type == "fluid"
  local target_is_virtual = not target_is_item and not target_is_fluid  -- Includes all other SignalIDType, e.g "virtual", "entity"

  local target_quality = target_item.quality --[[@as string]] or "normal"
  local target_quality_is_any = target_quality == "any"

  ---@type ItemFilter
  local target_item_filter = {name = target_name, quality = target_quality}
  if target_quality_is_any then
    target_item_filter.quality = "normal"
    target_item_filter.comparator = "≥"
  end
  ---@type ItemIDAndQualityIDPair
  local target_item_and_quality = {name = target_name, quality = target_quality}

  for _, entity in pairs(entities) do
    if force and not force.is_chunk_charted(entity.surface, to_chunk_position(entity.position)) then
      goto continue
    end

    local entity_type = entity.type

    -- Signals
    if state.signals then
      if signal_entities[entity_type] then
        local control_behavior = entity.get_control_behavior()
        if control_behavior then
          ---@type SignalID[]
          local signals = {}
          if entity_type == "accumulator" then
            ---@cast control_behavior LuaAccumulatorControlBehavior
            if control_behavior.read_charge then
              table.insert(signals, control_behavior.output_signal)
            end
          elseif entity_type == "assembling-machine" or entity_type == "furnace" then
            ---@cast control_behavior LuaAssemblingMachineControlBehavior
            if control_behavior.circuit_read_recipe_finished then
              table.insert(signals, control_behavior.circuit_recipe_finished_signal)
            end
            if control_behavior.circuit_read_working then
              table.insert(signals, control_behavior.circuit_working_signal)
            end
          elseif entity_type == "rail-signal" then  -- and control_behavior.read_signal -- TODO check
            ---@cast control_behavior LuaRailSignalBaseControlBehavior
            if control_behavior.read_signal then
              table.insert(signals, control_behavior.red_signal)
              table.insert(signals, control_behavior.orange_signal)
              table.insert(signals, control_behavior.green_signal)
            end
          elseif entity_type == "rail-chain-signal" then
            ---@cast control_behavior LuaRailSignalBaseControlBehavior
            if control_behavior.read_signal then
              table.insert(signals, control_behavior.red_signal)
              table.insert(signals, control_behavior.orange_signal)
              table.insert(signals, control_behavior.blue_signal)
              table.insert(signals, control_behavior.green_signal)
            end
          elseif entity_type == "reactor" then
            ---@cast control_behavior LuaReactorControlBehavior
            if control_behavior.read_temperature then
              table.insert(signals, control_behavior.temperature_signal)
            end
          elseif entity_type == "roboport" then
            ---@cast control_behavior LuaRoboportControlBehavior
            if control_behavior.read_robot_stats then
              table.insert(signals, control_behavior.available_logistic_output_signal)
              table.insert(signals, control_behavior.total_logistic_output_signal)
              table.insert(signals, control_behavior.available_construction_output_signal)
              table.insert(signals, control_behavior.total_construction_output_signal)
              table.insert(signals, control_behavior.roboport_count_output_signal)
            end
          elseif entity_type == "space-platform" then
            ---@cast control_behavior LuaSpacePlatformHubControlBehavior
            if control_behavior.read_speed then
              table.insert(signals, control_behavior.speed_signal)
            end
            if control_behavior.read_damage_taken then
              table.insert(signals, control_behavior.damage_taken_signal)
            end
          elseif entity_type == "train-stop" then
            ---@cast control_behavior LuaTrainStopControlBehavior
            if control_behavior.read_stopped_train then
              table.insert(signals, control_behavior.stopped_train_signal)
            end
            if control_behavior.read_trains_count then
              table.insert(signals, control_behavior.trains_count_signal)
            end
          elseif entity_type == "wall" then
            ---@cast control_behavior LuaWallControlBehavior
            if control_behavior.read_sensor then
              table.insert(signals, control_behavior.output_signal)
            end
          end

          for _, signal in ipairs(signals) do
            if signal_eq(target_item, signal) then
              SearchResults.add_entity(entity, surface_data.signals)
              SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
              break
            end
          end

          if entity_type == "assembling-machine" or entity_type == "furnace" then
            -- to avoid duplicate when both circuit_read_contents and circuit_read_ingredients are enabled
            local added_signals = {}

            if control_behavior.circuit_read_contents then
              -- TODO support "Include in crafting" and "Include fuel"
              local signal_count = 0
              if target_is_item then
                signal_count = entity.get_item_count(target_item_filter)
              elseif target_is_fluid then
                signal_count = entity.get_fluid_count(target_name)
              end
              if signal_count > 0 then
                SearchResults.add_entity(entity, surface_data.signals)
                SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
                added_signals[target_type..'/'..target_name] = true
              end
            end
            if control_behavior.circuit_read_ingredients then
              local inventory = entity.get_inventory(defines.inventory.assembling_machine_input)
              if inventory then
                local signal_count = 0
                if target_is_item then
                  signal_count = get_item_count(inventory, target_item_and_quality)
                elseif target_is_fluid then
                  signal_count = entity.get_fluid_count(target_name)  -- Not strictly speaking accurate since checks entire entity, not just input inventory
                end
                if signal_count > 0 and not added_signals[target_type..'/'..target_name] then
                  SearchResults.add_entity(entity, surface_data.signals)
                  SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
                end
              end
            end
          elseif entity_type == "constant-combinator" then
            ---@cast control_behavior LuaConstantCombinatorControlBehavior
            for _, section in ipairs(control_behavior.sections) do
              for _, filter in ipairs(section.filters) do
                local signal = filter.value  --[[@as SignalID]]
                if signal_eq(target_item, signal) then
                  SearchResults.add_entity(entity, surface_data.signals)
                  SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
                  goto break_both
                end
              end
            end
            ::break_both::
          elseif entity_type == "arithmetic-combinator" or entity_type == "decider-combinator" or entity_type == "selector-combinator" then
            ---@cast control_behavior LuaCombinatorControlBehavior
            local signal_count = get_signal_last_tick(control_behavior, target_item)
            if signal_count and signal_count ~= 0 then
              SearchResults.add_entity(entity, surface_data.signals)
              SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
            end
          elseif entity_type == "reactor" and target_is_item then  -- TODO reactors can also burn fluids
            if control_behavior.read_fuel then
              local signal_count = get_item_count(entity.burner.inventory, target_item_and_quality)
              if signal_count > 0 then
                SearchResults.add_entity(entity, surface_data.signals)
                SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
              else
                local currently_burning = entity.burner.currently_burning
                if currently_burning and target_name == currently_burning.name.name and (target_quality_is_any or target_quality == currently_burning.quality.name) then
                  SearchResults.add_entity(entity, surface_data.signals)
                  SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
                end
              end
            end
          elseif entity_type == "roboport" and target_is_item then
            if control_behavior.read_items_mode == defines.control_behavior.roboport.read_items_mode.logistics and is_wire_connected(entity, entity_type) then
              local logistic_network = entity.logistic_network
              if logistic_network then
                local signal_count = get_item_count(logistic_network, target_item_and_quality)
                if signal_count > 0 then
                  SearchResults.add_entity(entity, surface_data.signals)
                  SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
                end
              end
            elseif control_behavior.read_items_mode == defines.control_behavior.roboport.read_items_mode.missing_requests then
              -- TODO not possible right now
            end
          elseif entity_type == "space-platform-hub" and target_is_item then
            if control_behavior.read_contents then
              local signal_count = entity.get_item_count(target_item_filter)
              if signal_count > 0 then
                SearchResults.add_entity(entity, surface_data.signals)
                SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
              end
            elseif control_behavior.read_moving_from then
              -- TODO would be really hacky to get
            elseif control_behavior.read_moving_to then
              -- TODO would be really hacky to get
            end
          elseif entity_type == "train-stop" then
            if control_behavior.read_from_train then
              local train = entity.get_stopped_train()
              if train then
                if target_is_item then
                  local signal_count = train.get_item_count(target_item_filter)
                  if signal_count > 0 then
                    SearchResults.add_entity(entity, surface_data.signals)
                    SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
                  end
                elseif target_is_fluid then
                  local signal_count = train.get_fluid_count(target_name)
                  if signal_count > 0 then
                    SearchResults.add_entity(entity, surface_data.signals)
                    SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
                  end
                end
              end
            end
          elseif entity_type == "container" and target_is_item then
            if control_behavior.read_contents then
              local signal_count = entity.get_item_count(target_item_filter)
              if signal_count > 0 then
                SearchResults.add_entity(entity, surface_data.signals)
                SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
              end
            end
          elseif entity_type == "logistic-container" and target_is_item then
            ---@cast control_behavior LuaLogisticContainerControlBehavior
            if control_behavior.circuit_exclusive_mode_of_operation == defines.control_behavior.logistic_container.exclusive_mode.send_contents then
              local signal_count = entity.get_item_count(target_item_filter)
              if signal_count > 0 then
                SearchResults.add_entity(entity, surface_data.signals)
                SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
              end
            end
          elseif entity_type == "inserter" and target_is_item then
            ---@cast control_behavior LuaInserterControlBehavior
            -- Doesn't check inserter if in pulse mode
            if control_behavior.circuit_read_hand_contents and control_behavior.circuit_hand_read_mode == defines.control_behavior.inserter.hand_read_mode.hold then
              local held_stack = entity.held_stack
              if held_stack and held_stack.valid_for_read and held_stack.name == target_name and (target_quality_is_any or held_stack.quality.name == target_quality) then
                SearchResults.add_entity(entity, surface_data.signals)
                SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
              end
            end
          elseif entity_type == "storage-tank" and target_is_fluid then
            if control_behavior.read_contents then
              local signal_count = entity.get_fluid_count(target_name)
              if signal_count > 0 then
                SearchResults.add_entity(entity, surface_data.signals)
                SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
              end
            end
          elseif entity_type == "mining-drill" then
            ---@cast control_behavior LuaMiningDrillControlBehavior
            if control_behavior.circuit_read_resources then
              local resources = control_behavior.resource_read_targets
              local count = 0
              for _, resource in pairs(resources) do
                if resource.name == target_name then
                  if resource.initial_amount then
                    count = count + (resource.amount / 30000)  -- Calculate fluid/s from amount
                  else
                    count = count + resource.amount
                  end
                end
              end
              if count > 0 then
                SearchResults.add_entity(entity, surface_data.signals)
                SearchResults.add_surface_statistics("signal_count", 1, surface_statistics)
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
      ---@type LuaRecipe|LuaRecipePrototype?
      local recipe
      ---@type LuaQualityPrototype?
      local quality_prototype
      if entity_type == "assembling-machine" then
        recipe, quality_prototype = entity.get_recipe()
      elseif entity_type == "furnace" then
        -- Even if the furnace has stopped smelting, this records the last item it was smelting
        recipe, quality_prototype = entity.get_recipe()
        if not recipe then
          local recipe_and_quality = entity.previous_recipe
          if recipe_and_quality then
            recipe = recipe_and_quality.name  --[[@as LuaRecipePrototype]]
            quality_prototype = recipe_and_quality.quality  --[[@as LuaQualityPrototype]]
          end
        end
      end

      if recipe and recipe.ingredients and quality_prototype then
        local quality = quality_prototype.name
        for _, ingredient in pairs(recipe.ingredients) do
          if target_eq(target_item, ingredient) and (target_quality_is_any or target_quality == quality) then
            SearchResults.add_entity_product(entity, surface_data.consumers, recipe)
            SearchResults.add_surface_statistics("consumers_count", 1, surface_statistics)
            break
          end
        end
      elseif target_is_item and entity_type == "lab" then
        local item_count = entity.get_item_count(target_item_filter)
        if item_count > 0 then
          SearchResults.add_entity(entity, surface_data.consumers)
          SearchResults.add_surface_statistics("consumers_count", 1, surface_statistics)
        end
      elseif target_is_fluid then
        if entity_type == "generator" or entity_type == "thruster" then
          local fluid_count = entity.get_fluid_count(target_name)
          if fluid_count > 0 then
            SearchResults.add_entity(entity, surface_data.consumers)
            SearchResults.add_surface_statistics("consumers_count", 1, surface_statistics)
          end
        else
          local input_fluidbox = entity.prototype.fluidbox_prototypes[1]  -- TODO check assumption
          if input_fluidbox and input_fluidbox.filter and input_fluidbox.filter.name == target_name then
            SearchResults.add_entity(entity, surface_data.consumers)
            SearchResults.add_surface_statistics("consumers_count", 1, surface_statistics)
          end
        end
      end

      local burner = entity.burner
      if burner then
        local currently_burning = burner.currently_burning
        if currently_burning and target_name == currently_burning.name.name and (target_quality_is_any or target_quality == currently_burning.quality.name) then
          SearchResults.add_entity(entity, surface_data.consumers)
          SearchResults.add_surface_statistics("consumers_count", 1, surface_statistics)
        end
      end

      -- Consuming ammo
      if target_is_item and (entity_type == "artillery-turret" or entity_type == "artillery-wagon" or entity_type == "ammo-turret") then
        local item_count = entity.get_item_count(target_item_filter)
        if item_count > 0 then
          SearchResults.add_entity(entity, surface_data.consumers)
          SearchResults.add_surface_statistics("consumers_count", 1, surface_statistics)
        end
      elseif target_is_fluid and entity_type == "fluid-turret" then
        local fluid_count = entity.get_fluid_count(target_name)
        if fluid_count > 0 then
          SearchResults.add_entity(entity, surface_data.consumers)
          SearchResults.add_surface_statistics("consumers_count", 1, surface_statistics)
        end
      end
    end

    -- Producers
    if state.producers then
      ---@type LuaRecipe|LuaRecipePrototype?
      local recipe
      ---@type LuaQualityPrototype?
      local quality_prototype
      if entity_type == "assembling-machine" then
        recipe, quality_prototype = entity.get_recipe()
      elseif entity_type == "furnace" then
        -- Even if the furnace has stopped smelting, this records the last item it was smelting
        recipe, quality_prototype = entity.get_recipe()
        if not recipe then
          local recipe_and_quality = entity.previous_recipe
          if recipe_and_quality then
            recipe = recipe_and_quality.name  --[[@as LuaRecipePrototype]]
            quality_prototype = recipe_and_quality.quality  --[[@as LuaQualityPrototype]]
          end
        end
      end

      if recipe and recipe.products and quality_prototype then
        local quality = quality_prototype.name
        for _, product in pairs(recipe.products) do
          if target_eq(target_item, product) and (target_quality_is_any or target_quality == quality) then
            SearchResults.add_entity_product(entity, surface_data.producers, recipe)
            SearchResults.add_surface_statistics("producers_count", 1, surface_statistics)
            break
          end
        end
      elseif entity_type == "mining-drill" then
        local mining_target = entity.mining_target
        if mining_target then
          local mineable_properties = mining_target.prototype.mineable_properties
          local quality = mining_target.quality.name
          for _, product in pairs(mineable_properties.products or {}) do
            if target_name == product.name and (target_quality_is_any or target_quality == quality) then
              SearchResults.add_entity(entity, surface_data.producers)
              SearchResults.add_surface_statistics("producers_count", 1, surface_statistics)
              break
            end
          end
        end
      elseif target_is_fluid and entity_type == "offshore-pump" then
        if entity.get_fluid_count(target_name) > 0 then
          SearchResults.add_entity(entity, surface_data.producers)
          SearchResults.add_surface_statistics("producers_count", 1, surface_statistics)
        end
      elseif target_is_fluid and (entity_type == "fusion-generator") then
        local prototype = entity.prototype
        local fluidboxes = prototype.fluidbox_prototypes
        local output = fluidboxes[2]  -- TODO check assumption
        if output.filter.name == target_name then
          SearchResults.add_entity(entity, surface_data.producers)
          SearchResults.add_surface_statistics("producers_count", 1, surface_statistics)
        end
      end
    end

    -- Storage
    if state.storage then
      if target_is_fluid and (entity_type == "storage-tank" or entity_type == "fluid-wagon") then
        local fluid_count = entity.get_fluid_count(target_name)
        if fluid_count > 0 then
          SearchResults.add_entity_storage_fluid(entity, surface_data.storage, fluid_count)
          SearchResults.add_surface_statistics("fluid_count", fluid_count, surface_statistics)
        end
      elseif target_is_item and (entity_type == "character-corpse" or item_storage_entities[entity_type]) then
        -- Entity is an inventory entity
        local item_count = entity.get_item_count(target_item_filter)
        if item_count > 0 then
          SearchResults.add_entity_storage(entity, surface_data.storage, item_count)
          SearchResults.add_surface_statistics("item_count", item_count, surface_statistics)
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
          local item_count = get_item_count(inventory, target_item_and_quality)
          if item_count > 0 then
            SearchResults.add_entity_module(entity, surface_data.modules, item_count)
            SearchResults.add_surface_statistics("module_count", item_count, surface_statistics)
          end
        end
      end
    end

    -- Requesters
    if target_is_item and state.requesters then
      -- Buffer and Requester chests, character, and spidertron
      if entity_type == "logistic-container" or entity_type == "character" or entity_type == "spider-vehicle" then
        local logistic_points = entity.get_logistic_point() --[=[@as LuaLogisticPoint[]]=]
        for _, logistic_point in pairs(logistic_points) do
          for _, filter in pairs(logistic_point.filters or {}) do
            if filter and filter.name == target_name and (target_quality_is_any or filter.quality == target_quality) then  -- TODO take into account filter.comparator for quality
              SearchResults.add_entity_request(entity, surface_data.requesters, filter.count)
              SearchResults.add_surface_statistics("request_count", filter.count, surface_statistics)
            end
          end
        end
      elseif entity_type == "item-request-proxy" then
        local requests = entity.item_requests
        for _, item in pairs(requests) do
          if item.name == target_name and (target_quality_is_any or item.quality == target_quality) then
            SearchResults.add_entity_request(entity.proxy_target, surface_data.requesters, item.count)
            SearchResults.add_surface_statistics("request_count", item.count, surface_statistics)
          end
        end
      end
    end

    -- Ground
    if target_is_item and state.ground_items then
      if entity_type == "item-entity" and entity.name == "item-on-ground" then
        if entity.stack.name == target_name and (target_quality_is_any or entity.stack.quality.name == target_quality) then
          SearchResults.add_entity(entity, surface_data.ground_items)
          SearchResults.add_surface_statistics("ground_count", 1, surface_statistics)
        end
      end
    end

    -- Logistics
    if state.logistics then
      if item_logistic_entities[entity_type] then
        if entity_type == "inserter" then
          local held_stack = entity.held_stack
          if held_stack and held_stack.valid_for_read and held_stack.name == target_name and (target_quality_is_any or held_stack.quality.name == target_quality) then
            SearchResults.add_entity_storage(entity, surface_data.logistics, held_stack.count)
            SearchResults.add_surface_statistics("item_count", held_stack.count, surface_statistics)
          end
        else
          local item_count = entity.get_item_count(target_item_filter)
          if item_count > 0 then
            SearchResults.add_entity_storage(entity, surface_data.logistics, item_count)
            SearchResults.add_surface_statistics("item_count", item_count, surface_statistics)
          end
        end
      elseif fluid_logistic_entities[entity_type] then
        -- So target.type == "fluid"
        local fluid_count = entity.get_fluid_count(target_name)
        if fluid_count > 0 then
          SearchResults.add_entity_storage_fluid(entity, surface_data.logistics, fluid_count)
          SearchResults.add_surface_statistics("fluid_count", fluid_count, surface_statistics)
        end
      end
    end
    ::continue::
  end
end

---@param target_item SignalID
---@return EntityName[]?
local function get_target_entity_names(target_item)
  local target_name = target_item.name

  if target_item.type == "entity" then
    return {target_name}
  end

  -- Check hardcoded mod overrides
  if mod_placeholder_entities[target_name] then
    return mod_placeholder_entities[target_name]
  end

  -- Get all associated items from entity.items_to_place_this,
  -- entity.mineable_properties, item.place_result, item.plant_result
  if storage.item_to_entities[target_name] then
    return storage.item_to_entities[target_name]
  end

  -- Or just try an entity with the same name as the item
  if prototypes.entity[target_name] then
    return {target_name}
  end
end

--- @type table<SurfaceDataCategoryName, string[]>
local sort_categories_by = {
  consumers = {"count"},
  producers = {"count"},
  storage = {"item_count", "fluid_count"},
  logistics = {"item_count", "fluid_count"},
  modules = {"module_count"},
  requesters = {"request_count"},
  ground_items = {"count"},
  entities = {"resource_count", "count"},
  signals = {"count"}
}

---@param surface_data SurfaceData
---@param player LuaPlayer
local function sort_surface_data(surface_data, player)
  for category, groups in pairs(surface_data) do
    local player_data = storage.players[player.index]
    local sort_by = player_data.sort_results_by
    if sort_by == "distance" then
      table.sort(groups, function (k1, k2) return (k1.distance or math.huge) < (k2.distance or math.huge) end)
    elseif sort_by == "name" then
      table.sort(groups, function (k1, k2) return k1.entity_name < k2.entity_name end)
    elseif sort_by == "count" and sort_categories_by[category] then
      table.sort(groups, function (k1, k2)
        for _, property_name in ipairs(sort_categories_by[category]) do
          if k1[property_name] ~= nil and k2[property_name] ~= nil then
            return k1[property_name] > k2[property_name]
          end
        end
        return false
      end)
    end
  end
end

---@param force LuaForce
---@param state SearchGuiState
---@param target_item SignalID
---@param surface_list LuaSurface[]
---@param type_list string[]
---@param neutral_type_list string[]
---@param player LuaPlayer
function Search.blocking_search(force, state, target_item, surface_list, type_list, neutral_type_list, player)
  local target_name = target_item.name
  local target_type = target_item.type or "item"
  local target_is_item = target_type == "item"
  local target_is_fluid = target_type == "fluid"
  local target_is_virtual = target_type == "virtual"
  local target_is_entity = target_type == "entity"
  local target_quality = target_item.quality --[[@as string]] or "normal"

  local data = {}
  local statistics = {}

  for _, surface in pairs(surface_list) do
    if not surface.valid then goto continue end
    local surface_data = get_default_surface_data()
    ---@type SurfaceStatistics
    local surface_statistics = {}

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

    Search.process_found_entities(entities, state, surface_data, surface_statistics, target_item, force)

    -- Map tags
    if state.map_tags then
      local tags = force.find_chart_tags(surface.name)
      for _, tag in pairs(tags) do
        local tag_icon = tag.icon
        if tag_icon and signal_eq(target_item, tag_icon) then
          SearchResults.add_tag(tag, surface_data.map_tags)
          SearchResults.add_surface_statistics("tag_count", 1, surface_statistics)
        end
      end
    end

    -- Entities
    if state.entities then
      local target_entity_names = get_target_entity_names(target_item)
      if target_entity_names then
        entities = surface.find_entities_filtered{
          name = target_entity_names,
          quality = target_quality ~= "any" and target_quality or nil,
          force = { force, "neutral" },
        }
        for _, entity in pairs(entities) do
          if entity.type == "resource" then
            local amount = SearchResults.add_entity_resource(entity, surface_data.entities)
            SearchResults.add_surface_statistics("resource_count", amount, surface_statistics)
          else
            SearchResults.add_entity(entity, surface_data.entities)
            SearchResults.add_surface_statistics("entity_count", 1, surface_statistics)
          end
        end
      end
    end

    if surface == player.surface then
      generate_distance_data(surface_data, player.physical_position)
    end
    sort_surface_data(surface_data, player)
    data[surface.name] = surface_data
    statistics[surface.name] = surface_statistics
    ::continue::
  end

  local player_data = storage.players[player.index]
  local refs = player_data.refs
  SearchGui.build_results(data, statistics, refs.result_flow)
  SearchGui.hide_search_progress(refs)
  refs.sort_results_dropdown.enabled = true
  storage.current_searches[player.index] = nil
end

function on_tick()
  local player_index, search_data = next(storage.current_searches)
  if not player_index or not search_data then return end

  -- First, check to see if we can trigger a blocking search
  if search_data.blocking then
    if search_data.tick_triggered + DEBOUNCE_TICKS < game.tick then
      -- TODO Check player is still online?
      Search.blocking_search(search_data.force, search_data.state, search_data.target_item, search_data.not_started_surfaces, search_data.type_list, search_data.neutral_type_list, search_data.player)
    end
    return
  end

  if search_data.search_complete then
    local player_data = storage.players[player_index]
    local refs = player_data.refs
    SearchGui.build_results(search_data.data, search_data.statistics, refs.result_flow)
    SearchGui.hide_search_progress(refs)
    refs.sort_results_dropdown.enabled = true
    storage.current_searches[player_index] = nil
  end

  local current_surface_search_data = search_data.current_surface_search_data
  if not current_surface_search_data or not current_surface_search_data.surface.valid then
    -- Start next surface
    next_surface = table.remove(search_data.not_started_surfaces)
    if not next_surface then
      -- All surfaces are complete
      search_data.search_complete = true
      return
    end

    if not next_surface.valid then return end  -- Will try another surface next tick

    -- Setup next surface data
    search_data.current_surface_search_data = {
      surface = next_surface,
      surface_data = get_default_surface_data(),
      surface_statistics = {},
      chunk_iterator = next_surface.get_chunks(),
    }

    -- Update results
    local player_data = storage.players[player_index]
    local refs = player_data.refs
    SearchGui.build_results(search_data.data, search_data.statistics, refs.result_flow, false, true)
    return  -- Start next surface processing on next tick
  end


  local chunk_iterator = current_surface_search_data.chunk_iterator
  if not chunk_iterator.valid then
    search_data.current_surface_search_data = nil
    return
  end

  local current_surface = current_surface_search_data.surface
  local force = search_data.force
  local chunks_processed = 0
  local chunks_per_tick = settings.global["fs-chunks-per-tick"].value
  while chunks_processed < chunks_per_tick do
    local chunk = chunk_iterator()
    if not chunk then
      -- Surface is complete
      if current_surface_search_data.surface == search_data.player.surface then
        generate_distance_data(current_surface_search_data.surface_data, search_data.player.physical_position)
      end
      sort_surface_data(current_surface_search_data.surface_data, search_data.player)

      search_data.data[current_surface.name] = current_surface_search_data.surface_data
      search_data.statistics[current_surface.name] = current_surface_search_data.surface_statistics
      search_data.current_surface_search_data = nil

      search_data.completed_chunk_count = search_data.completed_chunk_count + chunks_processed
      SearchGui.show_search_progress(storage.players[player_index].refs, search_data.completed_chunk_count / search_data.total_chunk_count)
      return
    end

    if force.is_chunk_charted(current_surface, chunk) then
      chunks_processed = chunks_processed + 1
    else
      goto continue
    end

    local target_item = search_data.target_item
    local target_name = target_item.name
    local target_type = target_item.type or "item"
    local target_is_entity = target_type == "entity"
    local target_quality = target_item.quality --[[@as string]] or "normal"

    local state = search_data.state
    local surface_data = current_surface_search_data.surface_data
    local surface_statistics = current_surface_search_data.surface_statistics

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

    for i, entity in pairs(entities) do
      if not math2d.bounding_box.contains_point(chunk_area, entity.position) then
        entities[i] = nil
      end
    end

    Search.process_found_entities(entities, state, surface_data, surface_statistics, target_item)

    -- Map tags
    if state.map_tags then
      local slightly_smaller_chunk_area = {left_top = {chunk_area.left_top.x, chunk_area.left_top.y}, right_bottom = {chunk_area.right_bottom.x - 1, chunk_area.right_bottom.y - 1}}
      local tags = force.find_chart_tags(current_surface.name, slightly_smaller_chunk_area)
      for _, tag in ipairs(tags) do
        if math2d.bounding_box.contains_point(chunk_area, tag.position) then
          local tag_icon = tag.icon
          if tag_icon and signal_eq(target_item, tag_icon) then
            SearchResults.add_tag(tag, surface_data.map_tags)
            SearchResults.add_surface_statistics("tag_count", 1, surface_statistics)
          end
        end
      end
    end

    -- Entities
    if state.entities then
      local target_entity_names = get_target_entity_names(target_item)
      if target_entity_names then
        entities = current_surface.find_entities_filtered{
          area = chunk_area,
          name = target_entity_names,
          quality = target_quality ~= "any" and target_quality or nil,
          force = { force, "neutral" },
        }
        for _, entity in pairs(entities) do
          if math2d.bounding_box.contains_point(chunk_area, entity.position) then
            if entity.type == "resource" then
              local amount = SearchResults.add_entity_resource(entity, surface_data.entities)
              SearchResults.add_surface_statistics("resource_count", amount, surface_statistics)
            else
              SearchResults.add_entity(entity, surface_data.entities)
              SearchResults.add_surface_statistics("entity_count", 1, surface_statistics)
            end
          end
        end
      end
    end
    ::continue::
  end

  search_data.completed_chunk_count = search_data.completed_chunk_count + chunks_processed
  SearchGui.show_search_progress(storage.players[player_index].refs, search_data.completed_chunk_count / search_data.total_chunk_count)
end

---@param target_item SignalID
---@param force LuaForce
---@param state SearchGuiState
---@param player LuaPlayer
---@param immediate? boolean
---@return boolean
function Search.find_machines(target_item, force, state, player, immediate)
  local target_name = target_item.name
  if target_name == nil then
    -- 'Unknown signal selected'
    return false
  end

  -- Crafting Combinator adds signals for recipes, which players sometimes mistake for items/fluids
  if target_item.type == "virtual" and not state.signals
    and (script.active_mods["crafting_combinator"] or script.active_mods["crafting_combinator_xeraph"]) then
    local recipe = prototypes.recipe[target_name]
    if recipe then
      player.print("[Factory Search] It looks like you selected a recipe from the \"Crafting combinator recipes\" tab. Instead select an item or fluid from a different tab.")
      return false
    end
  end

  local target_type = target_item.type or "item"
  local target_is_item = target_type == "item"
  local target_is_fluid = target_type == "fluid"

  local entity_types = {}
  local neutral_entity_types = {}
  if (target_is_item or target_is_fluid) and state.consumers then
    add_entity_type(entity_types, ingredient_entities)

    -- Only add turrets if target is ammo
    if target_is_item and prototypes.get_item_filtered({{filter = "type", type = "ammo"}})[target_name] then
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

  local surface_list
  if not state.all_surfaces then
    surface_list = {player.surface}
  else
    surface_list = filtered_surfaces()
  end

  local total_chunk_count = 0
  local non_blocking_setting = settings.global["fs-non-blocking-search"].value
  if non_blocking_setting == "on" or (non_blocking_setting == "multiplayer" and game.is_multiplayer()) then
    non_blocking_search = true

    for _, surface in ipairs(surface_list) do
      for chunk in surface.get_chunks() do
        if force.is_chunk_charted(surface, chunk) then
          total_chunk_count = total_chunk_count + 1
        end
      end
    end
  else
    non_blocking_search = false
  end
  search_data = {
    blocking = not non_blocking_search,
    tick_triggered = game.tick - (immediate and DEBOUNCE_TICKS or 0),
    force = force,
    state = state,
    target_item = target_item,
    type_list = type_list,
    neutral_type_list = neutral_type_list,
    player = player,
    data = {},
    statistics = {},
    not_started_surfaces = surface_list,
    search_complete = false,
    total_chunk_count = total_chunk_count,
    completed_chunk_count = 0
  }
  storage.current_searches[player.index] = search_data
  return true
end

Search.events = {
  [defines.events.on_tick] = on_tick,
}

return Search