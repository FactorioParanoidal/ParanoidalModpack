local get_filter_updater = require("filter_updaters")
local fh_util = require("fh_util")

---@param hook_name string
---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---@return boolean
---Calls a remote hook on a target entity if needed. Returns true if the hook was used.
local function call_items_hook(hook_name, entity, items)
    local hook = prototypes.mod_data.fh_add_items_hooks.data[hook_name][fh_util.get_effective_name(entity)]
    if not hook then
        return false
    end
    for _, item in pairs(remote.call(hook[1], hook[2], entity)) do
        fh_util.add_item_to_table(items, item)
    end
    return true
end

local function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

local function add_inventory_items(table, inventory)
    if inventory then
        for _, item in pairs(inventory.get_contents()) do
            fh_util.add_item_to_table(table, item)
        end
    end
end

local function get_player_global(player_index)
    local player_global = storage.players[player_index]
    if player_global and player_global.player and player_global.player.valid then
        return player_global
    end
end

local fuel_category_to_items_cache
local function get_items_by_fuel_category(fuel_category)
    if not settings.global["fh-add-fuel-items"].value then
        return {}
    end
    if not fuel_category_to_items_cache then
        fuel_category_to_items_cache = {}
        for _, item_prototype in pairs(prototypes.item) do
            local item_fuel_category = item_prototype.fuel_category
            if item_fuel_category then
                if not fuel_category_to_items_cache[item_fuel_category] then
                    fuel_category_to_items_cache[item_fuel_category] = {}
                end
                table.insert(fuel_category_to_items_cache[item_fuel_category], item_prototype)
            end
        end
    end
    return fuel_category_to_items_cache[fuel_category] or {}
end

local function spoil_closure(items, exclude_inputs)
    local result = exclude_inputs and {} or table.deepcopy(items)
    while next(items) do
        local new_items = {}
        for _, item in pairs(items) do
            local item_prototype = prototypes.item[item.name]
            local spoil_result = item_prototype and item_prototype.spoil_result
            if spoil_result and not result[fh_util.make_item_id(spoil_result.name, item.quality)] then
                fh_util.add_item_to_table(new_items, spoil_result, item.quality)
                fh_util.add_item_to_table(result, spoil_result, item.quality)
            end
        end
        items = new_items
    end
    return result
end

local function build_sprite_buttons(player_global, updater)
    local button_table = player_global.elements.button_table
    button_table.clear()

    local items = spoil_closure(player_global.items)
    local active_items = player_global.active_items

    for item_id, item in pairs(items) do
        local elem_type
        local prototype_name
        local item_value
        if prototypes.item[item.name] then
            elem_type = "item-with-quality"
            prototype_name = "item"
            item_value = item
        elseif prototypes.fluid[item.name] then
            elem_type = "fluid"
            prototype_name = "fluid"
            item_value = item.name
        else
            goto continue
        end

        local button = button_table.add {
            type = "choose-elem-button",
            elem_type = elem_type,
            [elem_type] = item_value,
            tags = {
                action = active_items[item_id] and "fh_deselect_button" or "fh_select_button",
                item = item,
            },
            tooltip = { "fh.button-tooltip", prototypes[prototype_name][item.name].localised_name, updater.button_description },
            style = active_items[item_id] and "yellow_slot_button" or "slot_button",
            mouse_button_filter = { "left", "right" },
        }
        button.locked = true

        :: continue ::
    end
end

local buttons_per_column = 7 -- the maximum number of sprite-buttons per column in the gui
local max_columns = 10 -- the maximum number of columns to use for the gui

