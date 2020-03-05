local Event = require('__stdlib__/stdlib/event/event')
local Gui = require('__stdlib__/stdlib/event/gui')
local mod_gui = require('mod-gui')

local function change_button_state(gui, type)
    local b_name = 'picker-eq-button-' .. type
    if gui[b_name] then
        gui[b_name].destroy()
    else
        gui.add {
            type = 'sprite-button',
            name = b_name,
            tooltip = {'equipment-hotkeys.tooltip', {'equipment-types.' .. type}},
            sprite = b_name
            -- hovered_sprite ='',
            -- clicked_sprite = ''
        }
    end
end

local function toggle_armor_modules(event, name, types)
    local player = game.players[event.player_index]
    local grid = player.character and player.character.grid
    if grid then
        local status = 'notfound'
        local equip_locale

        for eq_name in pairs(types or {[name] = true}) do
            for _, equipment in pairs(grid.equipment) do
                if equipment.name:gsub('^picker%-disabled%-', '') == eq_name then
                    if status == 'notfound' then
                        status = equipment.name:find('^picker%-disabled%-') and 'enable' or 'disable'
                    end
                    if status ~= 'notfound' then
                        local position, energy = equipment.position, equipment.energy
                        local new_name = status == 'enable' and eq_name or status == 'disable' and 'picker-disabled-' .. eq_name
                        grid.take(equipment)
                        local new_equip = grid.put {name = new_name, position = position}
                        if new_equip then
                            new_equip.energy = energy
                        end
                        local gui = mod_gui.get_button_flow(player)
                        change_button_state(gui, new_equip.type)
                    end
                end
            end
            equip_locale = types and types[eq_name] or {'equipment-name.' .. eq_name}
        end
        player.print({'equipment-hotkeys.' .. status, equip_locale})
    end
end

-- Switch out newly placed equipment to the correct state (enabled or disabled)
local function place_equipment(event)
    local grid = event.grid
    local placed = event.equipment
    if game.equipment_prototypes['picker-disabled-' .. placed.name] then
        for _, equipment in pairs(grid.equipment) do
            if equipment ~= placed then
                if placed.type == equipment.type and equipment.name:find('^picker%-disabled%-') then
                    local new = {name = 'picker-disabled-' .. placed.name, position = placed.position}
                    grid.take(placed)
                    grid.put(new)
                    break
                end
            end
        end
    end
end
Event.register(defines.events.on_player_placed_equipment, place_equipment)

local function toggle_from_gui(event)
    local pattern = event.element.name:gsub('picker%-eq%-button%-', '')
    toggle_armor_modules(event, 'equipment-bot-chip-all', global.equipment_list[pattern] or {})
end
Gui.on_click('picker%-eq%-button%-', toggle_from_gui)

local function on_init()
    global.equipment_list = {}
    for _, eq in pairs(game.equipment_prototypes) do
        if not eq.name:find('^picker%-disabled%-') and game.equipment_prototypes['picker-disabled-' .. eq.name] then
            global.equipment_list[eq.type] = global.equipment_list[eq.type] or {}
            global.equipment_list[eq.type][eq.name] = {'equipment-types.' .. eq.type} -- To get the locale
        end
    end
end
Event.register(Event.core_events.init_and_config, on_init)

Event.armor_hotkeys = Event.armor_hotkeys or {}
Event.armor_hotkeys['toggle-equipment-night-vision'] = function(event)
    toggle_armor_modules(event, 'equipment-bot-chip-all', global.equipment_list['night-vision-equipment'] or {})
end
Event.armor_hotkeys['toggle-equipment-active-defense'] = function(event)
    toggle_armor_modules(event, 'equipment-bot-chip-all', global.equipment_list['active-defense-equipment'] or {})
end
Event.armor_hotkeys['toggle-equipment-bot-chip-trees'] = function(event)
    if game.active_mods['Nanobots'] then
        toggle_armor_modules(event, 'equipment-bot-chip-trees')
    end
end
Event.armor_hotkeys['toggle-equipment-bot-chip-items'] = function(event)
    if game.active_mods['Nanobots'] then
        toggle_armor_modules(event, 'equipment-bot-chip-items')
    end
end
Event.armor_hotkeys['toggle-equipment-bot-chip-launcher'] = function(event)
    if game.active_mods['Nanobots'] then
        toggle_armor_modules(event, 'equipment-bot-chip-launcher')
    end
end
Event.armor_hotkeys['toggle-equipment-bot-chip-feeder'] = function(event)
    if game.active_mods['Nanobots'] then
        toggle_armor_modules(event, 'equipment-bot-chip-feeder')
    end
end
Event.armor_hotkeys['toggle-equipment-bot-chip-nanointerface'] = function(event)
    if game.active_mods['Nanobots'] then
        toggle_armor_modules(event, 'equipment-bot-chip-nanointerface')
    end
end

for event_name in pairs(Event.armor_hotkeys) do
    Event.register(event_name, Event.armor_hotkeys[event_name])
end
