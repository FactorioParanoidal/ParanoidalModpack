local Event = require('__stdlib__/stdlib/event/event')

local shortcuts = {
    ['toggle-night-vision-equipment'] = {
        filters = {{filter = 'type', type = 'night-vision-equipment'}},
        name = '.'
    },
    ['toggle-active-defense-equipment'] = {
        filters = {{filter = 'type', type = 'active-defense-equipment'}},
        name = '.',
        automatic = true
    },
    ['toggle-equipment-bot-chip-items'] = {
        filters = {{filter = 'type', type = 'active-defense-equipment'}},
        name = 'equipment%-bot%-chip%-items'
    },
    ['toggle-equipment-bot-chip-feeder'] = {
        filters = {{filter = 'type', type = 'active-defense-equipment'}},
        name = 'equipment%-bot%-chip%-feeder'
    },
    ['toggle-equipment-bot-chip-launcher'] = {
        filters = {{filter = 'type', type = 'active-defense-equipment'}},
        name = 'equipment%-bot%-chip%-launcher'
    },
    ['toggle-equipment-bot-chip-nanointerface'] = {
        filters = {{filter = 'type', type = 'active-defense-equipment'}},
        name = 'equipment%-bot%-chip%-nanointerface'
    },
    ['toggle-equipment-bot-chip-trees'] = {
        filters = {{filter = 'type', type = 'active-defense-equipment'}},
        name = 'equipment%-bot%-chip%-trees'
    }
}

local function name_filter(protos, shortcut)
    local new_protos = {}
    for _, proto in pairs(protos) do
        if not proto.name:find('^picker%-disabled') and proto.name:find(shortcut.name) then
            if not shortcut.automatic or (shortcut.automatic and proto.automatic) then
                local disabled_proto = protos['picker-disabled-' .. proto.name]
                if disabled_proto then
                    new_protos[#new_protos + 1] = proto
                    new_protos[#new_protos + 1] = disabled_proto
                end
            end
        end
    end
    return new_protos
end

local function swap_in_place(grid, equipment, disable)
    local name = disable and ('picker-disabled-' .. equipment.name) or equipment.name:gsub('^picker%-disabled%-', '')
    local new = {name = name, position = equipment.position, energy = equipment.energy}
    if grid.take {equipment = equipment} then
        local new_eq = grid.put(new)
        if new_eq then
            new_eq.energy = new.energy
        end
        return new_eq
    end
end

-- Toggle all armor modules when toggling the shortcut/keybind
local function toggle_armor_modules(event)
    local event_name = event.prototype_name or event.input_name

    local shortcut = shortcuts[event_name]

    if not shortcut then
        return
    end

    local protos = name_filter(game.get_filtered_equipment_prototypes(shortcut.filters), shortcut)
    if #protos < 2 then
        return
    end

    local player = game.get_player(event.player_index)
    if not player.is_shortcut_available(event_name) then
        return
    end

    local toggled = player.is_shortcut_toggled(event_name)
    player.set_shortcut_toggled(event_name, not toggled)

    local character = player.character
    local grid = character and character.grid
    if not grid then
        return
    end

    for _, proto in pairs(protos) do
        for _, equipment in pairs(grid.equipment) do
            local name, count = equipment.name:gsub('^picker%-disabled%-', '') -- >0 means currently disabled
            if proto.name == name and game.equipment_prototypes['picker-disabled-' .. name] then
                if not (not toggled) and count == 0 then
                    swap_in_place(grid, equipment, true)
                elseif not toggled and count > 0 then
                    swap_in_place(grid, equipment, false)
                end
            end
        end
    end
end
local inputs = {'toggle-night-vision-equipment', 'toggle-active-defense-equipment'}
Event.register(inputs, toggle_armor_modules)
Event.register(defines.events.on_lua_shortcut, toggle_armor_modules)

-- Place new enabled or disabled equipment if there is already disabled equipment.
local function on_player_placed_equipment(event) -- Check for disableable equipment
    local placed = event.equipment

    if not game.equipment_prototypes['picker-disabled-' .. placed.name] then
        return
    end

    local grid = event.grid
    local player = game.get_player(event.player_index)
    local character = player.character

    if character and character.grid == grid then
        -- This is a players character grid
        local shortcut = game.shortcut_prototypes['toggle-' .. placed.name] or game.shortcut_prototypes['toggle-' .. placed.type]
        if shortcut and player.is_shortcut_available(shortcut.name) and not player.is_shortcut_toggled(shortcut.name) then
            return swap_in_place(grid, placed, true)
        end
    else
        -- Not a players character grid, check contents
        for _, equipment in pairs(grid.equipment) do
            if equipment ~= placed and placed.type == equipment.type then
                -- See if there is disabled equipment in the grid and if so swap in new disabled
                if equipment.name:find(placed.name, 1, true) and equipment.name:find('^picker%-disabled%-') then
                    return swap_in_place(grid, placed, true)
                end
            end
        end
    end
end
Event.register(defines.events.on_player_placed_equipment, on_player_placed_equipment)

-- Hack to toggle the shortcut when it becomes researched.
local function on_research_finished(event)
    local force = event.research.force
    local tech = event.research.prototype
    for shortcut in pairs(shortcuts) do
        local proto = game.shortcut_prototypes[shortcut]

        if proto and tech == proto.technology_to_unlock then
            for _, player in pairs(force.players) do
                if not player.is_shortcut_toggled(shortcut) then
                    player.set_shortcut_toggled(shortcut, true)
                end
            end
        end
    end
end
Event.register(defines.events.on_research_finished, on_research_finished)

-- Hack to toggle the shortcut when a new player is created in an existing game.
local function on_player_created(event)
    local player = game.get_player(event.player_index)
    local force = player.force
    for shortcut in pairs(shortcuts) do
        local proto = game.shortcut_prototypes[shortcut]
        local tech = proto and proto.technology_to_unlock
        if tech and force.technologies[tech.name].researched then
            if not player.is_shortcut_available(shortcut) then
                player.set_shortcut_available(shortcut, true)
                player.set_shortcut_toggled(shortcut, true)
            end
        end
    end
end
Event.register(defines.events.on_player_created, on_player_created)
