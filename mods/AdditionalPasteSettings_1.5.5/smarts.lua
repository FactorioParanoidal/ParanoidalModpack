require('util')

local lib = require('lib')
local config = require('config')
local Smarts = {} ---@class Smarts

--------------------------------------------------------------------------------------------------------------
----------  Local Helper functions

--------------------------------------------------------------------------------------------------------------
-- Classes

---@class ItemCycle
---@field name string
---@field type string

---@class EntityData
---@field cycle ItemCycle[]
---@field cycle_index int


--------------------------------------------------------------------------------------------------------------
----------  Local cycle functions

-----  Container cycle
---@param entity LuaEntity
---@return ItemCycle[]
local function container_cycle(entity)
    local cycle = {}
    if entity and entity.valid and entity.get_inventory(defines.inventory.chest) then
        local inventory = lib.get_keys(entity.get_inventory(defines.inventory.chest).get_contents())
        for _, v in pairs(inventory) do
            table.insert(cycle, { name = v, type = "item" })
        end
    end
    return cycle
end

-----  Decider/Arithmetic combinator cycle
---@param entity LuaEntity
---@return ItemCycle[]
local function decider_arithmetic_combinator_cycle(entity)
    local cycle = {}
    if entity and entity.valid then
        local cb = entity.get_control_behavior() ---@cast cb LuaCombinatorControlBehavior
        if cb and cb.signals_last_tick then
            local signals = cb.signals_last_tick
            for _, v in pairs(signals) do
                table.insert(cycle, v.signal)
            end
        end
    end
    return cycle
end

-----  DisplayPlate current sprite
---@param entity LuaEntity
---@return ItemCycle[]
local function simple_entity_with_owner_cycle(entity)
    local remote_interface
    if game.active_mods["IndustrialDisplayPlates"] then remote_interface = "IndustrialDisplayPlates" end
    if game.active_mods["DisplayPlates"] then remote_interface = "DisplayPlates" end

    local interfaces = remote.interfaces[remote_interface]
    if (not interfaces.get_sprite) and (not interfaces.set_sprite) then return {} end

    local rv = remote.call(remote_interface, "get_sprite", { entity = entity })
    if (not rv) then return {} end

    local cycle = { { type = rv.spritetype, name = rv.spritename } }
    return cycle
end

-----  Assembly Machine cycle
---@param entity LuaEntity
---@return ItemCycle[]
local function assembly_cycle(entity)
    local cycle = {}

    if entity and entity.valid and entity.get_recipe() then
        local recipe = entity.get_recipe()
        for _, v in pairs(recipe.products) do
            table.insert(cycle, v)
        end
        for _, v in pairs(recipe.ingredients) do
            table.insert(cycle, v)
        end
    end

    return cycle
end

-----  Constant Combinator cycle
---@param entity LuaEntity
---@return ItemCycle[]
local function constant_combinator_cycle(entity)
    local cycle = {}

    if entity and entity.valid then
        local cb = entity.get_control_behavior() ---@cast cb LuaConstantCombinatorControlBehavior
        if cb and cb.enabled then
            local signals = cb.parameters
            for _, v in pairs(signals) do
                if v.signal.name then
                    table.insert(cycle, v.signal)
                end
            end
        end
    end

    return cycle
end

--------------------------------------------------------------------------------------------------------------
----------  Local rename functions

