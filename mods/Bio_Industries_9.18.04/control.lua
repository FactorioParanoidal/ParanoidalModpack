--Bio_Industries Version   0.17.32

local QC_Mod = false

local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)
require ("util")
require ("libs/util_ext")
require ("control_tree")
require ("control_bio_cannon")
require ("control_arboretum")


---************** Used for Testing -----
--require ("Test_Spawn")
---*************


--------------------------------------------------------------------
local function On_Init()
--~ game.check_prototype_translations()

        if global.Bio_Cannon_Table ~= nil then
                Event.register(defines.events.on_tick, function(event) end)
        end

        if global.bi == nil then
                global.bi = {}
                global.bi.tree_growing = {}
                global.bi.tree_growing_stage_1 = {}
                global.bi.tree_growing_stage_2 = {}
                global.bi.tree_growing_stage_3 = {}
                global.bi.tree_growing_stage_4 = {}
                global.bi.terrains = {}
                global.bi.trees = {}
        end


        global.bi.seed_bomb={}
        global.bi.seed_bomb["seedling"] = "seedling"
        global.bi.seed_bomb["seedling-2"] = "seedling-2"
        global.bi.seed_bomb["seedling-3"] = "seedling-3"

        -- Global table for bio farm
        if global.bi_bio_farm_table == nil then
                global.bi_bio_farm_table = {}
        end

        -- Global table for solar boiler
        if global.bi_solar_boiler_table == nil then
                global.bi_solar_boiler_table = {}
        end

        -- Global table for solar farm
        if global.bi_solar_farm_table == nil then
                global.bi_solar_farm_table = {}
        end

        -- Global table for power rail
        if global.bi_power_rail_table == nil then
                global.bi_power_rail_table = {}
        end

        -- Global table for arboretum
        if global.Arboretum_Table == nil then
                global.Arboretum_Table = {}
        end

        -- enable researched recipes
        for i, force in pairs(game.forces) do
                force.reset_technologies()
                force.reset_recipes()
        end

        --[[
        if QC_Mod then
                ---*************
                --local surface = game.surfaces['nauvis']
                Test_Spawn()
                ---*************
        end
        ]]
end


--------------------------------------------------------------------
local function On_Load()

        if global.Bio_Cannon_Table ~= nil then
                Event.register(defines.events.on_tick, function(event) end)
        end


end


--------------------------------------------------------------------
local function On_Config_Change()


        if global.Bio_Cannon_Table ~= nil then
                Event.register(defines.events.on_tick, function(event) end)
        end

        if global.bi == nil then
                global.bi = {}
                global.bi.tree_growing = {}
                global.bi.tree_growing_stage_1 = {}
                global.bi.tree_growing_stage_2 = {}
                global.bi.tree_growing_stage_3 = {}
                global.bi.tree_growing_stage_4 = {}
                global.bi.terrains = {}
                global.bi.trees = {}
        end


        global.bi.seed_bomb={}
        global.bi.seed_bomb["seedling"] = "seedling"
        global.bi.seed_bomb["seedling-2"] = "seedling-2"
        global.bi.seed_bomb["seedling-3"] = "seedling-3"


        -- Global table for bio farm
        if global.bi_bio_farm_table == nil then
                global.bi_bio_farm_table = {}
        end

        -- Global table for solar boiler
        if global.bi_solar_boiler_table == nil then
                global.bi_solar_boiler_table = {}
        end

        -- Global table for solar farm
        if global.bi_solar_farm_table == nil then
                global.bi_solar_farm_table = {}
        end

        -- Global table for power rail
        if global.bi_power_rail_table == nil then
                global.bi_power_rail_table = {}
        end

        -- Global table for arboretum
        if global.Arboretum_Table == nil then
                global.Arboretum_Table = {}
        end


        -- enable researched recipes
        for i, force in pairs(game.forces) do
                for _, tech in pairs(force.technologies) do
                        if tech.researched then
                                for _, effect in pairs(tech.effects) do
                                        if effect.type == "unlock-recipe" then
                                                force.recipes[effect.recipe].enabled = true
                                        end
                                end
                        end
                end
        end

end


