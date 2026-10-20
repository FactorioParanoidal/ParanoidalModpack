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
    toxic:migrate(script.active_mods["toxicPollution2"])
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

-- Only constant combinators matter; filtered events are registered one at a time (2.0 API).
-- The former names on_build_entity/on_robot_build_entity do not exist: nothing was registered.
local combinator_filter = {{filter = "type", type = "constant-combinator"}}
for _, event_id in ipairs({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
}) do
    script.on_event(event_id, function(event)
        detector:OnBuild(event)
    end, combinator_filter)
end

for _, event_id in ipairs({defines.events.on_robot_mined_entity, defines.events.on_player_mined_entity}) do
    script.on_event(event_id, function(event)
        detector:DeleteEntity(event.entity)
    end, combinator_filter)
end

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