---@param landing_pad_entity LuaEntity
---@param cycle ItemCycle[]
local function update_se_landing_pad_name(landing_pad_entity, cycle)
    if landing_pad_entity.name ~= "se-rocket-landing-pad" then return end

    -- If the destination is a SE landing pad use remote interface to rename the pad and show a flying text
    global.entity_data[landing_pad_entity.unit_number] = global.entity_data[landing_pad_entity.unit_number] or {}

    -- Check if the global dict tracking the entities being changed needs to be reset due to a new inventory
    local entity = global.entity_data[landing_pad_entity.unit_number]
    if entity == nil or entity.cycle == nil or (not table.compare(cycle, entity.cycle)) then
        entity = entity or {}
        entity.cycle = cycle
        entity.cycle_index = 1
    end

    local item = entity.cycle[entity.cycle_index]
    if (not item) then return end

    local item_name
    if config['use_Babelfish'] then
        item_name = lib.find_name_in_babelfish_dictonary(item.name, item.type)
    else
        item_name = item.name
    end

    -- Get the name of the cargo rocket pad following the naming standard in the "MAP SETTINGS"
    local name = lib.parse_string(config['se-rocket-landing-pad-name'], { lib.parse_signal_to_rich_text(item), item_name })
    entity.cycle_index = entity.cycle_index + 1
    if entity.cycle_index > #entity.cycle then entity.cycle_index = 1 end

    -- Grab the current name and if the new name is different use the remote interface to change the name of the landing pad
    local current_name = remote.call("space-exploration", "get_landing_pad_name",
        { unit_number = landing_pad_entity.unit_number })
    if current_name ~= name then
        landing_pad_entity.surface.create_entity { name = "flying-text", position = landing_pad_entity.position, text = name, color = lib.colors.white }
        remote.call("space-exploration", "set_landing_pad_name", { unit_number = landing_pad_entity.unit_number, name = name })
    end

end

---@param display_plate LuaEntity
---@param cycle ItemCycle[]
local function update_simple_entity_with_owner(display_plate, cycle)

    local remote_interface
    if game.active_mods["IndustrialDisplayPlates"] then remote_interface = "IndustrialDisplayPlates" end
    if game.active_mods["DisplayPlates"] then remote_interface = "DisplayPlates" end

    local interfaces = remote.interfaces[remote_interface]
    if (not interfaces.get_sprite) and (not interfaces.set_sprite) then return end

    local rv = remote.call(remote_interface, "get_sprite", { entity = display_plate })
    if (not rv) then return end

    global.entity_data[display_plate.unit_number] = global.entity_data[display_plate.unit_number] or {}
    local entity = global.entity_data[display_plate.unit_number]

    if entity == nil or entity.cycle == nil or not table.compare(cycle, entity.cycle) then
        entity = entity or {}
        entity.cycle = cycle
        entity.cycle_index = 1
    end

    if entity.cycle[entity.cycle_index].type == "virtual" then
        entity.cycle[entity.cycle_index].type = "virtual-signal"
    end
    local new_sprite = entity.cycle[entity.cycle_index].type .. "/" .. entity.cycle[entity.cycle_index].name

    local msg = lib.parse_signal_to_rich_text(entity.cycle[entity.cycle_index]) .. " " .. entity.cycle[entity.cycle_index].name
    display_plate.surface.create_entity { name = "flying-text", position = display_plate.position, text = msg, color = lib.colors.white }
    remote.call(remote_interface, "set_sprite", { entity = display_plate, sprite = new_sprite })

    entity.cycle_index = entity.cycle_index + 1
    if entity.cycle_index > #entity.cycle then entity.cycle_index = 1 end
end

----------