local function build_interface(player_global)
    if player_global.elements.main_frame then
        player_global.elements.main_frame.destroy()
    end

    local guis_table = {
        ["splitter"] = defines.relative_gui_type.splitter_gui,
        ["lane-splitter"] = defines.relative_gui_type.splitter_gui,
        ["logistic-container"] = defines.relative_gui_type.container_gui,
        ["loader"] = defines.relative_gui_type.loader_gui,
        ["loader-1x1"] = defines.relative_gui_type.loader_gui,
        ["car"] = defines.relative_gui_type.car_gui,
        ["cargo-wagon"] = defines.relative_gui_type.container_gui,
        ["spider-vehicle"] = defines.relative_gui_type.spider_vehicle_gui,
        ["mining-drill"] = defines.relative_gui_type.mining_drill_gui,
        ["inserter"] = defines.relative_gui_type.inserter_gui,
    }
    local relative_gui_type = guis_table[fh_util.get_effective_type(player_global.entity)]
    if not relative_gui_type then
        relative_gui_type = defines.relative_gui_type.inserter_gui
    end

    local anchor = {
        gui = relative_gui_type,
        position = defines.relative_gui_position.right
    }

    ---@type LuaGuiElement
    local main_frame = player_global.player.gui.relative.add {
        type = "frame",
        name = "main_frame",
        anchor = anchor,
        style = "fh_content_frame",
    }
    -- limit the height of the relative gui to fit 10 buttons per column
    -- if there are too many buttons, the scroll-pane allows them to be scrolled
    -- to be visible
    main_frame.style.maximal_height = buttons_per_column * 44
    main_frame.style.horizontally_stretchable = false

    player_global.elements.main_frame = main_frame

    ---@type LuaGuiElement
    local content_frame = main_frame.add {
        type = "scroll-pane",
        name = "content_frame",
        direction = "vertical",
    }
    content_frame.style.top_margin = 8

    ---@type LuaGuiElement
    local button_frame = content_frame.add {
        type = "frame",
        name = "button_frame",
        direction = "vertical",
        style = "fh_deep_frame",
    }

    -- use multiple columns if there are lots of buttons so its less
    -- likely to require the scroll pane for large amounts of found
    -- items to filter
    -- the scroll bar may still appear because the number of columns
    -- is capped to prevent the relative gui taking up too much horizontal space
    local items = player_global.items
    local item_count = 0
    for _ in pairs(items) do
        item_count = item_count + 1
    end
    local columns = math.ceil(item_count / buttons_per_column)
    columns = math.min(columns, max_columns)
    columns = math.max(columns, 1)

    ---@type LuaGuiElement
    local button_table = button_frame.add {
        type = "table",
        name = "button_table",
        column_count = columns,
        style = "filter_slot_table"
    }
    player_global.elements.button_table = button_table
end

---@param player LuaPlayer
local function init_global(player)
    ---@class PlayerTable
    storage.players[player.index] = {
        player = player,
        elements = {},
        items = {}, ---@type table<string, ItemWithQuality>
        active_items = {}, ---@type table<string, ItemWithQuality>
        entity = nil, ---@type LuaEntity?
    }
end

local FilterHelper = {}

function FilterHelper.add_items_belt_inventory(entity, items)
    if entity.type == "entity-ghost" then
        return
    end
    for i = 1, entity.get_max_transport_line_index() do
        for _, item in pairs(entity.get_transport_line(i).get_contents()) do
            fh_util.add_item_to_table(items, item)
        end
    end
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---@param upstream uint?
---@param downstream uint?
---Adds to the filter item list for a transport belt
function FilterHelper.add_items_belt(entity, items, upstream, downstream)
    --TODO user config for this
    upstream = upstream or 10 -- number of belts upstream (inputs) of this belt to check for filter items
    downstream = downstream or 10 -- number of belts downstream (outputs) of this belt to check for filter items

    local effective_type = fh_util.get_effective_type(entity)
    if contains({ "transport-belt", "splitter", "lane-splitter", "underground-belt", "loader", "loader-1x1" }, effective_type) then
        FilterHelper.add_items_belt_inventory(entity, items)
        if upstream > 0 then
            for _, belt in pairs(entity.belt_neighbours.inputs) do
                FilterHelper.add_items_belt(belt, items, upstream - 1, 0)
            end
        end
        if downstream > 0 then
            for _, belt in pairs(entity.belt_neighbours.outputs) do
                FilterHelper.add_items_belt(belt, items, 0, downstream - 1)
            end
        end
    end
    if effective_type == "underground-belt" then
        FilterHelper.add_items_belt_inventory(entity, items)
        if upstream > 0 and entity.belt_to_ground_type == "output" and entity.neighbours then
            FilterHelper.add_items_belt(entity.neighbours, items, upstream - 1, 0)
        end
        if downstream > 0 and entity.belt_to_ground_type == "input" and entity.neighbours then
            FilterHelper.add_items_belt(entity.neighbours, items, 0, downstream - 1)
        end
    end
end

