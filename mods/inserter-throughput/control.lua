local mod_gui = require('mod-gui')
local get_mod_button_flow = mod_gui.get_button_flow
local mod_button_style = mod_gui.button_style

local migrations = require('migrations')

local calc = require('calc')
local floor = math.floor

local lib = require('lib')
local get_stack_size = lib.get_stack_size

local strlen = string.len
local format = string.format

local draw_text = rendering.draw_text
local destroy_text = rendering.destroy
local text_color = {1, 1, 1}
local text_offset = {0.5, -0.5}

local stopwatch = require('stopwatch')
local stopwatch_tick = stopwatch.tick
local stopwatch_timeout = 3600 -- in ticks

-- COMPATIBILITY

local name_blacklist = nil

if not script.active_mods['miniloader'] then
    name_blacklist = {} -- disable blacklist
end

local function populate_name_blacklist()
    name_blacklist = {}
    local inserters = game.get_filtered_entity_prototypes{{filter = 'type', type = 'inserter'}}
    for name in pairs(inserters) do
        if string.find(name, 'miniloader', nil, true) then
            name_blacklist[name] = true
        end
    end
end

-- LOGIC

local function vector(from, to)
    return {to.x - from.x, to.y - from.y}
end

local function number_to_string_with_precision(number, precision)
    local result = tostring(number)
    if precision > 0 then
        local rounded = format(format('%%.%if', precision), number)
        if strlen(rounded) < strlen(result) then
            result = rounded
        end
    end
    return result
end

local function get_throughput_info(inserter, precision)
    local inserter_position = inserter.position
    local prototype = (inserter.type == 'entity-ghost'
        and inserter.ghost_prototype or inserter.prototype)
    
    local pickup_position = inserter.pickup_position
    local pickup_target = inserter.pickup_target
    if not pickup_target then
        pickup_target = inserter.surface.find_entities_filtered{
            position = pickup_position, limit = 1}[1]
    end
    local pickup_belt_speed
    if pickup_target then
        if pickup_target.type == 'entity-ghost' then
            pickup_belt_speed = pickup_target.ghost_prototype.belt_speed
        else
            pickup_belt_speed = pickup_target.prototype.belt_speed
        end
    end
    
    local drop_position = inserter.drop_position
    local drop_target = inserter.drop_target
    if not drop_target then
        drop_target = inserter.surface.find_entities_filtered{
            position = drop_position, limit = 1}[1]
    end
    local drop_belt_speed
    if drop_target then
        if drop_target.type == 'entity-ghost' then
            drop_belt_speed = drop_target.ghost_prototype.belt_speed
        else
            drop_belt_speed = drop_target.prototype.belt_speed
        end
    end
    
    local value = calc(
        prototype.inserter_rotation_speed,
        prototype.inserter_extension_speed,
        vector(inserter_position, pickup_position),
        vector(inserter_position, drop_position),
        get_stack_size(inserter, prototype),
        pickup_belt_speed,
        drop_belt_speed
    )
    return {'', number_to_string_with_precision(value, precision), {'per-second-suffix'}}
end

-- GUI

local function update_toggle_button_state(toggle_button, new_state)
    if new_state then
        toggle_button.style = 'inserter_throughput_pressed_button'
    else
        toggle_button.style = mod_button_style
    end
end

local function init_toggle_button(player)
    local top_gui = get_mod_button_flow(player)
    local toggle_element = top_gui['inserter-throughput-toggle']
    if not toggle_element then
        toggle_element = top_gui.add{
            type = 'sprite-button',
            name = 'inserter-throughput-toggle',
            tooltip = {'inserter-throughput.toggle-button-tooltip'},
            sprite = 'inserter-throughput-toggle-button'
        }
    end
    local player_settings = player.mod_settings
    toggle_element.visible = player_settings['inserter-throughput-show-toggle'].value
    update_toggle_button_state(toggle_element, player_settings['inserter-throughput-enabled'].value)
end