---comment
---@param mtype any
---@param multiplier double
---@param stack any
---@param previous_value int
---@param recipe LuaRecipe
---@param speed any
---@param additive any
---@param special? float
---@return int
local function update_stack(mtype, multiplier, stack, previous_value, recipe, speed, additive, special)
    if mtype == "additional-paste-settings-per-stack-size" then
        if additive and previous_value ~= nil then
            if special then
                return previous_value * special
            else
                if game.item_prototypes[stack.name] and game.item_prototypes[stack.name].stack_size then
                    return math.floor(previous_value + (game.item_prototypes[stack.name].stack_size * multiplier))
                else
                    return 0
                end
            end
        else
            if special then
                if game.item_prototypes[stack.name] and game.item_prototypes[stack.name].stack_size then
                    return math.floor(game.item_prototypes[stack.name].stack_size * special)
                else
                    return 0
                end
            else
                if game.item_prototypes[stack.name] and game.item_prototypes[stack.name].stack_size then
                    return math.floor(game.item_prototypes[stack.name].stack_size * multiplier)
                else
                    return 0
                end
            end
        end
    elseif mtype == "additional-paste-settings-per-recipe-size" then
        local amount = 0
        if recipe then
            for i = 1, #recipe.ingredients do
                if recipe.ingredients[i].name == stack.name then
                    amount = recipe.ingredients[i].amount
                    break
                end
            end
            for i = 1, #recipe.products do
                if recipe.products[i].name == stack.name then
                    if recipe.products[i].amount then
                        amount = recipe.products[i].amount
                    else
                        amount = recipe.products[i].amount_max
                    end
                    break
                end
            end
        end
        if additive and previous_value ~= nil then
            return math.floor(previous_value + amount * multiplier)
        else
            return math.floor(amount * multiplier)
        end
    elseif mtype == "additional-paste-settings-per-time-size" then
        local amount = 0
        if recipe then
            for i = 1, #recipe.ingredients do
                if recipe.ingredients[i].name == stack.name then
                    amount = recipe.ingredients[i].amount
                    break
                end
            end
            for i = 1, #recipe.products do
                if recipe.products[i].name == stack.name then
                    if recipe.products[i].amount then
                        amount = recipe.products[i].amount
                    else
                        amount = recipe.products[i].amount_max
                    end
                    break
                end
            end
            if additive and previous_value ~= nil then
                return math.ceil(previous_value + amount * multiplier * speed / recipe.energy)
            else
                return math.ceil(amount * multiplier * speed / recipe.energy)
            end
        end
    else
        error "error"
    end
    return 0
end

function Smarts.clear_requester_chest(from, to)
    if from == to then
        if to.prototype.logistic_mode == "requester" or to.prototype.logistic_mode == "buffer" then
            for i = 1, to.request_slot_count do
                to.clear_request_slot(i)
            end
        elseif to.prototype.logistic_mode == "storage" then
            to.storage_filter = nil
        end
    end
end

function Smarts.clear_inserter_settings(from, to, player, special)
    if from == to and
        settings.get_player_settings(player)["additional-paste-settings-paste-clear-inserter-filter-on-paste-over"].value then
        local ctrl = to.get_or_create_control_behavior()
        ctrl.logistic_condition = nil
        ctrl.circuit_condition = nil
        ctrl.connect_to_logistic_network = false
        ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.none
    end
end

---Copy machine to constant combinator
---@param from LuaEntity
---@param to LuaEntity
---@param player LuaPlayer
function Smarts.assembly_to_constant_combinator(from, to, player)
    local multiplier = settings.get_player_settings(player)["additional-paste-settings-options-combinator-multiplier-value"].value ---@cast multiplier double
    local mtype = settings.get_player_settings(player)["additional-paste-settings-options-combinator-multiplier-type"].value
    local additive = settings.get_player_settings(player)["additional-paste-settings-options-sumup"].value
    local recipe = from.get_recipe()
    local amount = 0 ---@type int
    local per_recipe_size = ("additional-paste-settings-per-recipe-size" == settings.get_player_settings(player)["additional-paste-settings-options-requester-multiplier-type"].value)

    local current = nil
    local found = false
    local msg = ""
    local ctrl = to.get_or_create_control_behavior() ---@cast ctrl LuaConstantCombinatorControlBehavior
    if recipe then
        for k = 1, #recipe.ingredients do
            current = recipe.ingredients[k]
            found = false
            ---@type uint
            for i = 1, ctrl.signals_count do
                local s = ctrl.get_signal(i)
                if s.signal ~= nil and s.signal.name == current.name then
                    amount = update_stack(mtype, multiplier, { name = current.name }, s.count, recipe, from.crafting_speed, additive)
                    ctrl.set_signal(i, { signal = { type = current.type, name = current.name }, count = amount })
                    msg = msg .. "[img=" .. current.type .. "." .. current.name .. "] = " .. amount .. " "
                    found = true
                end
            end

            if (not found) then
                ---@type uint
                for i = 1, ctrl.signals_count do
                    local s = ctrl.get_signal(i)
                    if s.signal == nil then
                        amount = update_stack(mtype, multiplier, { name = current.name }, nil, recipe, from.crafting_speed, additive)
                        ctrl.set_signal(i, { signal = { type = current.type, name = current.name }, count = amount })
                        msg = msg .. "[img=" .. current.type .. "." .. current.name .. "] = " .. amount .. " "
                        break
                    end
                end
            end
        end
        to.surface.create_entity { name = "flying-text", position = to.position, text = msg, color = lib.colors.white }
    end