local function crafter_has_quality(entity)
    if entity.effects and entity.effects.quality and entity.effects.quality > 0 then
        return true
    end
    local proxy = entity
    if entity.type ~= "entity-ghost" then
        proxy = entity.surface.find_entity("item-request-proxy", entity.position)
        if not proxy or proxy.proxy_target ~= entity then
            return false
        end
    end
    for _, request in pairs(proxy.item_requests) do
        local module = prototypes.item[request.name]
        if module and module.type == "module" then
            local effects = module.module_effects
            if effects and effects.quality and effects.quality > 0 then
                return true
            end
        end
    end
    return false
end

---@param target LuaEntity
---@param items table<string, ItemWithQuality>
---Adds to the filter item list based on an entity being taken from
function FilterHelper.add_items_pickup_target_entity(target, items)
    if call_items_hook("pickup_target", target, items) then
        return
    end

    local inventory = target.get_output_inventory()
    if target.type == "proxy-container" and target.proxy_target_entity then
        inventory = target.proxy_target_entity.get_inventory(target.proxy_target_inventory)
    end
    add_inventory_items(items, inventory)
    FilterHelper.add_items_assembling_machine_output(target, items)
    FilterHelper.add_items_fuel_entity_output(target, items)
    FilterHelper.add_items_transport_belt_connectable(target, items)
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---Adds to the filter item list based on an assembling machine being taken from
function FilterHelper.add_items_assembling_machine_output(target, items)
    if fh_util.get_effective_type(target) == "assembling-machine" then
        local recipe, quality = target.get_recipe()
        if not recipe then
            return
        end

        -- Add spoiled ingredients as outputs
        for _, ingredient in pairs(recipe.ingredients) do
            if ingredient.type == "item" then
                fh_util.add_item_to_table(items, prototypes.item[ingredient.name].spoil_result, quality)
            end
        end

        -- Add quality outputs
        local has_quality = crafter_has_quality(target)
        local skip_locked_qualities = settings.global["fh-show-only-unlocked-qualities"].value
        while quality do
            for _, product in pairs(recipe.products) do
                if product.type == "item" then
                    fh_util.add_item_to_table(items, product, quality)
                end
            end
            if not has_quality then
                break
            end
            quality = quality.next
            if quality and skip_locked_qualities and not target.force.is_quality_unlocked(quality) then
                break
            end
        end
    end
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---Adds to the filter item list based on the fuel the entity burns
function FilterHelper.add_items_fuel_entity_input(entity, items)
    if not (entity.burner and entity.burner.valid) then
        return
    end

    for fuel_category, _ in pairs(entity.burner.fuel_categories) do
        for _, item_prototype in pairs(get_items_by_fuel_category(fuel_category)) do
            fh_util.add_item_to_table(items, item_prototype)
        end
    end
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---Adds to the filter item list based on the fuel the entity burns, burnt/spoiler result
function FilterHelper.add_items_fuel_entity_output(entity, items)
    if not (entity.burner and entity.burner.valid) then
        return
    end

    for fuel_category, _ in pairs(entity.burner.fuel_categories) do
        for _, item_prototype in pairs(get_items_by_fuel_category(fuel_category)) do
            fh_util.add_item_to_table(items, item_prototype.burnt_result)
            fh_util.add_item_to_table(items, item_prototype.spoil_result)
        end
    end
end

