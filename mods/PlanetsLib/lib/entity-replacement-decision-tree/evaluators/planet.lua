--Returns planet name of LuaEntity, or "space-platform" if on planet. Intended to return a string to act as an input for a table key.
return function(LuaEntity)
    local entity = LuaEntity

    local surface = entity.surface
    local planet_object = surface.planet
    local planet 
    if planet_object then
        planet = planet_object.name
    else
        planet = "space-platform"
    end

    return planet


end
