require("classes.toxic")
require("classes.detector")

local interval = 1

local toxic = Toxic()
local detector = Detector(interval)

script.on_init(function()
    toxic:init()
    toxic:initCommands()
    detector:init()
end)

script.on_load(function()
    toxic:initCommands()
end)

script.on_configuration_changed(function()
    toxic:init()
    detector:init()
    toxic:migrate(game.active_mods["toxicPollution"])
end)

script.on_event(defines.events.on_player_joined_game, function(event)
    toxic:init()
    detector:init()
end)

script.on_nth_tick(interval, function(event)
    if event.tick % conf:TickInterval() == 0 then
        toxic:OnTick()
    end
    detector:OnTick(event)
end)

script.on_event(defines.events.on_gui_closed, function(event)
    detector:OnGuiClosed(event)
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
    detector:OnSettingPasted(event)
end)

script.on_event({defines.events.on_robot_build_entity, defines.events.on_build_entity}, function(event)
    detector:OnBuild(event)
end)

script.on_event({defines.events.on_robot_mined_entity, defines.events.on_player_mined_entity}, function(event)
    detector:DeleteEntity(event.entity)
end)

script.on_event(defines.events.on_research_finished, function(event)
    local tech = event.research
    toxic:UpdateTech(tech.name, tech.force)
end)

script.on_event(defines.events.on_player_died, function(event)
    toxic:OnPlayerDied(event)
end)

script.on_event(defines.events.on_player_respawned, function(event)
    toxic:OnPlayerRespawned(event)
end)