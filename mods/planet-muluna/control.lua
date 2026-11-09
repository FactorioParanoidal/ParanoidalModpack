
require("api")
Muluna.funit = Muluna.funit or {}
local rro = Muluna.rro
-- script.on_configuration_changed(function()
--     if debug_mode then
--         log(DT .. "initialized storage")
--         log(serpent.block(storage))
--     end
--     if storage == nil then 
--         storage = {
--             ---@type table<int, LuaEntity>
--             nav_beacons = {}, -- beacon [unit_number] = LuaEntity (nav-beacon)
--             ---@type table<int, LuaSpacePlatform>
--             beacon_platforms = {}, -- beacon [unit_number] = LuaSpacePlatform
--             ---@type table<int, LuaEntity>
--             platform_beacons = {}, -- platform [index] = LuaEntity (nav-beacon)
--             ---@type table<int, LuaSpaceLocationPrototype>
--             nav_surfaces = {}, -- beacon [unit_number] = LuaSpaceLocationPrototype
--             ---@type table<int, LuaEntity>
--             beacon_electric_interfaces = {}, -- beacon [unit_number] = LuaEntity (nav-beacon-electric-interface)
--         }
--     end
-- end)


--_G.maraxsis = require "scripts.constants"
--muluna={}
--require("lib.control-stage")

require("scripts.ground-diggers")
require("scripts.nav-beacon")
require("scripts.walking_particles")
require("scripts.heat-assembling-machine")
require("scripts.telescopes")
require("scripts.gui")
require("scripts.burner-roboports")
require("scripts.compound-entities")
require("scripts.remote")
require("scripts.even-pickier-dollies")
--local sd = require("scripts.project-seadragon")

--muluna.finalize_events()

-- script.on_nth_tick(60,function(event)
--     local map_gen_settings = game.planets.muluna.surface.map_gen_settings
--     --map_gen_settings.autoplace_settings.entity.settings["anorthite-chunk"] == nil
--     if map_gen_settings.autoplace_settings.entity.settings["anorthite-chunk"] == nil then
--       map_gen_settings.autoplace_controls["anorthite-chunk"] = {}
--       map_gen_settings.autoplace_settings.entity.settings["anorthite-chunk"] = {}
--       game.planets.muluna.surface.map_gen_settings = map_gen_settings
--       game.planets.muluna.surface.regenerate_entity("anorthite-chunk")
--     end
-- end) 

local function init_storage() 
    storage.players_on_muluna = {}
    if not storage.telescopes then 
        storage.telescopes = {} 
    end
end
local interstellar_science_pack = require("scripts.interstellar-science-pack")

-- Muluna.events.on_event(defines.events.on_tick, function()
--     for _,player in pairs(game.players) do
--         if player.character then
--             print(player.character_running_speed_modifier)
--         end
        
--     end

-- end
-- )




Muluna.events.on_event(Muluna.events.events.on_init(), function(event)
    --init_storage() 
    storage.walking_tick_rates = {}
    for _,force in pairs(game.forces) do
        interstellar_science_pack.update_interstellar_pack(force,false)
    end
    storage.players_on_muluna = {}
    for i,player in pairs(game.players) do
        if player.surface.name == "muluna" then
            storage.players_on_muluna[i] = {player=player}
        end
    end
    if not storage.players_walking_on_muluna then storage.players_walking_on_muluna = {} end
    if not storage.player_control_method then 
        storage.player_control_method = {} 
        for i,player in pairs(game.players) do
            storage.player_control_method[i] = player.input_method 
        end
    end
    if not storage.telescopes then storage.telescopes = {} end 
    if not storage.telescopes_on_surface then storage.telescopes_on_surface = {} end
    -- The telescope combinator update skips writes that cannot change the
    -- signals by comparing a numeric signature. A prototype change can reorder
    -- or rename the virtual signals without changing the platform numbers, so
    -- force one rewrite after a configuration change.
    for _, telescope in pairs(storage.telescopes) do
        telescope.signal_signature = nil
    end
    if not storage.active_burner_roboports then storage.active_burner_roboports = {} end
    if not storage.burner_roboports then storage.burner_roboports = {} end
    if not storage.cached_direction_to_string then storage.cached_direction_to_string = {} end
    if not storage.nav_beacons_other then storage.nav_beacons_other = {} end
    if not storage.walking_tick_rates then storage.walking_tick_rates = {} end
    for i,radar in pairs(storage.nav_beacons) do
        if not storage.nav_beacons_other[i] then
            storage.nav_beacons_other[i] = {gui = {enabled = true}}
        end
        
    end

end)

Muluna.events.finalize_events()

local new_surface = require("scripts.new-surface")

script.on_event(defines.events.on_surface_created,function(event)
    -- game.print(tostring(event.surface_index))
    -- game.print(tostring(event.tick))
    --game.print(tostring(tick))
    new_surface.on_new_surface(event.surface_index)

end

)




script.on_event(defines.events.on_research_finished, function(event) interstellar_science_pack.update_interstellar_pack(event.research.force) end)
-- script.on_configuration_changed(function()
    
-- end
-- )




if script.active_mods["funit"] then
    require("scripts.funit")
    require("__funit__.mock").register()
end

if script.active_mods["gvv"] then require("__gvv__.gvv")() end
