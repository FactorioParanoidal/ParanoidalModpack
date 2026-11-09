local function remove_resource(resource) 
    local map_gen_settings = game.planets.muluna.surface.map_gen_settings
    map_gen_settings.autoplace_controls[resource] = nil
    map_gen_settings.autoplace_settings.entity.settings[resource] = nil
    game.planets.muluna.surface.map_gen_settings = map_gen_settings
    game.planets.muluna.surface.regenerate_entity(resource)
end
if game.planets.muluna.surface then
    remove_resource("uranium-ore")
    remove_resource("stone")
    --regenerate_resource("helium")
end




-- for surface in pairs(game.surfaces) do
--     if surface.name == "muluna" then
        
--     end
-- end