---@param target LuaEntity
---@param items table<string, ItemWithQuality>
---Adds to the filter item list based on an entity being given to
function FilterHelper.add_items_drop_target_entity(target, items)
    if call_items_hook("drop_target", target, items) then
        return
    end

    if contains({ "assembling-machine", "rocket-silo" }, fh_util.get_effective_type(target)) then
        local recipe, quality = target.get_recipe()
        if recipe then
            for _, ingredient in pairs(recipe.ingredients) do
                if ingredient.type == "item" then
                    fh_util.add_item_to_table(items, ingredient, quality)
                end
            end
        end
    end
    FilterHelper.add_items_fuel_entity_input(target, items)
    FilterHelper.add_items_transport_belt_connectable(target, items)
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---@param ignore_slots boolean?
---Adds to the filter item list for an inserter
function FilterHelper.add_items_inserter(entity, items, ignore_slots, ignored_entity)
    if fh_util.get_effective_type(entity) == "inserter" and (ignore_slots or entity.filter_slot_count > 0) then
        for _, target in pairs(entity.surface.find_entities_filtered { position = entity.pickup_position }) do
            if target ~= ignored_entity and not target.prototype.has_flag("no-automated-item-removal") then
                FilterHelper.add_items_pickup_target_entity(target, items)
            end
        end
        for _, target in pairs(entity.surface.find_entities_filtered { position = entity.drop_position }) do
            if target ~= ignored_entity and not target.prototype.has_flag("no-automated-item-insertion") then
                FilterHelper.add_items_drop_target_entity(target, items)
            end
        end
    end
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---Adds to the filter item list based on the connected transport belts
function FilterHelper.add_items_transport_belt_connectable(entity, items)
    FilterHelper.add_items_belt(entity, items, nil, nil)
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---Adds to the filter item list for a splitter
function FilterHelper.add_items_splitter(entity, items)
    if not contains({ "splitter", "lane-splitter" }, fh_util.get_effective_type(entity)) then
        return
    end

    for _, always_shown_item in pairs(util.split(settings.global["fh-default-item-on-splitter"].value, ",")) do
        if always_shown_item and always_shown_item ~= "" then
            if prototypes.item[always_shown_item] then
                fh_util.add_item_to_table(items, always_shown_item)
            else
                game.print("FilterHelper: Unknown default item " .. always_shown_item)
            end
        end
    end

    FilterHelper.add_items_transport_belt_connectable(entity, items)
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---Adds to the filter item list for a loader
function FilterHelper.add_items_loader(entity, items)
    if not contains({ "loader", "loader-1x1" }, fh_util.get_effective_type(entity)) then
        return
    end

    FilterHelper.add_items_transport_belt_connectable(entity, items)

    if entity.type ~= "entity-ghost" and entity.loader_container and entity.loader_container.valid then
        if entity.loader_type == "input" then
            FilterHelper.add_items_drop_target_entity(entity.loader_container, items)
        elseif entity.loader_type == "output" then
            FilterHelper.add_items_pickup_target_entity(entity.loader_container, items)
        end
    end
end

