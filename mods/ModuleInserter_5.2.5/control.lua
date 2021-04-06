local event = require("__flib__.event")
local gui = require("__flib__.gui-beta")
local mod_gui = require("__core__.lualib.mod-gui")
local migration = require("__flib__.migration")
local mi_gui = require("scripts.gui")
local table = require("__flib__.table")

local lib = require "__ModuleInserter__/lib_control"
local debugDump = lib.debugDump

local function compare_contents(tbl1, tbl2)
    if tbl1 == tbl2 then return true end
    for k, value in pairs(tbl1) do
        if (value ~= tbl2[k]) then return false end
    end
    for k, _ in pairs(tbl2) do
        if tbl1[k] == nil then return false end
    end
    return true
end

local function sort_modules(entity, modules, cTable)
    --Don't sort empty inventories
    if not next(modules) then return end
    local inventory = entity.get_module_inventory()
    local contents = inventory and inventory.get_contents()
    if compare_contents(cTable, contents) then
        local status, err = pcall(function()
            inventory.clear()
            local insert = inventory.insert
            for _, module in pairs(modules) do
                if module then
                    insert{name = module, count = 1}
                end
            end
        end)
        if not status then
            debugDump(err, true)
            inventory.clear()
            for name, count in pairs(contents) do
                inventory.insert{name = name, count = count}
            end
        end
    end
end

local function on_mod_item_opened(e)
    e.player = game.get_player(e.player_index)
    e.pdata = global._pdata[e.player_index]
    if not e.pdata.gui_open then
        mi_gui.open(e)
    end
end
event.on_mod_item_opened(on_mod_item_opened)

event.register("toggle-module-inserter", function(e)
    e.player = game.get_player(e.player_index)
    e.pdata = global._pdata[e.player_index]
    mi_gui.toggle(e)
end)

local function get_module_inserter(e)
    local player = game.get_player(e.player_index)
    local inv = player.get_main_inventory()
    local mi = inv.find_item_stack("module-inserter")
    if mi then
        mi.swap_stack(player.cursor_stack)
    else
        player.clear_cursor()
        player.cursor_stack.set_stack{name = "module-inserter", count = 1}
    end
end

event.register("get-module-inserter", get_module_inserter)

event.on_lua_shortcut(function(e)
    if e.prototype_name == "module-inserter" then
        get_module_inserter(e)
    end
end)

event.register("mi-confirm-gui", function(e)
    local pdata =  global._pdata and global._pdata[e.player_index]
    if pdata and pdata.gui_open and not pdata.pinned then
        e.pdata = pdata
        e.player = game.get_player(e.player_index)
        mi_gui.handlers.main.apply_changes(e)
    end
end)

local function drop_module(entity, name, count, module_inventory, chest, create_entity)
    if not (chest and chest.valid) then
        chest = create_entity{
            name = "module_inserter_pickup",
            position = entity.position,
            force = entity.force,
            create_build_effect_smoke = false
        }
        if not (chest and chest.valid) then
            error("Invalid chest")
        end
    end

    local stack = {name = name, count = count}
    stack.count = chest.insert(stack)
    if module_inventory.remove(stack) ~= stack.count then
        log("Not all modules removed")
    end
    return chest
end

local function print_planner(planner)--luacheck: ignore
    for i = 1, 4 do
        log(serpent.line(planner.get_mapper(i, "from")) .. serpent.line(planner.get_mapper(i, "to")))
    end
end

--TODO: figure out which modules can be replaced via upgrade item
--only 1 type desired
--multiple module types if:
--  amounts can be matched from contents to desired
local function create_upgrade_planner(contents, desired, desired_count, upgrade_planner)
    if desired_count == 0 or table_size(contents) == 0 then return end
    if desired_count == 1 then
        local from = {type = "item", name = ""}
        local to = {type = "item", name = next(desired)}
        local i = 0
        for name, _ in pairs(contents) do
            if name ~= to.name then
                i = i + 1
                from.name = name
                upgrade_planner.set_mapper(i, "from", from)
                upgrade_planner.set_mapper(i, "to", to)
            end
        end
        if i > 0 then
            return upgrade_planner
        end
    end
    local matches = {}
    local assigned = {}
    --"upgrading" to the same module
    for name, c in pairs(contents) do
        if desired[name] and desired[name] == c then
            matches[name] = name
            assigned[name] = name
        end
    end
    for name, c in pairs(contents) do
        for name_d, c_d in pairs(desired) do
            if c == c_d and not matches[name] and not assigned[name_d] then
                matches[name] = name_d
                assigned[name_d] = name
            end
        end
    end
    if desired_count == table_size(matches) then
        local from = {type = "item", name = ""}
        local to = {type = "item", name = next(desired)}
        local i = 0
        for name, name_d in pairs(matches) do
            if name ~= name_d then
                from.name = name
                to.name = name_d
                i = i + 1
                upgrade_planner.set_mapper(i, "from", from)
                upgrade_planner.set_mapper(i, "to", to)
            end
        end
        if i > 0 then
            return upgrade_planner
        end
    end