--------------------------------------------------------------------
--- Used for some compatibility with Angels Mods
Event.register(defines.events.on_player_joined_game, function(event)

   local player = game.players[event.player_index]
   local force = player.force
   local techs = force.technologies

        if settings.startup["angels-use-angels-barreling"] and settings.startup["angels-use-angels-barreling"].value then
      techs['fluid-handling'].researched = false
      techs['bi-tech-fertiliser'].reload()
      local _t = techs['angels-fluid-barreling'].researched
      techs['angels-fluid-barreling'].researched = false
      techs['angels-fluid-barreling'].researched = _t
   end

end)


---------------------------------------------
Event.register(defines.events.on_trigger_created_entity, function(event)

        --- Used for Seed-bomb
        local ent = event.entity
        local surface = ent.surface
        local position = ent.position

        -- Basic
    if global.bi.seed_bomb[ent.name] == "seedling" then
                ----writeDebug("Seed Bomb Activated - Basic")
                seed_planted_trigger(event)


        -- Standard
    elseif global.bi.seed_bomb[ent.name] == "seedling-2" then
                ----writeDebug("Seed Bomb Activated - Standard")
                local terrain_name_s
                if game.active_mods["alien-biomes"] then
                        terrain_name_s = "vegetation-green-grass-3"
                else
                        terrain_name_s = "grass-3"
                end

                surface.set_tiles{{name=terrain_name_s, position=position}}
                seed_planted_trigger(event)


        -- Advanced
    elseif global.bi.seed_bomb[ent.name] == "seedling-3" then
                ----writeDebug("Seed Bomb Activated - Advanced")
                local terrain_name_a
                if game.active_mods["alien-biomes"] then
                        terrain_name_a = "vegetation-green-grass-1"
                else
                        terrain_name_a = "grass-1"
                end

                surface.set_tiles{{name=terrain_name_a, position=position}}
                seed_planted_trigger(event)

    end

end)