end

function Smarts.assembly_to_logistic_chest(from, to, player, special)
    -- this needs additional logic from events on_vanilla_pre_paste and on_vanilla_paste to correctly set the filter
    if to.prototype.logistic_mode == "requester" or to.prototype.logistic_mode == "buffer" then
        global.event_backup[from.position.x .. "-" .. from.position.y .. "-" .. to.position.x .. "-" .. to.position.y] = { gamer = player.index, stacks = {} }
    elseif to.prototype.logistic_mode == "storage" then
        if from.get_recipe() ~= nil then
            local msg
            local proto = game.item_prototypes[from.get_recipe().name]
            if proto then
                to.storage_filter = proto
                msg = "Filter applied [img=item." .. from.get_recipe().name .. "]"
                to.surface.create_entity { name = "flying-text", position = to.position, text = msg, color = lib.colors.white }
            else
                local products = from.get_recipe().products
                for _, product in pairs(products) do
                    if product.type and product.type == "item" then
                        proto = game.item_prototypes[product.name]
                        break
                    end
                end
                if proto then
                    to.storage_filter = proto
                    msg = "Filter applied [img=item." .. proto.name .. "]"
                    to.surface.create_entity { name = "flying-text", position = to.position, text = msg, color = lib.colors.white }
                end
            end
        end
    end
end

local function rename_train_stop(station)
    local station_name
    local entity = global.entity_data[station.unit_number]
    local item = entity.cycle[entity.cycle_index]

    if (not item) then return end

    local item_name
    if config['use_Babelfish'] then
        item_name = lib.find_name_in_babelfish_dictonary(item.name, item.type)
    else
        item_name = item.name
    end

    if entity.mode == "Load" then station_name = lib.parse_string(config['station_name_load'], { lib.parse_signal_to_rich_text(item), item_name }) end
    if entity.mode == "Unload" then station_name = lib.parse_string(config['station_name_unload'], { lib.parse_signal_to_rich_text(item), item_name }) end
    if entity.mode == "Unload" then entity.cycle_index = entity.cycle_index + 1 end
    if entity.mode == "Load" then entity.mode = "Unload" else entity.mode = "Load" end
    if entity.cycle_index > #entity.cycle then entity.cycle_index = 1 end

    if station.backer_name ~= station_name then
        station.backer_name = station_name
        station.surface.create_entity { name = "flying-text", position = station.position, text = station.backer_name, color = lib.colors.white }
    end
end

local function update_station(to, cycle)
    global.entity_data[to.unit_number] = global.entity_data[to.unit_number] or {}
    local entity = global.entity_data[to.unit_number]

    if entity == nil or entity.cycle == nil or (not table.compare(cycle, entity.cycle)) then
        entity.mode = "Load"
        entity.cycle = cycle
        entity.cycle_index = 1
    end

    rename_train_stop(to)
end

function Smarts.constant_combinator_to_train_stop(from, to, player, special)
    local cycle = constant_combinator_cycle(from)
    if #cycle > 0 then update_station(to, cycle) end
end

function Smarts.decider_arithmetic_combinator_to_train_stop(from, to, player, special)
    local cycle = decider_arithmetic_combinator_cycle(from)
    if #cycle > 0 then update_station(to, cycle) end
end

function Smarts.decider_arithmetic_combinator_to_container(from, to, player, special)
    local cycle = decider_arithmetic_combinator_cycle(from)
    if #cycle == 0 then return end
    update_se_landing_pad_name(to, cycle)
end

