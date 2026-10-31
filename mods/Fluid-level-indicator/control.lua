mod_gui = require("mod-gui")
require "fli/fli"
require("compatibility/com_control")


-- Only the indicators reach the handler (script_raised_built is raised for every ore tile of RSO).
local fli_filter = {}
for _, name in ipairs(flientities) do fli_filter[#fli_filter + 1] = {filter = "name", name = name} end
script.on_event(defines.events.on_built_entity, function(event) placedfli(event.entity) end, fli_filter)
script.on_event(defines.events.on_robot_built_entity, function(event) placedfli(event.entity) end, fli_filter)
script.on_event(defines.events.script_raised_built, function(event) placedfli(event.entity) end, fli_filter)
script.on_event(defines.events.script_raised_revive, function(event) placedfli(event.entity) end, fli_filter)
-- Clone filter applies to the source entity; the clone of an indicator is an indicator.
script.on_event(defines.events.on_entity_cloned, function(event) placedfli(event.destination) end, fli_filter)
script.on_event(defines.events.on_space_platform_built_entity, function(event) placedfli(event.entity) end, fli_filter)

-- flientities already includes names added by compatibility/com_control.
script.on_event(defines.events.on_pre_player_mined_item, function(event) removedfli(event.entity) end, fli_filter)
script.on_event(defines.events.on_robot_pre_mined, function(event) removedfli(event.entity) end, fli_filter)
script.on_event(defines.events.on_entity_died, function(event) removedfli(event.entity) end, fli_filter)
script.on_event(defines.events.script_raised_destroy, function(event) removedfli(event.entity) end, fli_filter)
script.on_event(defines.events.on_space_platform_mined_entity, function(event) removedfli(event.entity) end, fli_filter)

script.on_event(defines.events.on_pre_chunk_deleted, function(event)
    local surface = game.surfaces[event.surface_index]
    for _,chunk in pairs(event.positions) do
      local x = chunk.x
      local y = chunk.y
      local area = {{x*32,y*32},{31+x*32,31+y*32}}
      for _,ent in pairs(surface.find_entities_filtered{name = flientities,area = area}) do
        removedfli(ent)
      end
    end
end)

script.on_event(defines.events.on_pre_surface_cleared,function(event)
    local surface = game.surfaces[event.surface_index]
    for _,ent in pairs(surface.find_entities_filtered({name = flientities})) do
        removedfli(ent)
    end
end)

script.on_event(defines.events.on_pre_surface_deleted,function(event)
    local surface = game.surfaces[event.surface_index]
    for _,ent in pairs(surface.find_entities_filtered({name = flientities})) do
        removedfli(ent)
    end
end)

script.on_configuration_changed(function(data)
    storage.flis = {}
    storage.flitexts = {}
    storage.flidig1 = {}
    storage.flidig10 = {}
    storage.flidig100 = {}
    storage.flidigpc = {}
    storage.fliindex = 1
    if storage.flitype == nil then
        -- to keep settings
        storage.flitype = {}
    end
    storage.currentfliunitnumber = nil -- replaced by per-player storage.fli_open
    storage.fli_open = {}
    register_flis()
end)

script.on_init(function() 
    storage.flis = {}
    storage.flitexts = {}
    storage.flidig1 = {}
    storage.flidig10 = {}
    storage.flidig100 = {}
    storage.flidigpc = {}
    storage.fliindex = 1
    storage.flitype = {}
    storage.flishown = {}
    storage.fli_open = {}
    end)


-- Runs only on update ticks. The interval comes from a runtime-global setting, so the
-- registration is the same on every client and after every load.
local function register_update_handler()
    script.on_nth_tick(nil)
    script.on_nth_tick(fli_update_interval(), flion_tick)
end
register_update_handler()

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == "update_every_x_tick" or event.setting == "number_of_units_to_check_per_update" then
        fli_refresh_settings()
        register_update_handler()
    end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    local player = game.players[event.player_index]
    if (event.element.name == "fli_dropdown") then
        set_fli_type(event)
    end
end)

local function is_fli_entity(value)
    for _, v in ipairs(flientities) do
        if v == value then
            return true
        end
    end
    return false
end

script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.players[event.player_index]
    local ent = event.entity
    if (event.gui_type == defines.gui_type.entity) and ent and is_fli_entity(ent.name) then
        open_fli_gui(player, ent)
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player = game.players[event.player_index]
    local ent = event.entity
    -- An indicator removed while its window is open arrives here without a valid entity.
    if (event.gui_type == defines.gui_type.entity) and (not (ent and ent.valid) or is_fli_entity(ent.name)) then
        close_fli_gui(player, ent)
    end
end)