--------------------------------------------------------------------
local function On_Built(event)
        local entity = event.created_entity or event.entity
        local surface = entity.surface
        local force = entity.force
        local position = entity.position

        --- Seedling planted
        if entity.valid and entity.name == "seedling" then
                seed_planted (event)
        end


    --- Bio Farm has been built
        if entity.valid and entity.name == "bi-bio-farm" then
        --writeDebug("Bio Farm has been built")

                local b_farm = entity
                local pole_name = "bi-bio-farm-electric-pole"
                local panel_name = "bi-bio-farm-solar-panel"
                local lamp_name = "bi-bio-farm-light"

                local create_pole = surface.create_entity({name = pole_name, position = position, force = force}) -- Hidden Power Pole
                local create_panel = surface.create_entity({name = panel_name, position = position, force = force}) -- Hidden Solar Paner
                local create_lamp = surface.create_entity({name = lamp_name, position = position, force = force}) -- Hidden Lamp

                create_pole.minable = false
                create_pole.destructible = false
                create_panel.minable = false
                create_panel.destructible = false
                create_lamp.minable = false
                create_lamp.destructible = false

                -- Group Multiple Entities Together
                global.bi_bio_farm_table[b_farm.unit_number] = {base=b_farm, pole=create_pole, panel=create_panel, lamp=create_lamp}

        end


        --- Bio Solar Boiler / Solar Plant has been built
        if entity.valid and entity.name == "bi-solar-boiler" then
        --writeDebug("Bio Solar Boiler has been built")

                local solar_plant = entity
                --local boiler_solar = "bi-solar-boiler-2"
                --local boiler_solar = "bi-solar-boiler"
                local boiler_solar = "bi-solar-boiler-panel"
                local sm_pole_name = "bi-hidden-power-pole"

                local create_solar_boiler = surface.create_entity({name = boiler_solar, position = position, force = force}) -- Hidden Solar Paner
                local create_sm_pole = surface.create_entity({name = sm_pole_name, position = position, force = force}) -- Hidden Power Pole

                create_solar_boiler.minable = false
                create_solar_boiler.destructible = false
                create_sm_pole.minable = false
                create_sm_pole.destructible = false

                -- Group Multiple Entities Together
                global.bi_solar_boiler_table[solar_plant.unit_number] = {base=solar_plant, boiler=create_solar_boiler, pole=create_sm_pole}

        end


    --- Solar Farm has been built
        if entity.valid and entity.name == "bi-bio-solar-farm" then
        --writeDebug("Bio Solar Farm has been built")

                local solar_farm = entity
                local sm_pole_name = "bi-hidden-power-pole"

                local create_sm_pole = surface.create_entity({name = sm_pole_name, position = position, force = force}) -- Hidden Power Pole

                create_sm_pole.minable = false
                create_sm_pole.destructible = false

                -- Group Multiple Entities Together
                global.bi_solar_farm_table[solar_farm.unit_number] = {base=solar_farm, pole=create_sm_pole}

        end


        --- Bio Cannon has been built
        if entity.valid and entity.name == "bi-bio-cannon-area" then

        local New_Bio_Cannon
        local New_Bio_CannonR

        --writeDebug("Bio Cannon has been built")

                -- Hidden Radar
                New_Bio_CannonR = surface.create_entity({name = "Bio-Cannon-r", position = position, direction = event.created_entity.direction, force = force})
                -- New Cannon, the first was just used for Radius overlay
                New_Bio_Cannon  = surface.create_entity({name = "bi-bio-cannon", position = position, direction = event.created_entity.direction, force = force})
                --~ -- Hidden Radar
                --~ New_Bio_CannonR = surface.create_entity({name = "Bio_Cannon_r", position = position, direction = event.created_entity.direction, force = force})

                New_Bio_Cannon.health = event.created_entity.health




                New_Bio_CannonR.operable = false
                New_Bio_CannonR.destructible = false
                New_Bio_CannonR.minable = false

                if global.Bio_Cannon_Table == nil then
                        global.Bio_Cannon_Table = {}
                        Event.register(defines.events.on_tick, function(event) end)
                end

                -- Group Multiple Entities Together
                table.insert(global.Bio_Cannon_Table, {New_Bio_Cannon,New_Bio_CannonR,0})

                -- Remove the "Overlay" Entity
                event.created_entity.destroy()

        end


    --- Arboretum has been built
        if entity.valid and entity.name == "bi-arboretum-area" then
        --writeDebug("Arboretum has been built")

                local arboretum_new = "bi-arboretum"
                local radar_name = "bi-arboretum-radar"
                local pole_name = "bi-hidden-power-pole"
                local lamp_name = "bi-bio-farm-light"

                local create_arboretum = surface.create_entity({name = arboretum_new, position = position, direction = entity.direction, force = force})  -- New Arboretum, the first was just used for Radius overlay
                local position_c = {position.x - 3.5, position.y + 3.5}
                local create_radar = surface.create_entity({name = radar_name, position = position_c, direction = entity.direction, force = force}) -- Radar
                local create_pole = surface.create_entity({name = pole_name, position = position, direction = entity.direction, force = force})  -- Hidden pole
                local create_lamp = surface.create_entity({name = lamp_name, position = position, force = force}) -- Hidden Lamp

                create_radar.minable = false
                create_radar.destructible = false
                create_pole.minable = false
                create_pole.destructible = false
                create_lamp.minable = false
                create_lamp.destructible = false



                -- Group Multiple Entities Together
                global.Arboretum_Table[create_arboretum.unit_number] = {inventory=create_arboretum, radar=create_radar, pole=create_pole, lamp=create_lamp}

                --log("built: entity unit_number: " .. create_arboretum.unit_number)
                --log("built: global.Arboretum_Table: " .. serpent.block(global.Arboretum_Table[create_arboretum.unit_number]))

                -- Remove the "Overlay" Entity
                event.created_entity.destroy()

        end


        -- Power Rail
        if (entity.valid and entity.name == "bi-straight-rail-power") or (entity.valid and entity.name == "bi-curved-rail-power") then
        --writeDebug("Power Rail has been built")

                local rail_track = entity
                local pole_name = "bi-rail-hidden-power-pole"
                local create_rail_pole = surface.create_entity({name = pole_name, position = position, force = force}) -- Create Hidden Power Pole

                create_rail_pole.minable = false
                create_rail_pole.destructible = false

                -- Group Multiple Entities Together Together
                global.bi_power_rail_table[rail_track.unit_number] = {base=rail_track, pole=create_rail_pole}


                if global.bi_power_rail_table[rail_track.unit_number].pole.valid then

                        local radius = 5
                        local area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
                        local power_rail_poles = {}
                        power_rail_poles = surface.find_entities_filtered{area = area, name="bi-rail-hidden-power-pole", force = force}

                        if power_rail_poles ~= nil and  #power_rail_poles >= 1 then

                                for i=1, #power_rail_poles do

                                        for _,neighbour in pairs(power_rail_poles[i].neighbours.copper) do
                                                if neighbour.name == "bi-rail-hidden-power-pole" or neighbour.name == "bi-power-to-rail-pole" then
                                                        ----writeDebug(i.. " Hidden Power Rail Pole found")
                                                        power_rail_poles[i].connect_neighbour(neighbour)
                                                else
                                                        ----writeDebug(i.. " Hidden Power Rail Pole found")
                                                        power_rail_poles[i].disconnect_neighbour(neighbour)
                                                end

                                        end

                                end

                        end


                end

        end


        --- Disconnect any other power lines from the rail-hidden-power pole
        if entity.valid and entity.type == "electric-pole" then

                if entity.name ~= "bi-rail-hidden-power-pole" and entity.name ~= "bi-power-to-rail-pole" then

                        for _,neighbour in pairs(entity.neighbours.copper) do

                                if neighbour.name == "bi-rail-hidden-power-pole" then
                                        entity.disconnect_neighbour(neighbour)
                                end

                        end

                end

        end