function Smarts.simple_entity_with_owner_to_container(from, to, player, special)
    if to.name == "se-rocket-landing-pad" then
        local cycle = simple_entity_with_owner_cycle(from)
        if #cycle == 0 then return end
        update_se_landing_pad_name(to, cycle)
    end
end

function Smarts.constant_combinator_to_container(from, to, player, special)
    if to.name == "se-rocket-landing-pad" then
        local cycle = constant_combinator_cycle(from)
        if #cycle > 0 then update_se_landing_pad_name(to, cycle) end
    end
end

function Smarts.assembly_to_container(from, to, player, special)
    if to.name == "se-rocket-landing-pad" then
        local cycle = assembly_cycle(from)
        if #cycle > 0 then update_se_landing_pad_name(to, cycle) end
    end
end

function Smarts.container_to_container(from, to, player, special)
    if to.name == "se-rocket-landing-pad" then
        local cycle = container_cycle(from)
        update_se_landing_pad_name(to, cycle)
    end
end

function Smarts.decider_arithmetic_combinator_to_simple_entity_with_owner(from, to, player, special)
    local cycle = decider_arithmetic_combinator_cycle(from)
    if #cycle > 0 then update_simple_entity_with_owner(to, cycle) end
end

function Smarts.constant_combinator_to_simple_entity_with_owner(from, to, player, special)
    local cycle = constant_combinator_cycle(from)
    if #cycle > 0 then update_simple_entity_with_owner(to, cycle) end
end

function Smarts.assembly_to_simple_entity_with_owner(from, to, player, special)
    local cycle = assembly_cycle(from)
    if #cycle > 0 then update_simple_entity_with_owner(to, cycle) end
end

function Smarts.container_to_simple_entity_with_owner(from, to, player, special)
    local cycle = container_cycle(from)
    if #cycle > 0 then update_simple_entity_with_owner(to, cycle) end
end

function Smarts.container_to_train_stop(from, to, player, special)
    local cycle = container_cycle(from)
    if #cycle > 0 then update_station(to, cycle) end
end

function Smarts.assembly_to_train_stop(from, to, player, special)
    local cycle = assembly_cycle(from)
    if #cycle > 0 then update_station(to, cycle) end
end

function Smarts.assembly_to_transport_belt(from, to, player, special)
    if (not settings.get_player_settings(player)["additional-paste-settings-paste-to-belt-enabled"].value) then
        return
    end

    local ctrl = to.get_or_create_control_behavior()
    local c1 = ctrl.get_circuit_network(defines.wire_type.red)
    local c2 = ctrl.get_circuit_network(defines.wire_type.green)

    local fromRecipe = from.get_recipe()

    if fromRecipe == nil then
        if c1 == nil and c2 == nil then
            ctrl.logistic_condition = nil
            ctrl.connect_to_logistic_network = false
        else
            ctrl.circuit_condition = nil
            ctrl.enable_disable = false
        end
    else
        local product = fromRecipe.products[1].name
        local item = game.item_prototypes[product]

        if item ~= nil then
            local comparator = settings.get_player_settings(player)["additional-paste-settings-options-comparator-value"].value
            local multiplier = settings.get_player_settings(player)["additional-paste-settings-options-transport_belt-multiplier-value"].value ---@cast multiplier double
            local mtype = settings.get_player_settings(player)["additional-paste-settings-options-transport_belt-multiplier-type"].value
            local additive = settings.get_player_settings(player)["additional-paste-settings-options-sumup"].value
            local amount = update_stack(mtype, multiplier, item, nil, fromRecipe, from.crafting_speed, additive, special)
            if c1 == nil and c2 == nil then
                if ctrl.connect_to_logistic_network and
                    ctrl.logistic_condition["condition"]["first_signal"]["name"] == product then
                    if ctrl.logistic_condition["condition"]["constant"] ~= nil then
                        amount = update_stack(mtype, multiplier, item, ctrl.logistic_condition["condition"]["constant"],
                            fromRecipe, from.crafting_speed, additive, special)
                    end
                else
                    ctrl.connect_to_logistic_network = true
                end
                ctrl.logistic_condition = { condition = { comparator = comparator, first_signal = { type = "item", name = product }, constant = amount } }
                to.surface.create_entity { name = "flying-text", position = to.position, text = "[img=item." .. product .. "] " .. comparator .. " " .. math.floor(amount), color = lib.colors.white }
            else
                if ctrl.enable_disable and ctrl.circuit_condition["condition"]["first_signal"]["name"] == product then
                    if ctrl.logistic_condition["condition"]["constant"] ~= nil then
                        amount = update_stack(mtype, multiplier, item, ctrl.circuit_condition["condition"]["constant"], fromRecipe, from.crafting_speed, additive, special)
                    end
                else
                    ctrl.enable_disable = true
                end
                ctrl.circuit_condition = { condition = { comparator = comparator, first_signal = { type = "item", name = product }, constant = amount } }
                to.surface.create_entity { name = "flying-text", position = to.position, text = "[img=item." .. product .. "] " .. comparator .. " " .. math.floor(amount), color = lib.colors.white }
            end
        end
    end
