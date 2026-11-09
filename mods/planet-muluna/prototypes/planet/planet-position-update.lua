local parent_planet = "nauvis"

if mods["any-planet-start"] then
    local nauvis = data.raw["planet"]["nauvis"]
    
    parent_planet = settings.startup["aps-planet"].value
    --assert(1==2,tostring(parent_planet))
    local start_planet = settings.startup["aps-planet"].value
    if parent_planet == "none" or parent_planet =="muluna" then
        parent_planet = "nauvis"
    end
    
    
    
    local o_parent_planet = data.raw["planet"][parent_planet]



    PlanetsLib:update{{
        type = "planet",
        name = "muluna",
        magnitude = (o_parent_planet.magnitude or 1)*3/5,
        orbit = {
        orientation = 0.75, --When planetsLib orbit is added, orientation and distance are set relative to parent body.
        distance = 1.6*(o_parent_planet.magnitude or 1)/(nauvis.magnitude),
        parent = {
            type = "planet",
            name = parent_planet,
            },
        
            sprite = {
            type = "sprite",
            filename = "__muluna-graphics__/graphics/orbits/orbit-muluna.png",
            size = 412,
            scale = 0.25*(o_parent_planet.magnitude or 1)/(nauvis.magnitude),
            }
        },
    }}

end



  