end


--------------------------------------------------------------------
local function On_Remove(event)

        local entity = event.created_entity or event.entity

        --- Bio Farm has been removed
        if entity.valid and entity.name == "bi-bio-farm" then
        --writeDebug("Bio Farm has been removed")

                if global.bi_bio_farm_table[entity.unit_number] then
                        global.bi_bio_farm_table[entity.unit_number].pole.destroy()
                        global.bi_bio_farm_table[entity.unit_number].panel.destroy()
                        global.bi_bio_farm_table[entity.unit_number].lamp.destroy()
                        global.bi_bio_farm_table[entity.unit_number] = nil
                end

        end


        --- Bio Solar Farm has been removed
        if entity.valid and entity.name == "bi-bio-solar-farm" then
        --writeDebug("Solar Farm has been removed")

                if global.bi_solar_farm_table[entity.unit_number] then
                        global.bi_solar_farm_table[entity.unit_number].pole.destroy()
                        global.bi_solar_farm_table[entity.unit_number] = nil
                end

        end


        --- Bio Solar Boiler has been removed
        if entity.valid and entity.name == "bi-solar-boiler" then
        --writeDebug("Solar Boiler has been removed")

                if global.bi_solar_boiler_table[entity.unit_number] then
                        global.bi_solar_boiler_table[entity.unit_number].boiler.destroy()
                        global.bi_solar_boiler_table[entity.unit_number].pole.destroy()
                        global.bi_solar_boiler_table[entity.unit_number] = nil
                end

        end


        --- Power Rail has been removed
        if (entity.valid and entity.name == "bi-straight-rail-power") or (entity.valid and entity.name == "bi-curved-rail-power") then
        --writeDebug("Power-Rail has been removed")

                if global.bi_power_rail_table[entity.unit_number] then
                        global.bi_power_rail_table[entity.unit_number].pole.destroy()
                        global.bi_power_rail_table[entity.unit_number] = nil
                end

        end


        --- Arboretum has been removed
        if entity.valid and entity.name == "bi-arboretum" then

                if global.Arboretum_Table[entity.unit_number] then
                --game.print("passed if statement: global.Arboretum_Table[entity.unit_number]")  -- it does not get here now!

                        global.Arboretum_Table[entity.unit_number].radar.destroy()
                        if global.Arboretum_Table[entity.unit_number].pole then
                                global.Arboretum_Table[entity.unit_number].pole.destroy()
                        end
                        if global.Arboretum_Table[entity.unit_number].lamp then
                                global.Arboretum_Table[entity.unit_number].lamp.destroy()
                        end
                        global.Arboretum_Table[entity.unit_number] = nil
                end

        end



        --- Seedling Removed
        if entity.valid and entity.name == "seedling" then
        --writeDebug("Seedling has been removed")

                for k, v in pairs(global.bi.tree_growing) do
                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                table.remove(global.bi.tree_growing, k)
                                return
                        end
                end

        end


        --- Tree Stage 1 Removed
        if entity.valid and entity.type == "tree" then --and global.bi.trees[entity.name] then
        ----writeDebug("Tree Removed removed name: "..entity.name)
        local tree_name = (string.find(entity.name, "bio%-tree%-"))
        ----writeDebug("Tree Removed removed name: "..tree_name)
                if tree_name then

                        local tree_stage_1 = (string.find(entity.name, '1.-$'))
                        if tree_stage_1 then
                                ----writeDebug("1: Entity Name: "..entity.name.." Tree last two digits: "..tree_stage_1)
                                for k, v in pairs(global.bi.tree_growing_stage_1) do
                                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                                table.remove(global.bi.tree_growing_stage_1, k)
                                                return
                                        end
                                end
                        end


                        local tree_stage_2 = (string.find(entity.name, '2.-$'))
                        if tree_stage_2 then
                                ----writeDebug("2: Entity Name: "..entity.name.." Tree last two digits: "..tree_stage_2)
                                for k, v in pairs(global.bi.tree_growing_stage_2) do
                                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                                table.remove(global.bi.tree_growing_stage_2, k)
                                                return
                                        end
                                end
                        end


                        local tree_stage_3 = (string.find(entity.name, '3.-$'))
                        if tree_stage_3 then
                                ----writeDebug("3: Entity Name: "..entity.name.." Tree last two digits: "..tree_stage_3)
                                for k, v in pairs(global.bi.tree_growing_stage_3) do
                                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                                table.remove(global.bi.tree_growing_stage_3, k)
                                                return
                                        end
                                end
                        end


                        local tree_stage_4 = (string.find(entity.name, '4.-$'))
                        if tree_stage_4 then
                                ----writeDebug("4: Entity Name: "..entity.name.." Tree last two digits: "..tree_stage_4)
                                for k, v in pairs(global.bi.tree_growing_stage_4) do
                                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                                table.remove(global.bi.tree_growing_stage_4, k)
                                                return
                                        end
                                end
                        end
                end
        end