local function on_entity_selected(event)
    -- event.player_index   current player
    -- event.last_entity    previous entity
    local player_index = event.player_index
    local player_settings = settings.get_player_settings(player_index)
    if not player_settings['inserter-throughput-enabled'].value then
        return
    end
    local current_entity = game.get_player(player_index).selected
    local global_player_data = global.player_data
    local data = global_player_data[player_index]
    local text_id = data and data.text_id
    if current_entity then
        local entity_type = current_entity.type
        local entity_name = nil
        if entity_type == 'entity-ghost' then
            entity_type = current_entity.ghost_type
            entity_name = current_entity.ghost_name
        else
            entity_name = current_entity.name
        end
        if not name_blacklist then
            populate_name_blacklist()
        end
        if entity_type ~= 'inserter' or name_blacklist[entity_name] then
            current_entity = nil
        end
    end
    if current_entity then -- a valid inserter by now
        if not data then
            data = {}
            global_player_data[player_index] = data
        elseif data.text_id then
            destroy_text(data.text_id)
        end
        local precision = player_settings['inserter-throughput-rounding-precision'].value
        data.text_id = draw_text{
            text = get_throughput_info(current_entity, precision),
            surface = current_entity.surface,
            target = current_entity,
            target_offset = text_offset,
            color = text_color,
            players = {player_index},
            scale_with_zoom = true,
            vertical_alignment = 'baseline',
        }
    elseif text_id then
        destroy_text(text_id)
        data.text_id = nil
    end
end

local function on_setting_changed(event)
    -- event.player_index   player whose setting has changed, if applicable (API seems to be wrong)
    -- event.setting        name of the setting, as seen in the prototype
    -- event.setting_type   type of the setting, as seen in the prototype
    local setting_name = event.setting
    local player_index = event.player_index
    if setting_name == 'inserter-throughput-show-toggle' then
        local button = get_mod_button_flow(game.get_player(player_index))['inserter-throughput-toggle']
        if button then
            local new_state = settings.get_player_settings(player_index)[setting_name].value
            button.visible = new_state
        else
            init_toggle_button(game.get_player(player_index))
        end
    elseif setting_name == 'inserter-throughput-enabled' then
        local button = get_mod_button_flow(game.get_player(player_index))['inserter-throughput-toggle']
        if button then
            local new_state = settings.get_player_settings(player_index)[setting_name].value
            update_toggle_button_state(button, new_state)
            if not new_state then -- remove the tooltip on disable, if any
                local data = global.player_data[player_index]
                local text_id = data and data.text_id
                if text_id then
                    destroy_text(text_id)
                    data.text_id = nil
                end
            end
        else
            init_toggle_button(game.get_player(player_index))
        end
    end
end

local function on_toggle(event)
    -- event.player_index   player who triggered the custom input (unlisted in API)
    local player_settings = settings.get_player_settings(event.player_index)
    local enabled_setting = player_settings['inserter-throughput-enabled']
    enabled_setting.value = not enabled_setting.value
    -- this will trigger on_setting_changed above
    player_settings['inserter-throughput-enabled'] = enabled_setting
end

local function on_gui_clicked(event)
    -- event.element        clicked element
    -- event.player_index   player who clicked
    -- event.button         mouse button
    -- event.alt            state of Alt key
    -- event.control        state of Ctrl key
    -- event.shift          state of Shift key
    if event.element.name == 'inserter-throughput-toggle' then
        on_toggle(event)
    end
end

-- COMMANDS

local function stopwatch_command(event)
    -- event.player_index   player who ran the command, if any
    -- event.parameter      the rest of the command string
    if not event.player_index then
        -- no player implies no ability to select the inserter
        -- so responding with the help text will inform them of this fact
        localised_print{'inserter-throughput.stopwatch-help'}
        return
    end
    local player = game.get_player(event.player_index)
    local inserter = player.selected
    if not name_blacklist then
        populate_name_blacklist()
    end
    if not inserter or inserter.type ~= 'inserter' or name_blacklist[inserter.name] then
        player.print{'inserter-throughput.stopwatch-help'}
        return
    end
    local entry = stopwatch.new(inserter)
    entry.player = player
    entry.entity_name = inserter.name
    entry.entity_position = inserter.position
    entry.entity_surface = inserter.surface.name
    entry.timeout_tick = event.tick + stopwatch_timeout
    if not global.stopwatch then
        global.stopwatch = {entry}
    else
        table.insert(global.stopwatch, entry)
    end