end

function Smarts.assembly_to_inserter(from, to, player, special)
    local ctrl = to.get_or_create_control_behavior()
    local c1 = ctrl.get_circuit_network(defines.wire_type.red)
    local c2 = ctrl.get_circuit_network(defines.wire_type.green)

    local fromRecipe = from.get_recipe()

    if fromRecipe == nil then
        if c1 == nil and c2 == nil then
            ctrl.logistic_condition = nil
            ctrl.connect_to_logistic_network = false
        else
            ctrl.circuit_condition = nil
            ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.none
        end
    else
        local product = fromRecipe.products[1].name
        local item = game.item_prototypes[product]

        if item ~= nil then
            local comparator = settings.get_player_settings(player)["additional-paste-settings-options-comparator-value"].value
            local multiplier = settings.get_player_settings(player)["additional-paste-settings-options-inserter-multiplier-value"].value ---@cast multiplier double
            local mtype = settings.get_player_settings(player)["additional-paste-settings-options-inserter-multiplier-type"].value
            local additive = settings.get_player_settings(player)["additional-paste-settings-options-sumup"].value
            local amount = update_stack(mtype, multiplier, item, nil, fromRecipe, from.crafting_speed, additive, special)
            if c1 == nil and c2 == nil then
                if ctrl.connect_to_logistic_network and
                    ctrl.logistic_condition["condition"]["first_signal"]["name"] == product then
                    if ctrl.logistic_condition["condition"]["constant"] ~= nil then
                        amount = update_stack(mtype, multiplier, item, ctrl.logistic_condition["condition"]["constant"],
                            fromRecipe, from.crafting_speed, additive, special)
                    end
                else
                    ctrl.connect_to_logistic_network = true
                end
                ctrl.logistic_condition = { condition = { comparator = comparator, first_signal = { type = "item", name = product }, constant = amount } }
                to.surface.create_entity { name = "flying-text", position = to.position, text = "[img=item." .. product .. "] " .. comparator .. " " .. math.floor(amount), color = lib.colors.white }
            else
                if ctrl.circuit_mode_of_operation ==
                    defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable and
                    ctrl.circuit_condition["condition"]["first_signal"]["name"] == product then
                    if ctrl.logistic_condition["condition"]["constant"] ~= nil then
                        amount = update_stack(mtype, multiplier, item, ctrl.circuit_condition["condition"]["constant"],
                            fromRecipe, from.crafting_speed, additive, special)
                    end
                else
                    ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable
                end
                ctrl.circuit_condition = { condition = { comparator = comparator, first_signal = { type = "item", name = product }, constant = amount } }
                to.surface.create_entity { name = "flying-text", position = to.position, text = "[img=item." .. product .. "] " .. comparator .. " " .. math.floor(amount), color = lib.colors.white }
            end
        end
    end
end