end


--------------------------------------------------------------------
local function On_Death(event)

        local entity = event.created_entity or event.entity

        --- Bio Farm has been destroyed
        if entity.valid and entity.name == "bi-bio-farm" then
        --writeDebug("Bio Farm has been destroyed")

                if global.bi_bio_farm_table[entity.unit_number] then
                        global.bi_bio_farm_table[entity.unit_number].pole.destroy()
                        global.bi_bio_farm_table[entity.unit_number].panel.destroy()
                        global.bi_bio_farm_table[entity.unit_number].lamp.destroy()
                        global.bi_bio_farm_table[entity.unit_number] = nil
                end



        end


        --- Bio Solar Farm has been destroyed
        if entity.valid and entity.name == "bi-bio-solar-farm" then
        --writeDebug("Solar Farm has been destroyed")

                if global.bi_solar_farm_table[entity.unit_number] then
                        global.bi_solar_farm_table[entity.unit_number].pole.destroy()
                        global.bi_solar_farm_table[entity.unit_number] = nil
                end

        end


        --- Bio Solar Boiler has been destroyed
        if entity.valid and entity.name == "bi-solar-boiler" then
        --writeDebug("Solar Boiler has been destroyed")

                if global.bi_solar_boiler_table[entity.unit_number] then
                        global.bi_solar_boiler_table[entity.unit_number].boiler.destroy()
                        global.bi_solar_boiler_table[entity.unit_number].pole.destroy()
                        global.bi_solar_boiler_table[entity.unit_number] = nil
                end

        end


        --- Power Rail has been destroyed
        if (entity.valid and entity.name == "bi-straight-rail-power") or (entity.valid and entity.name == "bi-curved-rail-power") then
        --writeDebug("Power-Rail has been destroyed")

                if global.bi_power_rail_table[entity.unit_number] then
                        global.bi_power_rail_table[entity.unit_number].pole.destroy()
                        global.bi_power_rail_table[entity.unit_number] = nil
                end

        end


        --- Arboretum has been removed
        if entity.valid and entity.name == "bi-arboretum" then

                ----writeDebug("Arboretum has been removed")
                --log("entity unit_number: " .. entity.unit_number)
                --log("global.Arboretum_Table: " .. serpent.block(global.Arboretum_Table[entity.unit_number]))

                if global.Arboretum_Table[entity.unit_number] then
                --game.print("passed if statement: global.Arboretum_Table[entity.unit_number]")  -- it does not get here now!

                        global.Arboretum_Table[entity.unit_number].radar.destroy()
                        if global.Arboretum_Table[entity.unit_number].pole then
                                global.Arboretum_Table[entity.unit_number].pole.destroy()
                        end
                        if global.Arboretum_Table[entity.unit_number].lamp then
                                global.Arboretum_Table[entity.unit_number].lamp.destroy()
                        end
                        global.Arboretum_Table[entity.unit_number] = nil
                end

        end


        --- Seedling destroyed
        if entity.valid and entity.name == "seedling" then
        --writeDebug("Seedling has been destroyed")

                for k, v in pairs(global.bi.tree_growing) do
                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                table.remove(global.bi.tree_growing, k)
                                return
                        end
                end

        end

        --- Tree Stage 1 Removed
        if entity.valid and entity.type == "tree" then --and global.bi.trees[entity.name] then
        ----writeDebug("Tree Removed removed name: "..entity.name)
        local tree_name = (string.find(entity.name, "bio%-tree%-"))
        ----writeDebug("Tree Removed removed name: "..tree_name)
                if tree_name then

                        local tree_stage_1 = (string.find(entity.name, '1.-$'))
                        if tree_stage_1 then
                                ----writeDebug("1: Entity Name: "..entity.name.." Tree last two digits: "..tree_stage_1)
                                for k, v in pairs(global.bi.tree_growing_stage_1) do
                                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                                table.remove(global.bi.tree_growing_stage_1, k)
                                                return
                                        end
                                end
                        end


                        local tree_stage_2 = (string.find(entity.name, '2.-$'))
                        if tree_stage_2 then
                                ----writeDebug("2: Entity Name: "..entity.name.." Tree last two digits: "..tree_stage_2)
                                for k, v in pairs(global.bi.tree_growing_stage_2) do
                                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                                table.remove(global.bi.tree_growing_stage_2, k)
                                                return
                                        end
                                end
                        end


                        local tree_stage_3 = (string.find(entity.name, '3.-$'))
                        if tree_stage_3 then
                                ----writeDebug("3: Entity Name: "..entity.name.." Tree last two digits: "..tree_stage_3)
                                for k, v in pairs(global.bi.tree_growing_stage_3) do
                                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                                table.remove(global.bi.tree_growing_stage_3, k)
                                                return
                                        end
                                end
                        end


                        local tree_stage_4 = (string.find(entity.name, '4.-$'))
                        if tree_stage_4 then
                                ----writeDebug("4: Entity Name: "..entity.name.." Tree last two digits: "..tree_stage_4)
                                for k, v in pairs(global.bi.tree_growing_stage_4) do
                                        if v.position.x == entity.position.x and v.position.y == entity.position.y then
                                                table.remove(global.bi.tree_growing_stage_4, k)
                                                return
                                        end
                                end
                        end
                end
        end