end

local function create_request_proxy(entity, modules, desired, proxies, player, create_entity, upgrade_planner)
    local module_inventory = entity.get_module_inventory()
    if not module_inventory then
        return proxies
    end

    local contents = module_inventory.get_contents()
    local same = compare_contents(desired, contents)
    local desired_count = table_size(desired)
    local needs_sorting = desired_count > 1

    if same then
        if needs_sorting then
            sort_modules(entity, modules, desired)
        end
        return proxies
    end

    local planner = create_upgrade_planner(contents, desired, desired_count, upgrade_planner)
    if planner then
        --print_planner(planner)
        entity.surface.upgrade_area{area = entity.bounding_box, force = player.force, player = player, item = planner, skip_fog_of_war = false}
        planner.clear_upgrade_item()
        --print_planner(planner)
        local to_add = table_size(modules) - module_inventory.get_item_count()
        local irp
        if desired_count > 1 or to_add > 0 then
            irp = entity.surface.find_entity("item-request-proxy", entity.position)
        end
        if to_add > 0 and desired_count == 1 and irp then
            --find created proxy and change item requests
            local to = {type = "item", name = next(desired)}
            local requests = irp.item_requests
            requests[to.name] = desired[to.name] - (contents[to.name] or 0)
            irp.item_requests = requests
            return proxies
        end
        if to_add == 0 then
            if irp and needs_sorting then
                script.register_on_entity_destroyed(irp)
                proxies[irp.unit_number] = {modules = modules, cTable = desired, target = entity}
            end
            return proxies
        end
    end

    local missing = {}
    --local surplus = {}
    local changed
    local diff
    local chest = false
    --Drop all modules and done
    if desired_count == 0 then
        for name, count in pairs(contents) do
            chest = drop_module(entity, name, count, module_inventory, chest, create_entity)
        end
        if chest and chest.valid then
            if player and player.valid then
                chest.order_deconstruction(chest.force, player)
            else
                chest.order_deconstruction(chest.force)
            end
        end
        return proxies
    end
    --Request all modules and done
    if not next(contents) then
        missing = desired
        local ghost = create_entity{
            name = "item-request-proxy",
            position = entity.position,
            force = entity.force,
            target = entity,
            modules = missing,
            raise_built = true
        }
        if ghost and needs_sorting then
            script.register_on_entity_destroyed(ghost)
            proxies[ghost.unit_number] = {modules = modules, cTable = desired, target = entity}
        end
        return proxies
    end
    for name, count in pairs(desired) do
        diff = (contents[name] or 0) - count -- >0: drop, < 0 missing
        contents[name] = nil
        if diff < 0 then
            missing[name] = -1 * diff
        elseif diff > 0 then
            chest = drop_module(entity, name, diff, module_inventory, chest, create_entity)
            --surplus[name] = diff
        end
    end
    for name, count in pairs(contents) do
        diff = count - (desired[name] or 0) -- >0: drop, < 0 missing
        --assert(not missing[name] and not surplus[name])
        if diff < 0 then
            missing[name] = -1 * diff
        elseif diff > 0 then
            chest = drop_module(entity, name, diff, module_inventory, chest, create_entity)
            --surplus[name] = diff
            changed = true
        end
    end
    if chest and chest.valid then
        if player and player.valid then
            chest.order_deconstruction(chest.force, player)
        else
            chest.order_deconstruction(chest.force)
        end
    end
    if changed then
        contents = module_inventory.get_contents()
        same = compare_contents(desired, contents)
    end
    if not same and next(missing) then
        local ghost = create_entity{
            name = "item-request-proxy",
            position = entity.position,
            force = entity.force,
            target = entity,
            modules = missing,
            raise_built = true
        }
        if ghost and needs_sorting then
            script.register_on_entity_destroyed(ghost)
            proxies[ghost.unit_number] = {modules = modules, cTable = desired, target = entity}
        end
    end
    return proxies