function Smarts.on_hotkey_pressed(event)
    local player = game.players[event.player_index]
    local special = nil

    if event.input_name and event.input_name == "additional-paste-settings-hotkey-alt" then
        special = 0.5
    end

    if player ~= nil and player.connected then
        local from = player.entity_copy_source
        local to = player.selected

        if from ~= nil and to ~= nil then
            local key = from.type .. "|" .. to.type
            local act = Smarts.actions[key]

            if act ~= nil then
                act(from, to, player, special)
            end
        end
    end
end

---@param event EventData.on_pre_entity_settings_pasted
function Smarts.on_vanilla_pre_paste(event)
    if event.source.type == "assembling-machine" and event.destination.type == "logistic-container" and (event.destination.prototype.logistic_mode == "requester" or event.destination.prototype.logistic_mode == "buffer") then
        local evt = global.event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y]
        local range = event.destination.request_slot_count

        if evt ~= nil then
            ---@type uint
            for i = 1, range do
                local j = event.destination.get_request_slot(i)
                if j == nil then
                    -- evt.stacks[i] = {}
                else
                    evt.stacks[j.name] = j.count
                end
            end
        end
    end
end

---@param event EventData.on_entity_settings_pasted
function Smarts.on_vanilla_paste(event)
    local evt = global.event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y]

    if evt ~= nil and event.source.type == "assembling-machine" and event.destination.type == "logistic-container" and (event.destination.prototype.logistic_mode == "requester" or event.destination.prototype.logistic_mode == "buffer") then
        local result = {}
        local multiplier = settings.get_player_settings(event.player_index)["additional-paste-settings-options-requester-multiplier-value"].value ---@cast multiplier double
        local mtype = settings.get_player_settings(event.player_index)["additional-paste-settings-options-requester-multiplier-type"].value
        local recipe = event.source.get_recipe() ---@cast recipe LuaRecipe
        local speed = event.source.crafting_speed
        local additive = settings.get_player_settings(event.player_index)["additional-paste-settings-options-sumup"].value
        local invertPaste = settings.get_player_settings(event.player_index)["additional-paste-settings-options-invert-buffer"].value and event.destination.prototype.logistic_mode == "buffer"
        if invertPaste and event.destination.prototype.logistic_mode == "buffer" then
            mtype = "additional-paste-settings-per-stack-size"
            multiplier = settings.get_player_settings(event.player_index)["additional-paste-settings-options-invert-buffer-multiplier-value"].value ---@cast multiplier double
        end

        local post_stacks = {}
        ---@type uint
        for i = 1, event.destination.request_slot_count do
            local stack = event.destination.get_request_slot(i)
            if stack then
                post_stacks[stack.name] = stack.count
                if (not evt.stacks[stack.name]) then
                    evt.stacks[stack.name] = 0
                end
            end
        end

        for k, v in pairs(evt.stacks) do
            local prior = { name = k, count = v }
            local post = { name = k, count = post_stacks[k] }

            if prior ~= {} then
                if result[prior.name] ~= nil then
                    -- update_stack(mtype, multiplier, stack, previous_value, recipe, speed, additive, special)
                    result[prior.name].count = update_stack(mtype, multiplier, prior, result[prior.name].count, recipe, speed, additive)
                else
                    result[prior.name] = { name = prior.name, count = prior.count }
                end
            end

            if post ~= nil then
                if invertPaste then
                    if result[post.name] ~= nil then
                        result[post.name].count = update_stack(mtype, -1 * multiplier, post, result[post.name].count, recipe, speed, additive)
                    else
                        result[post.name] = { name = post.name, count = 0 }
                    end
                else
                    if result[post.name] ~= nil then
                        result[post.name].count = update_stack(mtype, multiplier, post, result[post.name].count, recipe, speed, additive)
                    else
                        result[post.name] = { name = post.name,
                            count = update_stack(mtype, multiplier, post, nil, recipe, speed, additive) }
                    end
                end
            end
        end

        if invertPaste and recipe then
            for k, product in pairs(recipe.products) do
                if result[product.name] ~= nil then
                    result[product.name].count = update_stack(mtype, multiplier, result[product.name], result[product.name].count, recipe, speed, additive)
                else
                    result[product.name] = {
                        name = product.name,
                        count = update_stack(mtype, multiplier, { name = product.name }, game.item_prototypes[product.name].stack_size, recipe, speed, additive)
                    }
                end
            end
        end

        ---@type uint
        for i = 1, event.destination.request_slot_count do
            event.destination.clear_request_slot(i)
        end

        local i = 1
        local msg = ""
        for k, v in pairs(result) do
            if v and v.count and v.count > 0 then
                event.destination.set_request_slot(v, i)
                msg = msg .. "[img=item." .. v.name .. "] = " .. v.count .. " "
                i = i + 1
            end
        end

        event.destination.surface.create_entity { name = "flying-text", position = event.destination.position, text = msg, color = lib.colors.white }
        global.event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y] = nil
    end