end


----------------Radars Scanning Function, used by Terraformer (Arboretum)  -----------------------------
Event.register(defines.events.on_sector_scanned, function(event)

        ---- Each time a Arboretum-Radar scans a sector  ----
        if event.radar.name == "bi-arboretum-radar" then

                local num = (event.radar.unit_number-1) --< Unit number of arboretum assembler

                if game.active_mods["omnimatter_fluid"] then
                        Get_Arboretum_Recipe_omnimatter_fluid(global.Arboretum_Table[num], event)
                else
                        Get_Arboretum_Recipe(global.Arboretum_Table[num], event)
                end

        end

end)


----- Solar Mat stuff
--------------------------------------------------------------------
local function Solar_Mat (event, surface)

        for i, vv in ipairs(event.tiles) do
                local position = vv.position
                local currentTilename = surface.get_tile(position.x,position.y).name

                if currentTilename == "bi-solar-mat" then
                        --writeDebug("Solar Mat has been built")

                        if event.force ~= nil then
                                local force = event.force
                                ----writeDebug(force)
                        else
                                local force = "player"
                                ----writeDebug(force)
                        end

                        local solar_mat = surface.get_tile(position.x,position.y)
                        local sm_pole_name = "bi-musk-mat-pole"
                        local sm_panel_name = "bi-musk-mat-solar-panel"

                        local create_sm_pole = surface.create_entity({name = sm_pole_name, position = {position.x + 0.5, position.y + 0.5}, force = force})
                        local create_sm_panel = surface.create_entity({name = sm_panel_name, position = {position.x + 0.5, position.y + 0.5}, force = force})

                        create_sm_pole.minable = false
                        create_sm_pole.destructible = false
                        create_sm_panel.minable = false
                        create_sm_panel.destructible = false

                else

                        local radius = 0.5
                        local area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
                        ----writeDebug("NOT Solar Mat")
                        --local entities = surface.find_entities(area)
                        --local entity1 = entities[1]
                        local entity1 = {}
                        entity1 = surface.find_entities_filtered{area=area, name="bi-musk-mat-pole", limit=1}


                        if entity1 ~= nil then
                                ----writeDebug(entity1.name)
                                for _, o in pairs(surface.find_entities_filtered({area = area, name = "bi-musk-mat-pole"})) do o.destroy() end

                                ----writeDebug("bi-musk-mat-pole Removed")
                        else
                                ----writeDebug("bi-musk-mat-pole not found")
                        end

                        --- Remove the Hidden Solar Panel
                        --local entity2 = entities[1]
                        local entity2 = {}
                        entity2 = surface.find_entities_filtered{area=area, name="bi-musk-mat-solar-panel", limit=1}

                        if entity2 ~= nil then
                                ----writeDebug(entity2.name)
                                for _, o in pairs(surface.find_entities_filtered({area = area, name = "bi-musk-mat-solar-panel"})) do o.destroy() end

                                ----writeDebug("bi-musk-mat-solar-panel Removed")
                        else
                                ----writeDebug("bi-musk-mat-solar-panel not found")
                        end



                end
        end