end

local function delayed_creation(e)
    local current = global.to_create[e.tick]
    if current then
        local proxies = global.proxies
        local ent
        local upgrade_inventory = game.create_inventory(1)
        upgrade_inventory.insert{name = "upgrade-planner"}
        for _, data in pairs(current) do
            ent = data.entity
            if ent and ent.valid then
                proxies = create_request_proxy(ent, data.modules, data.cTable, proxies, data.player, data.surface.create_entity, upgrade_inventory[1])
            end
        end
        upgrade_inventory.destroy()
        global.proxies = proxies
        global.to_create[e.tick] = nil
        script.on_nth_tick(e.nth_tick, nil)
    end
end

local function conditional_events(check)
    if check then
        for tick, to_create in pairs(global.to_create) do
            for id, data in pairs(to_create) do
                if not (data.entity and data.entity.valid) then
                    to_create[id] = nil
                end
            end
            if not next(to_create) then
                global.to_create[tick] = nil
            end
        end
    end
    for tick in pairs(global.to_create) do
        script.on_nth_tick(tick, delayed_creation)
    end
end

local function modules_allowed(recipe, modules)
    local restricted_modules = global.restricted_modules
    for module, _ in pairs(modules) do
        if restricted_modules[module] and not restricted_modules[module][recipe] then
            return false
        end
    end
    return true
end

local function on_player_selected_area(e)
    local status, err = pcall(function()
        local player_index = e.player_index
        if e.item ~= "module-inserter" or not player_index then return end
        local player = game.get_player(player_index)
        local pdata = global._pdata[player_index]
        local config = pdata.config_by_entity
        if not config then
            player.print({"module-inserter-config-not-set"})
            return
        end
        local ent_type, ent_name, target
        local surface = player.surface
        local delay = e.tick
        local max_proxies = settings.global["module_inserter_proxies_per_tick"].value
        local message = false
        for i, entity in pairs(e.entities) do
            ent_name = entity.name
            --remove existing proxies if we have a config for it's target
            if ent_name == "item-request-proxy" then
                target = entity.proxy_target
                if target and target.valid and config[target.name] then
                    entity.destroy{raise_destroy = true}
                end
                goto continue
            end

            local entity_configs = config[ent_name]
            if not entity_configs then
                goto continue
            end

            ent_type = entity.type
            local recipe = ent_type == "assembling-machine" and entity.get_recipe()
            recipe = recipe and recipe.name
            local entity_config = nil
            local cTable = nil
            if recipe then
                for _, e_config in pairs(entity_configs) do
                    if e_config.limitations then
                        if modules_allowed(recipe, e_config.cTable) then
                            entity_config = e_config
                            cTable = e_config.cTable
                            break
                        else
                            message = "item-limitation.production-module-usable-only-on-intermediates"
                        end
                    else
                        entity_config = e_config
                        cTable = e_config.cTable
                        break
                    end
                end
            else
                entity_config = entity_configs[1]
                cTable = entity_config.cTable
            end
            if entity_config then
                if (i % max_proxies == 0) then
                    delay = delay + 1
                end
                if not global.to_create[delay] then global.to_create[delay] = {} end
                global.to_create[delay][entity.unit_number] = {
                    entity = entity,
                    modules = table.shallow_copy(entity_config.to),
                    cTable = table.shallow_copy(cTable),
                    player = player,
                    surface = surface
                }
            end
            ::continue::
        end
        if message then
            player.print({message})
        end
        conditional_events()
    end)
    if not status then
        debugDump(err, true)
        conditional_events(true)
    end
end

local function on_player_alt_selected_area(e)
    local status, err = pcall(function()
        if not e.item == "module-inserter" then return end
        for _, entity in pairs(e.entities) do
            if entity.name == "item-request-proxy" then
                entity.destroy{raise_destroy = true}
            end
        end
        conditional_events()
    end)
    if not status then
        debugDump(err, true)
        conditional_events(true)
    end
end

local function se_grounded_entity(name)
    local result = name:sub(-9) == "-grounded" -- -#"grounded"
    return result