end

function Smarts.get_translations()
    global.locale_dictionaries = remote.call("Babelfish", "get_translations")
end

-- ---@type table<string, fun(name:string, value: number)>
-- TeamMember.actions = {
--     ["bob"] =  TeamMember.GuiRecreateForPlayer
-- }

-- local x = TeamMember.actions["dave"]

-- ---------------------------------------------------------------

-- ---@alias test table<string, function>

-- ---@type test
-- TeamMember.actions1 = {
--     ["bob"] =  TeamMember.GuiRecreateForPlayer
-- }

---@type table<string, fun(from: LuaEntity, to: LuaEntity, player?: LuaPlayer|nil, special?: number|nil)>
Smarts.actions = {
    --  SE cargo landing pad actions
    ["container|container"] = Smarts.container_to_container,
    ["logistic-container|container"] = Smarts.container_to_container,
    ["arithmetic-combinator|container"] = Smarts.decider_arithmetic_combinator_to_container,
    ["decider-combinator|container"] = Smarts.decider_arithmetic_combinator_to_container,
    ["constant-combinator|container"] = Smarts.constant_combinator_to_container,
    ["assembling-machine|container"] = Smarts.assembly_to_container,

    --  SE + DisplayPlate actions
    ["simple-entity-with-owner|container"] = Smarts.simple_entity_with_owner_to_container,

    --  DisplayPlate actions
    ["container|simple-entity-with-owner"] = Smarts.container_to_simple_entity_with_owner,
    ["logistic-container|simple-entity-with-owner"] = Smarts.container_to_simple_entity_with_owner,
    ["arithmetic-combinator|simple-entity-with-owner"] = Smarts.decider_arithmetic_combinator_to_simple_entity_with_owner,
    ["decider-combinator|simple-entity-with-owner"] = Smarts.decider_arithmetic_combinator_to_simple_entity_with_owner,
    ["constant-combinator|simple-entity-with-owner"] = Smarts.constant_combinator_to_simple_entity_with_owner,
    ["assembling-machine|simple-entity-with-owner"] = Smarts.assembly_to_simple_entity_with_owner,

    --  Train station actions
    ["constant-combinator|train-stop"] = Smarts.constant_combinator_to_train_stop,
    ["decider-combinator|train-stop"] = Smarts.decider_arithmetic_combinator_to_train_stop,
    ["arithmetic-combinator|train-stop"] = Smarts.decider_arithmetic_combinator_to_train_stop,
    ["container|train-stop"] = Smarts.container_to_train_stop,
    ["assembling-machine|train-stop"] = Smarts.assembly_to_train_stop,

    --  Old actions
    ["assembling-machine|transport-belt"] = Smarts.assembly_to_transport_belt,
    ["assembling-machine|inserter"] = Smarts.assembly_to_inserter,
    ["assembling-machine|logistic-container"] = Smarts.assembly_to_logistic_chest,
    ["assembling-machine|constant-combinator"] = Smarts.assembly_to_constant_combinator,
    ["logistic-container|logistic-container"] = Smarts.clear_requester_chest,
    ["inserter|inserter"] = Smarts.clear_inserter_settings
}

return Smarts
