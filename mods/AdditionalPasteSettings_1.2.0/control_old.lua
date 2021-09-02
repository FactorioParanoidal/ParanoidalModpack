-- DEBUG
function print_r(t, player)
    if player == nil then
        player = game.players[1]
    end
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            player.print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        player.print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        player.print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        player.print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        player.print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                player.print(indent .. tostring(t))
            end
        end
    end
    if (type(t) == "table") then
        player.print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        player.print("}")
    else
        sub_print_r(t, "  ")
    end
    --player.print("end")
end
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
-- end DEBUG

-- Variables
actions = {type_type = {}, prototype_prototype = {}, type_prototype = {}, prototype_type = {}}
empty = {}
local event_backup = {}

-- Api
map_type_to_type = function(from, to, action)
    local previous = actions.type_type[from .. "!" .. to]
    if previous ~= nil then
        previous[#previous + 1] = action
    else
        actions.type_type[from .. "!" .. to] = {action}
    end

    return #actions.type_type[from .. "!" .. to]
end

map_type_to_prototype = function(from, to, action)
    local previous = actions.type_prototype[from .. "!" .. to]
    if previous ~= nil then
        previous[#previous + 1] = action
    else
        actions.type_prototype[from .. "!" .. to] = {action}
    end

    return #actions.type_prototype[from .. "!" .. to]
end

map_prototype_to_prototype = function(from, to, action)
    local previous = actions.prototype_prototype[from .. "!" .. to]
    if previous ~= nil then
        previous[#previous + 1] = action
    else
        actions.prototype_prototype[from .. "!" .. to] = {action}
    end

    return #actions.prototype_prototype[from .. "!" .. to]
end

map_prototype_to_type = function(from, to, action)
    local previous = actions.prototype_type[from .. "!" .. to]
    if previous ~= nil then
        previous[#previous + 1] = action
    else
        actions.prototype_type[from .. "!" .. to] = {action}
    end

    return #actions.prototype_type[from .. "!" .. to]
end

-- Helpers

local function update_stack(mtype, multiplier, stack, previous_value, recipe, speed, additive)
    if not game.item_prototypes[stack.name] then
        protos = game.fluid_prototypes
    end

    if mtype == "additional-paste-settings-per-stack-size" then
        if additive and previous_value ~= nil then
            return previous_value + game.item_prototypes[stack.name].stack_size * multiplier
        else
            return game.item_prototypes[stack.name].stack_size * multiplier
        end
    elseif mtype == "additional-paste-settings-per-recipe-size" then
        local amount = 0
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
            return previous_value + amount * multiplier
        else
            return amount * multiplier
        end
    elseif mtype == "additional-paste-settings-per-time-size" then
        local amount = 0
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
    else
        error "error"
    end
end

-- Local additional paste settings

local assembly_to_inserter = function(from, to, player)
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
            local multiplier = settings.get_player_settings(player)["additional-paste-settings-options-inserter-multiplier-value"].value
            local mtype = settings.get_player_settings(player)["additional-paste-settings-options-inserter-multiplier-type"].value
            local additive = settings.get_player_settings(player)["additional-paste-settings-options-sumup"].value
            local amount = update_stack(mtype, multiplier, item, nil, fromRecipe, from.crafting_speed, additive)
            if c1 == nil and c2 == nil then
                if ctrl.connect_to_logistic_network and ctrl.logistic_condition["condition"]["first_signal"]["name"] == product then
                    if ctrl.logistic_condition["condition"]["constant"] ~= nil then
                        amount = update_stack(mtype, multiplier, item, ctrl.logistic_condition["condition"]["constant"], fromRecipe, from.crafting_speed, additive)
                    end
                else
                    ctrl.connect_to_logistic_network = true
                end
                ctrl.logistic_condition = {condition = {comparator = "<", first_signal = {type = "item", name = product}, constant = amount}}
            else
                if ctrl.circuit_mode_of_operation == defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable and ctrl.circuit_condition["condition"]["first_signal"]["name"] == product then
                    if ctrl.logistic_condition["condition"]["constant"] ~= nil then
                        amount = update_stack(mtype, multiplier, item, ctrl.circuit_condition["condition"]["constant"], fromRecipe, from.crafting_speed, additive)
                    end
                else
                    ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable
                end
                ctrl.circuit_condition = {condition = {comparator = "<", first_signal = {type = "item", name = product}, constant = amount}}
            end
        end
    end
end

local assembly_to_logistic_chest = function(from, to, player)
    -- this needs additional logic from events on_vanilla_pre_paste and on_vanilla_paste to correctly set the filter
    if to.prototype.logistic_mode == "requester" or to.prototype.logistic_mode == "buffer" then
        event_backup[from.position.x .. "-" .. from.position.y .. "-" .. to.position.x .. "-" .. to.position.y] = {gamer = player.index, stacks = {}}
    elseif to.prototype.logistic_mode == "storage" then
        if from.get_recipe() ~= nil then
            to.storage_filter = game.item_prototypes[from.get_recipe().name]
        end
    end
end

local clear_requester_chest = function(from, to, player)
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

local clear_inserter_settings = function(from, to, player)
    if from == to then
        local ctrl = to.get_or_create_control_behavior()
        ctrl.logistic_condition = nil
        ctrl.circuit_condition = nil
        ctrl.connect_to_logistic_network = false
        ctrl.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.none
    end
end

local assembly_to_constant_combinator = function(from, to, player)
    local multiplier = settings.get_player_settings(player)["additional-paste-settings-options-combinator-multiplier-value"].value
    local mtype = settings.get_player_settings(player)["additional-paste-settings-options-combinator-multiplier-type"].value
    local additive = settings.get_player_settings(player)["additional-paste-settings-options-sumup"].value
    local recipe = from.get_recipe()
    local amount = 0
    local per_recipe_size = ("additional-paste-settings-per-recipe-size" == settings.get_player_settings(player)["additional-paste-settings-options-requester-multiplier-type"].value)

    local current = nil
    local found = false
    local ctrl = to.get_or_create_control_behavior()
    if recipe then
        for k = 1, #recipe.ingredients do
            current = recipe.ingredients[k]
            found = false
            for i = 1, ctrl.signals_count do
                local s = ctrl.get_signal(i)
                if s.signal ~= nil and s.signal.name == current.name then
                    amount = update_stack(mtype, multiplier, {name = current.name}, s.count, recipe, from.crafting_speed, additive)
                    ctrl.set_signal(i, {signal = {type = current.type, name = current.name}, count = amount})
                    found = true
                end
            end

            if not found then
                for i = 1, ctrl.signals_count do
                    local s = ctrl.get_signal(i)
                    if s.signal == nil then
                        amount = update_stack(mtype, multiplier, {name = current.name}, nil, recipe, from.crafting_speed, additive)
                        ctrl.set_signal(i, {signal = {type = current.type, name = current.name}, count = amount})
                        break
                    end
                end
            end
        end
    end
end

-- Local logic

local function register_local_settings()
    map_type_to_type("assembling-machine", "inserter", assembly_to_inserter)
    map_type_to_type("assembling-machine", "logistic-container", assembly_to_logistic_chest)
    map_type_to_type("assembling-machine", "constant-combinator", assembly_to_constant_combinator)
    map_type_to_type("logistic-container", "logistic-container", clear_requester_chest)
    map_type_to_type("inserter", "inserter", clear_inserter_settings)
end

-- Events

local function on_vanilla_pre_paste(event)
    if event.source.type == "assembling-machine" and event.destination.type == "logistic-container" and (event.destination.prototype.logistic_mode == "requester" or event.destination.prototype.logistic_mode == "buffer") then
        local evt = event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y]
        local range = event.destination.request_slot_count
        if range == 0 then
            range = 20
        end

        if evt ~= nil then
            for i = 1, range do
                local j = event.destination.get_request_slot(i)
                if j == nil then
                    evt.stacks[i] = empty
                else
                    evt.stacks[i] = j
                end
            end
        end
    end
end

local function on_vanilla_paste(event)
    local evt = event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y]

    if evt ~= nil and event.source.type == "assembling-machine" and event.destination.type == "logistic-container" and (event.destination.prototype.logistic_mode == "requester" or event.destination.prototype.logistic_mode == "buffer") then
        local result = {}
        local indexes = {}
        local multiplier = settings.get_player_settings(event.player_index)["additional-paste-settings-options-requester-multiplier-value"].value
        local mtype = settings.get_player_settings(event.player_index)["additional-paste-settings-options-requester-multiplier-type"].value
        local recipe = event.source.get_recipe()
        local speed = event.source.crafting_speed
        local additive = settings.get_player_settings(event.player_index)["additional-paste-settings-options-sumup"].value
        local invertPaste = settings.get_player_settings(event.player_index)["additional-paste-settings-options-invert-buffer"].value and event.destination.prototype.logistic_mode == "buffer"
        if invertPaste and event.destination.prototype.logistic_mode == "buffer" then
            mtype = "additional-paste-settings-per-stack-size"
            multiplier = settings.get_player_settings(event.player_index)["additional-paste-settings-options-invert-buffer-multiplier-value"].value
        end

        for i = 1, #evt.stacks do
            local prior = evt.stacks[i]
            local post = event.destination.get_request_slot(i)

            if prior ~= empty then
                if result[prior.name] ~= nil then
                    result[prior.name].count = update_stack(mtype, multiplier, prior, result[prior.name].count, recipe, speed, additive)
                else
                    result[prior.name] = {name = prior.name, count = prior.count}
                end
            end

            if post ~= nil then
                if invertPaste then
                    if result[post.name] ~= nil then
                        result[post.name].count = update_stack(mtype, -1 * multiplier, post, result[post.name].count, recipe, speed, additive)
                    else
                        result[post.name] = {name = post.name, count = 0}
                    end
                else
                    if result[post.name] ~= nil then
                        result[post.name].count = update_stack(mtype, multiplier, post, result[post.name].count, recipe, speed, additive)
                    else
                        result[post.name] = {name = post.name, count = update_stack(mtype, multiplier, post, nil, recipe, speed, additive)}
                    end
                end
            end
        end
        if invertPaste and recipe then
            if result[recipe.name] ~= nil then
                result[recipe.name].count = update_stack(mtype, multiplier, result[recipe.name], result[recipe.name].count, recipe, speed, additive)
            else
                result[recipe.name] = {name = recipe.name, count = update_stack(mtype, multiplier, {name = recipe.name}, recipe, speed, additive)}
            end
        end
        local i = 1
        for k, v in pairs(result) do
            if not v or not v.count or v.count == 0 then
                -- Nothing to do here.
                -- elseif i > event.destination.request_slot_count then
                -- 	game.players[evt.gamer].print('Missing space in chest to paste requests')
            else
                event.destination.set_request_slot(v, i)
                i = i + 1
            end
        end
        while i <= event.destination.request_slot_count do
            event.destination.clear_request_slot(i)
            i = i + 1
        end
        event_backup[event.source.position.x .. "-" .. event.source.position.y .. "-" .. event.destination.position.x .. "-" .. event.destination.position.y] = nil
    end
end

local function on_gui_click_aps(event)
    print_r("something")
    print_r(event)
    print_r(defines.gui_type.controller)
end

local function on_hotkey_pressed(event)
    local player = game.players[event.player_index]

    if player ~= nil and player.connected then
        local from = player.entity_copy_source
        local to = player.selected

        if from ~= nil and to ~= nil then
            local key = from.type .. "!" .. to.type
            local act = actions.type_type[key]

            if act ~= nil then
                for i = 1, #act do
                    act[i](from, to, player)
                end
            end

            key = from.type .. "!" .. to.prototype.name
            act = actions.type_prototype[key]

            if act ~= nil then
                for i = 1, #act do
                    act[i](from, to, player)
                end
            end

            key = from.prototype.name .. "!" .. to.prototype.name
            act = actions.prototype_prototype[key]

            if act ~= nil then
                for i = 1, #act do
                    act[i](from, to, player)
                end
            end

            key = from.prototype.name .. "!" .. to.type
            act = actions.prototype_type[key]

            if act ~= nil then
                for i = 1, #act do
                    act[i](from, to, player)
                end
            end

        --player.print( "From: type=" .. from.type .. " prototype=" .. from.prototype.name .. " | To: type=" .. to.type .. " prototype=" .. to.prototype.name )
        end
    end

    if is_debug then
    --player.print("Fired")
    --print_r(actions, player)
    --print_r(event)
    end
end

local function on_init()
    register_local_settings()
end

local function on_load()
    register_local_settings()
end

-- Event register

script.on_init(on_init)
script.on_load(on_load)

script.on_event("additional-paste-settings-hotkey", on_hotkey_pressed)

script.on_event(defines.events.on_pre_entity_settings_pasted, on_vanilla_pre_paste)
script.on_event(defines.events.on_entity_settings_pasted, on_vanilla_paste)

--script.on_event(defines.events.on_gui_click, on_gui_click_aps)
--script.on_event(defines.events.on_gui_opened, on_gui_click_aps)
--script.on_event(defines.events.on_gui_value_changed, on_gui_click_aps)
--script.on_event(defines.events.on_gui_confirmed, on_gui_click_aps)