end

local function create_lookup_tables()
    global.nameToSlots = {}
    global.module_entities = {}
    local i = 1
    for name, prototype in pairs(game.entity_prototypes) do
        if prototype.module_inventory_size and prototype.module_inventory_size > 0 and not se_grounded_entity(name) then
            global.nameToSlots[name] = prototype.module_inventory_size
            global.module_entities[i] = name
            i = i + 1
        end
    end
    global.restricted_modules = {}
    local limitations
    for name, module in pairs(game.item_prototypes) do
        if module.type == "module" then
            limitations = module.limitations
            if limitations and next(limitations) then
                global.restricted_modules[name] = {}
                for _, recipe in pairs(limitations) do
                    global.restricted_modules[name][recipe] = true
                end
            end
        end
    end
end

local function remove_invalid_items()
    local items = game.item_prototypes
    local entities = game.entity_prototypes
    local removed_entities = {}
    local removed_modules = {}
    local function _remove(tbl)
        for _, config in pairs(tbl) do
            if (config.from or config.from == false) and not entities[config.from] then
                removed_entities[config.from] = true
                config.from = nil
                config.to = {}
                config.cTable = {}
            end
            config.limitations = nil
            for k, m in pairs(config.to) do
                if m and not items[m] then
                    config.to[k] = nil
                    config.cTable[m] = nil
                    removed_modules[config.from] = true
                end
                if global.restricted_modules[m] then
                    config.limitations = true
                end
            end
        end
    end
    for _, pdata in pairs(global._pdata) do
        _remove(pdata.config)
        if pdata.config_tmp then
            _remove(pdata.config_tmp)
        end
        for _, preset in pairs(pdata.storage) do
            _remove(preset)
        end
    end
    for k in pairs(removed_entities) do
        log("Module Inserter: Removed configuration for " ..k)
    end
    for k in pairs(removed_modules) do
        log("Module Inserter: Removed module " .. k .. " from all configurations")
    end
end

local function init_global()
    global.proxies = global.proxies or {}
    global.to_create = global.to_create or {}
    global.nameToSlots = global.nameToSlots or {}
    global.restricted_modules = global.restricted_modules or {}
    global._pdata = global._pdata or {}
end

local function init_player(i)
    init_global()
    local pdata = global._pdata[i] or {}
    global._pdata[i] = {
        last_preset = pdata.last_preset or "",
        config = pdata.config or {},
        storage = pdata.storage or {},
        gui = pdata.gui or {},
    }
    mi_gui.update_main_button(game.get_player(i))
    mi_gui.create(i)
end

local function init_players()
    for i, _ in pairs(game.players) do
        init_player(i)
    end
end

event.on_init(function()
    create_lookup_tables()
    init_global()
    init_players()
end)

event.on_load(function()
    conditional_events()
end)

