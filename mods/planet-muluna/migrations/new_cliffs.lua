local function regenerate_resource(resource) 
    local map_gen_settings = game.planets.muluna.surface.map_gen_settings
    --map_gen_settings.autoplace_controls[resource] = {}
    --map_gen_settings.autoplace_settings.entity.settings[resource] = {}
    --game.planets.muluna.surface.map_gen_settings = map_gen_settings
    game.planets.muluna.surface.regenerate_entity(resource)
end
if game.planets.muluna.surface then
    --regenerate_resource("cliff-muluna")
    --regenerate_resource("helium")
    local cliffs = game.planets.muluna.surface.find_entities_filtered{name="cliff"}
    if cliffs then
        for _,cliff in pairs(cliffs) do
            if cliff then
                local orientation = cliff.cliff_orientation
                local new_position = cliff.position
                cliff.destroy{}
                
                game.planets.muluna.surface.create_entity{name = "cliff-muluna", position = new_position, cliff_orientation = orientation}
                
                
            end
            
        end
    end
end


--     --map_gen_settings.autoplace_settings.entity.settings["anorthite-chunk"] == nil
--     --if map_gen_settings.autoplace_settings.entity.settings["anorthite-chunk"] == nil then
--       map_gen_settings.autoplace_controls["anorthite-chunk"] = {}
--       map_gen_settings.autoplace_settings.entity.settings["anorthite-chunk"] = {}
--       game.planets.muluna.surface.map_gen_settings = map_gen_settings
--       game.planets.muluna.surface.regenerate_entity("anorthite-chunk")
--     --end
-- local map_gen_settings = game.planets.muluna.surface.map_gen_settings
--     --if map_gen_settings.autoplace_settings.entity.settings["helium"] == nil then
--         map_gen_settings.autoplace_controls["helium"] = {}
--         map_gen_settings.autoplace_settings.entity.settings["helium"] = {}
--         game.planets.muluna.surface.map_gen_settings = map_gen_settings
--         game.planets.muluna.surface.regenerate_entity("helium")
--       --end