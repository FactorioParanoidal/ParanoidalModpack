--(( Copy Chest ))--
local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')

local table = require('__stdlib__/stdlib/utils/table')
local interface = require('__stdlib__/stdlib/scripts/interface')

local chest_types = {
    ['container'] = true,
    ['logistic-container'] = true,
    ['cargo-wagon'] = true
}

local api_check = 'picker_chest_contents_mover_check'

local function flying_text(player, text, position)
    return player.create_local_flying_text{text = text, position = position}
end

-- Copy on empty spot, nil copy_src
-- on paste, check for copy_src
-- Should allow stacking keybinds

local function copy_chest(event)
    local player, pdata = Player.get(event.player_index)
    local chest = player.selected

    if not chest then
        pdata.copy_src = nil
        return
    end

    if pdata.copy_src then
        -- Used for same keybind
        return
    end

    if not chest_types[chest.type] then
        return flying_text(player, {'chest.containers'}, chest.position)
    end

    if global.blacklisted_chests[chest.name] then
        return flying_text(player, {'chest.blacklisted', chest.localised_name}, chest.position)
    end

    local p_force, c_force = player.force, chest.force
    if not (p_force == c_force or c_force.name == 'neutral' or c_force.get_friend(p_force)) then
        return flying_text(player, {'cant-transfer-from-enemy-structures'}, chest.position)
    end

    local inventory = chest.get_inventory(defines.inventory.chest)
    if not inventory.is_empty() then
        pdata.copy_src = {
            inv = inventory,
            surface = chest.surface,
            ent = chest,
            tick = event.tick
        }
       return flying_text(player, {'chest.copy-src'}, chest.position)
    else
        return flying_text(player, {'chest.empty-src'}, chest.position)
    end
end
Event.register('picker-copy-chest', copy_chest)

local function paste_chest(event)
    local player, pdata = Player.get(event.player_index)
    local chest = player.selected

    if not chest then
        return
    end

    if not (pdata.copy_src and pdata.copy_src.tick ~= event.tick) then
        return
    end

    if not chest_types[chest.type] then
        return flying_text(player, {'chest.containers'}, chest.position)
    end

    local p_force, c_force = player.force, chest.force
    if not (p_force == c_force or c_force.name == 'neutral' or c_force.get_friend(p_force)) then
        return flying_text(player, {'cant-transfer-to-enemy-structures'}, chest.position)
    end

    if global.blacklisted_chests[chest.name] then
        return flying_text(player, {'chest.blacklisted', chest.localised_name}, chest.position)
    end

    if not (pdata.copy_src.inv and pdata.copy_src.inv.valid and not pdata.copy_src.inv.is_empty()) then
        pdata.copy_src = nil
        return flying_text(player, {'chest.no-copy-from'}, chest.position)
    end

    if chest == pdata.copy_src.ent then
        return flying_text(player, {'chest.same-inventory'}, chest.position)
    end

    if pdata.copy_src.surface ~= chest.surface and not settings.global['picker-copy-between-surfaces'].value then
        return flying_text(player, {'chest.not-same-surface'}, chest.position)
    end

    local interfaces = remote.interfaces
    for name in pairs(interfaces) do
        if interfaces[name][api_check] then
            if not remote.call(name, api_check, pdata.copy_src.ent, chest) then
                return
            end
        end
    end

    local count = chest.get_item_count()
    local src = pdata.copy_src.inv
    for i = 1, #src do
        local stack = src[i]
        if stack.valid_for_read then
            stack.count = stack.count - chest.insert(stack)
        end
    end

    if src.is_empty() then
        pdata.copy_src = nil
        return flying_text(player, {'chest.all-moved'}, chest.position)
    elseif count == chest.get_item_count() then
        return flying_text(player, {'chest.none-moved'}, chest.position)
    else
        return flying_text(player, {'chest.some-moved'}, chest.position)
    end
end
Event.register('picker-paste-chest', paste_chest)

local function update_global()
    global.blacklisted_chests = global.blacklisted_chests or {}
end
Event.register(Event.core_events.init_and_config, update_global)

function interface.set_blacklisted_chests(names, remove)
    global.blacklisted_chests = global.blacklisted_chests or {}
    if type(names) == 'string' then
        global.blacklisted_chests[names] = (not remove and true) or nil
        return true
    elseif type(names) == 'table' then
        for _, name in pairs(names) do
            global.blacklisted_chests[name] = (not remove and true) or nil
        end
        return true
    end
end

function interface.get_blacklisted_chests()
    global.blacklisted_chests = global.blacklisted_chests or {}
    return table.keys(global.blacklisted_chests)
end