---@param entity LuaEntity
---@param items table <string, ItemWithQuality>
---Adds to the filter item list based on the connected circuit signals
function FilterHelper.add_items_circuit(entity, items)
    if entity.get_control_behavior() then
        local control = entity.get_control_behavior()
        if control and (
            control.type == defines.control_behavior.type.generic_on_off
                or control.type == defines.control_behavior.type.inserter
        ) then
            local signals = entity.get_signals(defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
            if signals then
                for _, signal in pairs(signals) do
                    local signal_id = signal.signal
                    if signal_id.name and (signal_id.type == "item" or not signal_id.type) then
                        fh_util.add_item_to_table(items, signal_id)
                    end
                end
            end
        end
    end
end

---@param entity LuaEntity
---@param items table <string, ItemWithQuality>
function FilterHelper.add_items_chest(entity, items)
    if contains({ "container", "logistic-container" }, fh_util.get_effective_type(entity)) then
        -- contents
        add_inventory_items(items, entity.get_output_inventory())

        -- relevant inserters
        local bb = entity.bounding_box
        local distance = 3
        local area = { { bb.left_top.x - distance, bb.left_top.y - distance }, { bb.right_bottom.x + distance, bb.right_bottom.y + distance } }

        for _, inserter in pairs(entity.surface.find_entities_filtered { type = "inserter", area = area }) do
            if inserter.pickup_target == entity or inserter.drop_target == entity then
                FilterHelper.add_items_inserter(inserter, items, true, entity)
            end
        end
    end
end

---@param entity LuaEntity
---@param items table <string, ItemWithQuality>
function FilterHelper.add_items_vehicle(entity, items)
    -- contents
    if contains({ "car", "cargo-wagon", "spider-vehicle" }, fh_util.get_effective_type(entity)) then
        for _, inventory_type in pairs { defines.inventory.car_trunk, defines.inventory.cargo_wagon, defines.inventory.spider_trunk } do
            local inventory = entity.get_inventory(inventory_type)
            if inventory then
                add_inventory_items(items, inventory)
                return
            end
        end
    end
end

---@param entity LuaEntity
---@param items table <string, ItemWithQuality>
function FilterHelper.add_items_miner(entity, items)
    -- contents
    if fh_util.get_effective_type(entity) == "mining-drill" then
        local radius = fh_util.get_effective_prototype(entity).mining_drill_radius
        for _, resource in pairs(entity.surface.find_entities_filtered {
            area = { { entity.position.x - radius, entity.position.y - radius }, { entity.position.x + radius, entity.position.y + radius } },
            type = "resource",
        }) do
            fh_util.add_item_to_table(items, resource)
        end
    end
end

---@param entity LuaEntity
---@param items table<string, ItemWithQuality>
---@return table<string, ItemWithQuality>
---Adds to the filter item list for the given entity
function FilterHelper.add_items(entity, items)
    FilterHelper.add_items_inserter(entity, items)
    FilterHelper.add_items_splitter(entity, items)
    FilterHelper.add_items_loader(entity, items)
    --TODO have a second column for signals
    FilterHelper.add_items_circuit(entity, items)
    FilterHelper.add_items_chest(entity, items)
    FilterHelper.add_items_vehicle(entity, items)
    FilterHelper.add_items_miner(entity, items)
    return items
end

local function update_ui(player_global, check_items)
    if not player_global.entity or not player_global.entity.valid then
        return
    end
    local updater = get_filter_updater(player_global.entity)
    if not updater then
        return
    end

    local interface_open = player_global.elements.main_frame and player_global.elements.main_frame.valid
    local update_interface = false

    if check_items or interface_open then
        local old_active_items = player_global.active_items
        player_global.active_items = updater.get_active_items()
        for item_id, item in pairs(player_global.active_items) do
            player_global.items[item_id] = item
        end
        if not table.compare(player_global.active_items, old_active_items) then
            update_interface = true
        end
    end
    if check_items then
        local old_item_count = table_size(player_global.items)
        FilterHelper.add_items(player_global.entity, player_global.items)
        if table_size(player_global.items) > old_item_count then
            update_interface = true
        end
    end
    if not interface_open and (next(player_global.items) or next(player_global.active_items)) then
        update_interface = true
    end

    if update_interface then
        if not interface_open then
            build_interface(player_global)
        end
        build_sprite_buttons(player_global, updater)
    end
end

script.on_init(function()
    ---@type table<number, PlayerTable>
    storage.players = {}
    for _, player in pairs(game.players) do
        init_global(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    init_global(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_pre_player_removed, function(event)
    storage.players[event.player_index] = nil
end)

-- EVENT on_gui_opened
script.on_event(defines.events.on_gui_opened, function(event)
    -- the entity that is opened
    local player_global = get_player_global(event.player_index)
    if player_global and event.entity and fh_util.get_effective_type(event.entity) ~= "proxy-container" then
        player_global.entity = event.entity
        update_ui(player_global, true)
    end
end)

--EVENT on_gui_closed
script.on_event(defines.events.on_gui_closed, function(event)
    local player_global = get_player_global(event.player_index)
    if player_global.elements.main_frame then
        player_global.elements.main_frame.destroy()
    end
    player_global.entity = nil
    player_global.items = {}
    player_global.active_items = {}
end)

--EVENT on_gui_click
script.on_event(defines.events.on_gui_click, function(event)
    local player_global = get_player_global(event.player_index)
    if not player_global then
        return
    end

    local entity = player_global.entity
    local clicked_item = event.element.tags.item
    local action = event.element.tags.action

    if entity and entity.valid and (action == "fh_select_button" or action == "fh_deselect_button") then
        local updater = get_filter_updater(entity)
        if not updater then
            return
        end
        local command
        if event.button == defines.mouse_button_type.left then
            command = updater.add
        elseif event.button == defines.mouse_button_type.right then
            command = updater.remove
        end

        local fail_message = command(clicked_item, { alt = event.alt, control = event.control, shift = event.shift })
        if fail_message then
            -- Play fail sound if filter slots are full or empty
            entity.surface.play_sound { path = "utility/cannot_build", volume_modifier = 1.0 }
            player_global.player.create_local_flying_text { text = fail_message, create_at_cursor = true }
        end
        update_ui(player_global)
    end
end)

script.on_event(defines.events.on_tick, function(event)
    for _, player in pairs(game.players) do
        local player_global = get_player_global(player.index)
        if player_global then
            update_ui(player_global, event.tick % 60 == 0)
        end
    end
end)

-- TODO options for what things are considered. Chests, transport lines, etc
-- TODO recently used section