end

commands.add_command(
    'it-stopwatch',
    {'', {'inserter-throughput.stopwatch-command-description'}, ' ', {'inserter-throughput.stopwatch-help'}},
    stopwatch_command)

local function stopwatch_results(player, entry)
    local result = stopwatch.get_throughput(entry)
    local precision = player.mod_settings['inserter-throughput-rounding-precision'].value
    local pos = entry.entity_position
    local message = {'',
        {'inserter-throughput.stopwatch-finished', {'inserter-throughput.inserter-at',
            entry.entity_name, pos.x, pos.y, entry.entity_surface}},
        '\n',
    }
    local n = #message + 1
    if not result.stable then
        message[n] = {'inserter-throughput.stopwatch-warning-not-max'}
        message[n + 1] = '\n'
        n = n + 2
    end
    message[n] = {'inserter-throughput.stopwatch-result',
        number_to_string_with_precision(result.throughput, precision),
        {'per-second-suffix'},
        result.items,
        result.ticks,
    }
    player.print(message)
end

-- EVENTS

local function init()
    if not global.player_data then
        global.player_data = {}
    end
    -- player_data[player_index] = table
    --      .text_id        id of the rendered text
    for _, player in pairs(game.players) do
        init_toggle_button(player)
    end
end

local function on_player_joined_game(event)
    -- event.player_index   current player
    init_toggle_button(game.get_player(event.player_index))
end

local function on_tick(event)
    local watches = global.stopwatch
    if not watches then
        return
    end
    local tick = event.tick
    local n = #watches
    for i = n, 1, -1 do
        local entry = watches[i]
        local player = entry.player
        local inserter = entry.inserter
        local end_watch = false
        if not player.valid then -- they're gone, just stop wasting time
            end_watch = true
        elseif not inserter.valid then -- inserter is gone
            local pos = entry.entity_position
            player.print{'inserter-throughput.stopwatch-interrupted', {'inserter-throughput.inserter-at',
                entry.entity_name, pos.x, pos.y, entry.entity_surface}}
            end_watch = true
        elseif tick > entry.timeout_tick then
            local pos = entry.entity_position
            player.print{'inserter-throughput.stopwatch-timeout', {'inserter-throughput.inserter-at',
                entry.entity_name, pos.x, pos.y, entry.entity_surface}}
            end_watch = true
        else
            local finished, changed = stopwatch_tick(entry, tick)
            if finished then
                stopwatch_results(player, entry)
                end_watch = true
            elseif changed then
                entry.timeout_tick = tick + stopwatch_timeout
            end
        end
        if end_watch then
            watches[i] = watches[n]
            watches[n] = nil
            n = n - 1
        end
    end
    if n == 0 then
        global.stopwatch = nil
    end
end

function on_configuration_changed(event)
    -- event.old_version            old map version
    -- event.new_version            new map version
    -- event.mod_changes[mod_name]  only the ones that changed
    --      .old_version            old version of the mod
    --      .new_version            new version of the mod
    -- event.mod_startup_settings_changed
    -- event.migration_applied      if mod prototype migration was executed
    local versions = event.mod_changes['inserter-throughput']
    if versions and versions.old_version then
        local env = {
            init_toggle_button = init_toggle_button,
        }
        migrations(env, versions.old_version)
    end
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
script.on_event(defines.events.on_selected_entity_changed, on_entity_selected)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_setting_changed)
script.on_event(defines.events.on_gui_click, on_gui_clicked)
script.on_event('inserter-throughput-toggle', on_toggle)
script.on_event(defines.events.on_tick, on_tick)
script.on_init(init)
script.on_configuration_changed(on_configuration_changed)
