require("classes.toxic")
require("classes.detector")

-- Detector combinators are refreshed in 12 slots, one slot every 5 ticks (each combinator once
-- per 60 ticks as before); player damage runs once per TickInterval. No per-tick handler.
local DETECTOR_TICKS = 5

local toxic = Toxic()
local detector = Detector(DETECTOR_TICKS)

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

script.on_nth_tick(conf:TickInterval(), function()
    toxic:OnTick()
end)

script.on_nth_tick(DETECTOR_TICKS, function(event)
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

-- The respirator filters poison clouds (90% poison resistance, prototypes/items.lua) at the cost of
-- its durability: the absorbed part of every poison hit drains it; a worn-out respirator is gone.
local RESPIRATOR = "respirator"
local RESPIRATOR_POISON_SHARE = 0.9
script.on_event(defines.events.on_entity_damaged, function(event)
    local character = event.entity
    if not (character and character.valid) then return end
    local inventory = character.get_inventory(defines.inventory.character_armor)
    local stack = inventory and inventory[1]
    if not (stack and stack.valid_for_read and stack.name == RESPIRATOR) then return end
    local absorbed = event.original_damage_amount * RESPIRATOR_POISON_SHARE
    if absorbed <= 0 then return end
    if stack.durability <= absorbed then
        stack.clear()
        if character.player then character.player.print({"Armor-destroyed"}) end
    else
        stack.drain_durability(absorbed)
    end
end, {{filter = "type", type = "character"}, {mode = "and", filter = "damage-type", type = "poison"}})
