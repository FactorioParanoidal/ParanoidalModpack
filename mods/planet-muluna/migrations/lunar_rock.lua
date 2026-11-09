local function regenerate_resource(resource) 
    local map_gen_settings = game.planets.muluna.surface.map_gen_settings
    map_gen_settings.autoplace_controls[resource] = {}
    map_gen_settings.autoplace_settings.entity.settings[resource] = {}
    game.planets.muluna.surface.map_gen_settings = map_gen_settings
    game.planets.muluna.surface.regenerate_entity(resource)
end
if game.planets.muluna.surface then
    local map_gen_settings = game.planets.muluna.surface.map_gen_settings
    map_gen_settings.autoplace_controls["lunar_rocks"] = {}
    map_gen_settings.autoplace_settings.entity.settings["lunar-rock"] = {}
    game.planets.muluna.surface.map_gen_settings = map_gen_settings
    game.planets.muluna.surface.regenerate_entity("lunar-rock")
    --regenerate_resource("helium")
end