end


local function Player_Tile_Built(event)

        local player = game.players[event.player_index]
        local surface = player and player.surface


        if event.tiles then Solar_Mat (event, surface) end


end


local function Robot_Tile_Built(event)


        local robot = event.robot
        local surface = robot.surface

        -- fix #2 Error while running event Bio_Industries::on_robot_built_tile
        if surface == nil then
                return
        end

        if event.tiles then Solar_Mat (event, surface) end

end

--------------------------------------------------------------------
local function solar_mat_removed_at(surface, position)
   local radius = 0.5
   local area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
   local n = 0
   for _,o in next,surface.find_entities_filtered{name='bi-musk-mat-pole',area=area} or {}
      do o.destroy() n = n+1 end
   ----writeDebug(string.format('%g bi-musk-mat-poles removed',n))
   for _,o in next,surface.find_entities_filtered{name='bi-musk-mat-solar-panel',area=area} or {}
      do o.destroy() n = n+1 end
   ----writeDebug(string.format('bi-musk-mat-solar-panel',n))
   end


local function Player_Tile_Remove(event)
   local player = game.players[event.player_index]
   if event.item_stack.name == 'bi-solar-mat' and player.mining_state.mining then
     -- --writeDebug(string.format('%g solar mats removed',event.item_stack.count))
      return solar_mat_removed_at(player.surface, player.mining_state.position)
      end
   end


local function Robot_Tile_Remove(event)
   local robot = event.robot
   if event.item_stack.name == 'bi-solar-mat' then
     -- --writeDebug(string.format('%g solar mats removed',event.item_stack.count))
      return solar_mat_removed_at(robot.surface,robot.position)
      end
   end
--------------------------------------------------------------------


Event.register(Event.core_events.configuration_changed, On_Config_Change)
Event.register(Event.core_events.init, On_Init)
Event.register(Event.core_events.load, On_Load)


Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built}
Event.pre_remove_events = {defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.script_raised_destroy}
Event.death_events = {defines.events.on_entity_died, defines.events.script_raised_destroy}
Event.player_build_event = {defines.events.on_player_built_tile}
Event.robot_build_event = {defines.events.on_robot_built_tile}
Event.player_remove_events = {defines.events.on_player_mined_item}
Event.robo_remove_events = {defines.events.on_robot_mined}


Event.register(Event.build_events, On_Built)
Event.register(Event.pre_remove_events, On_Remove)
Event.register(Event.death_events, On_Death)
Event.register(Event.player_build_event, Player_Tile_Built)
Event.register(Event.robot_build_event, Robot_Tile_Built)
Event.register(Event.player_remove_events, Player_Tile_Remove)
Event.register(Event.robo_remove_events, Robot_Tile_Remove)



--- DeBug Messages
--------------------------------------------------------------------
function writeDebug(message)
        if QC_Mod == true then
                for i, player in pairs(game.players) do
                        player.print(tostring(message))
                end
        end
end
