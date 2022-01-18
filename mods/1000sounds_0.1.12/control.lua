local utils = require('utils')
local sound_files = require('sound_files')

local function getdeath(cause)
    if (cause == nil) then return 'other' end
    if (cause.type == 'locomotive') then return 'locomotive' end
    if (cause.type == 'wagon') then return 'wagon' end
    if (cause.type == 'cargo-wagon') then return 'wagon' end
    if (cause.type == 'player') then return 'player' end
    if (cause.type == 'car') then
        if (cause.name == 'car') then return 'car' end
        if (cause.name == 'tank') then return 'tank' end
    end
    if (cause.type == 'unit' or cause.type == 'turret') then
        if (cause.name == 'small-biter') then return 'biter' end
        if (cause.name == 'medium-biter') then return 'biter' end
        if (cause.name == 'big-biter') then return 'biter' end
        if (cause.name == 'behemoth-biter') then return 'biter' end

        if (cause.name == 'small-spitter') then return 'spitter' end
        if (cause.name == 'medium-spitter') then return 'spitter' end
        if (cause.name == 'big-spitter') then return 'spitter' end
        if (cause.name == 'behemoth-spitter') then return 'spitter' end

        if (cause.name == 'small-worm-turret') then return 'wormturret' end
        if (cause.name == 'medium-worm-turret') then return 'wormturret' end
        if (cause.name == 'big-worm-turret') then return 'wormturret' end
        if (cause.name == 'behemoth-worm-turret') then return 'wormturret' end
    end

    game.print("Let it be known that someone died on: " .. cause.type .. ' - ' .. cause.name)

    if (cause.type == 'car') then return 'car' end
    if (cause.type == 'unit') then return 'unit' end
    if (cause.type == 'turret') then return 'wormturret' end

    return 'other'
end

-- Play sound globaly
local function playItSam(eventname)
    if (eventname ~= 'sfx_off') then
        if (eventname ~= nil and game.is_valid_sound_path(eventname)) then
            game.play_sound({path = eventname})
        elseif (sound_files[eventname] ~= nil and game.is_valid_sound_path(sound_files[eventname])) then
            game.play_sound({path = sound_files[eventname]})
        elseif (eventname ~= nil and game.is_valid_sound_path('sound_' .. eventname)) then
            game.play_sound({path = 'sound_' .. eventname})
        elseif (sound_files[eventname] ~= nil and game.is_valid_sound_path('sound_' .. sound_files[eventname])) then
            game.play_sound({path = 'sound_' .. sound_files[eventname]})
        else
            utils.var_dump('player')
            for _, player in pairs(game.players) do
                player.surface.create_entity({name = eventname, position = player.position})
            end
        end
    end
end

-- Play sound for specific player
local function playItForSally(eventname, player_index)
    local player = nil
    if (player_index ~= nil and type(player_index) == 'uint') then
        player = game.get_player(player_index)
    end
    if (player_index ~= nil and type(player_index) == 'table' and tonumber(player_index['player_index']) ~= nil) then
        player = game.get_player(tonumber(player_index['player_index']))
    end
    
    if (player ~= nil and eventname ~= 'sfx_off') then
        player.surface.create_entity({name = eventname, position = player.position})
    else
        playItSam(eventname)
    end
end

-- Called after a player dies.
script.on_event(defines.events.on_player_died, function(event)
    local eventname = getdeath(event.cause)
    eventname = settings.global["1000sounds-kill-" .. eventname].value

    if (eventname == "[same as alien]") then
        eventname = settings.global["1000sounds-kill-unit"].value
    end

    eventname = 'sfx_' .. eventname
    if (event.cause ~= nil and eventname ~= 'sfx_off') then
        event.cause.surface.create_entity(
            {name = eventname, position = event.cause.position})
    end
end)

-- Called after a player respawns.
script.on_event(defines.events.on_player_respawned, function(player_index)
    local eventname = 'sfx_' ..
                          settings.global["1000sounds-player-respawn"].value
    playItForSally(eventname, player_index)
end)

-- Called when a character corpse expires due to timeout or all of the items being removed from it.
script.on_event(defines.events.on_character_corpse_expired,
                function(player_index)
    local eventname = 'sfx_' ..
                          settings.global["1000sounds-character-corpse-expired"]
                              .value
    playItSam(eventname)
end)

-- ---------------------------------------------------------------------------------

-- Called after the player was created.
script.on_event(defines.events.on_player_created, function(player_index)
    local eventname = 'sfx_' ..
                          settings.global["1000sounds-player-created"].value
    playItSam(eventname)
end)

-- Called when a player is removed (deleted) from the game. 
script.on_event(defines.events.on_player_removed, function(player_index)
    local eventname = 'sfx_' ..
                          settings.global["1000sounds-player-removed"].value
    playItSam(eventname)
end)

-- Called after a player joins the game.
script.on_event(defines.events.on_player_joined_game, function(player_index)
    local eventname = 'sfx_' ..
                          settings.global["1000sounds-player-joined"].value
    playItSam(eventname)
end)

-- Called after a player leaves the game.
script.on_event(defines.events.on_player_left_game, function(player_index)
    local eventname = 'sfx_' .. settings.global["1000sounds-player-left"].value
    playItSam(eventname)
end)

-- ---------------------------------------------------------------------------------

-- Called when an entity is built.
-- script.on_event(defines.events.on_built_entity, function(player_index)
--     local eventname = 'sfx_' .. settings.global["1000sounds-built-entity"].value
--     playItSam(eventname)    
-- end)

-- Called when a construction robot builds an entity.
-- script.on_event(defines.events.on_robot_built_entity, function(player_index)
--     local eventname = 'sfx_' .. settings.global["1000sounds-robot-built-entity"].value
--     playItSam(eventname)    
-- end)

-- Called when an entity dies.
-- script.on_event(defines.events.on_entity_died, function(player_index)
--     local eventname = 'sfx_' .. settings.global["1000sounds-entity-died"].value
--     playItSam(eventname)    
-- end)

-- Called when the deconstruction of an entity is canceled.
-- script.on_event(defines.events.on_canceled_deconstruction, function(player_index)
--     local eventname = 'sfx_' .. settings.global["1000sounds-canceled-deconstruction"].value
--     playItSam(eventname)    
-- end)

-- ---------------------------------------------------------------------------------

-- Called when someone talks in-game either a player or through the server interface.
script.on_event(defines.events.on_console_chat, function(player_index, message)
    local eventname = 'sfx_' .. settings.global["1000sounds-console-chat"].value
    playItSam(eventname)
end)

-- Called when someone enters a command-like message regardless of it being a valid command.
-- script.on_event(defines.events.on_console_command,
--                 function(player_index, command, parameters)
--     local eventname = 'sfx_' ..
--                           settings.global["1000sounds-console-command"].value
--     playItForSally(eventname, player_index)
-- end)

-- ---------------------------------------------------------------------------------

-- Called when a technology research starts.
script.on_event(defines.events.on_research_started, function(research, byscript)
    local eventname = 'sfx_' ..
                          settings.global["1000sounds-research-started"].value
    playItSam(eventname)
end)

-- Called when a research finishes.
script.on_event(defines.events.on_research_finished,
                function(research, byscript)
    local eventname = 'sfx_' ..
                          settings.global["1000sounds-research-finished"].value
    playItSam(eventname)
end)

-- Called when a research finishes.
script.on_event(defines.events.on_rocket_launched, function(research, byscript)
    local eventname = 'sfx_' ..
                          settings.global["1000sounds-rocket-launched"].value
    playItSam(eventname)
end)