local migrations = {
    ["4.1.7"]  = function()
        global = {}
        init_global()
        init_players()
        for _, player in pairs(game.players) do
            if player.gui.left.mod_gui_frame_flow and player.gui.left.mod_gui_frame_flow.valid then
                for _, egui in pairs(player.gui.left.mod_gui_frame_flow.children) do
                    if egui.get_mod() == "ModuleInserter" then
                        egui.destroy()
                    end
                end
            end
        end
    end,
    ["5.0.9"] = function()
        init_players()
        local gui_e, pdata
        for i, _ in pairs(game.players) do
            pdata = global._pdata[i]
            gui_e = pdata.gui_elements
            if gui_e then
                if gui_e.config_frame and gui_e.config_frame.valid then
                    gui_e.config_frame.destroy()
                end
                if gui_e.preset_frame and gui_e.preset_frame.valid then
                    gui_e.preset_frame.destroy()
                end
                init_player(i)
                pdata = global._pdata[i]
                if gui_e.main_button and gui_e.main_button.valid then
                    gui_e.main_button.destroy()
                end
            end
            pdata.last_preset = ""
            local config_by_entity = {}
            for _, config in pairs(pdata.config) do
                if config.from then
                    config_by_entity[config.from] = config_by_entity[config.from] or {}
                    config_by_entity[config.from][table_size(config_by_entity[config.from])+1] = {to = config.to, cTable = config.cTable, limitations = config.limitations}
                end
            end
            pdata.config_by_entity = config_by_entity

            pdata.gui_elements = nil
            pdata.gui_actions = nil
            pdata.settings = nil
        end
    end,
    ["5.1.5"] = function()
        local to_register = {}
        for _, proxies in pairs(global.proxies) do
            for _, data in pairs(proxies) do
                if data.proxy and data.target then
                    if data.proxy.valid and table_size(data.cTable) > 1 then
                        script.register_on_entity_destroyed(data.proxy)
                        to_register[data.proxy.unit_number] = {modules = data.modules, cTable = data.cTable, target = data.target}
                    end
                    if not data.proxy.valid then
                        if data.target and data.target.valid then
                            sort_modules(data.target, data.modules, data.cTable)
                        end
                    end
                end
            end
        end
        event.on_tick(nil)
        global.proxies = to_register
        conditional_events(true)
    end,
    ["5.1.7"] = function()
        for id, data in pairs(global.proxies) do
            if not (data.target and data.target.valid) then
                global.proxies[id] = nil
            end
        end
    end,
    ["5.1.8"] = function()
        for pi, pdata in pairs(global._pdata) do
            local player = game.get_player(pi)
            if player and pdata.gui.main_button and pdata.gui.main_button.valid then
                pdata.gui.main_button = nil
            elseif not player then
                global._pdata[pi] = nil
            end
        end
    end,
    ["5.1.9"] = function()
        for _, pdata in pairs(global._pdata) do
            pdata.pinned = false
        end
    end,
    ["5.2.2"] = function()
        for i, player in pairs(game.players) do
            local pdata = global._pdata[i]
            if pdata and pdata.gui then
                pdata.gui.main_button = nil
            end
            local button_flow = mod_gui.get_button_flow(player)
            local button = button_flow.module_inserter_config_button
            if button then
                gui.update_tags(button, {flib = {on_click = {gui = "mod_gui_button", action = "toggle"}}})
            end
            mi_gui.update_main_button(player)
        end
    end,
}

event.on_configuration_changed(function(e)
    create_lookup_tables()
    remove_invalid_items()
    if migration.on_config_changed(e, migrations) then
        for pi, pdata in pairs(global._pdata) do
            mi_gui.destroy(pdata, game.get_player(pi))
            mi_gui.create(pi)
        end

    end
    conditional_events(true)
end)

event.on_player_selected_area(on_player_selected_area)
event.on_player_alt_selected_area(on_player_alt_selected_area)

gui.hook_events(function(e)
    local msg = gui.read_action(e)
    if msg then
        e.player = game.get_player(e.player_index)
        e.pdata = global._pdata[e.player_index]
        local gui_handler = mi_gui.handlers[msg.gui]
        local handler = gui_handler and gui_handler[msg.action]
        if handler then
            handler(e)
        else
            e.player.print("Unhandled gui event: " .. serpent.line(msg))
        end
    end
end)

event.on_player_created(function(e)
    init_player(e.player_index)
end)

event.on_player_removed(function(e)
    global._pdata[e.player_index] = nil
end)

event.on_runtime_mod_setting_changed(function(e)
    if not e.player_index then return end
    if e.setting == "module_inserter_button_style" or e.setting == "module_inserter_hide_button" then
        mi_gui.update_main_button(game.get_player(e.player_index))
    end
end)

event.on_entity_destroyed(function(e)
    if e.unit_number and global.proxies[e.unit_number] then
        local data = global.proxies[e.unit_number]
        if data.target and data.target.valid then
            sort_modules(data.target, data.modules, data.cTable)
        end
        global.proxies[e.unit_number] = nil
    end
end)

-- event.on_player_cursor_stack_changed(function(e)
--     local player = game.get_player(e.player_index)
--     if player.cursor_stack.valid_for_read and player.cursor_stack.name == "module-inserter" then
--         global._pdata[e.player_index].cursor = true
--     elseif global._pdata[e.player_index].cursor then
--         global._pdata[e.player_index].cursor = false
--         local inv = player.get_main_inventory()
--         local count = inv.get_item_count("module-inserter")
--         if count > 1 then
--             inv.remove{name = "module-inserter", count = count - 1}
--         end
--     end
-- end)

commands.add_command("mi_clean", "", function()
    for _, egui in pairs(game.player.gui.screen.children) do
        if egui.get_mod() == "ModuleInserter" then
            egui.destroy()
        end
    end
end)