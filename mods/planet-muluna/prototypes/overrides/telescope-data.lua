local rro = Muluna.rro

local parent_planet = "nauvis"
assert(data.raw["planet"]["muluna"])
if mods["any-planet-start"] then
    local nauvis = data.raw["planet"]["nauvis"]
    
    parent_planet = settings.startup["aps-planet"].value
    --assert(1==2,tostring(parent_planet))
    local start_planet = settings.startup["aps-planet"].value
    if parent_planet == "none" or parent_planet =="muluna" then
        parent_planet = "nauvis"
    end
    
    
    
    --local o_parent_planet = data.raw["planet"][parent_planet]
end
Muluna.constants.planet_has_lightning = {}
-- Telescope data collection recipes
for _,space_location in pairs(data.raw["planet"]) do
    if       string.find(space_location.name,"factory%-floor") == nil and --Blacklist Factorissimo surfaces
             space_location.name~="factory-travel-surface" and
             space_location.name ~= rro.safe_find(data.raw["mod-data"],{"maraxsis-constants","TRENCH_SURFACE_NAME"})

             
             
        then
        local distance_factor = ((Muluna.telescopes.shortest_space_distance(parent_planet,space_location.name)))
        if distance_factor then
            Muluna.constants.planet_has_lightning[space_location.name] = space_location.lightning_properties ~= nil
            local recipe = {
                type = "recipe",
                name = "muluna-telescope-observation-" .. space_location.name,
                categories = {"muluna-telescope"},
                energy_required = 10,
                ingredients = {},
                results = {{type = "fluid", name = "muluna-astronomical-data",amount = 10 + math.floor(distance_factor)/1500}},
                icons = Muluna.icons.dual_icon("muluna-astronomical-data",space_location.name),
                --hidden=true,
                hide_from_player_crafting=true,
                surface_conditions = {
                    {
                        property = "pressure",
                        min = space_location.surface_properties["pressure"] or data.raw["surface-property"]["pressure"].default_value,
                        max = space_location.surface_properties["pressure"] or data.raw["surface-property"]["pressure"].default_value,
                    },
                    {
                        property = "gravity",
                        min = space_location.surface_properties["gravity"] or data.raw["surface-property"]["gravity"].default_value,
                        max = space_location.surface_properties["gravity"] or data.raw["surface-property"]["gravity"].default_value,
                    },
                    {
                        property = "temperature",
                        min = space_location.surface_properties["temperature"] or data.raw["surface-property"]["temperature"].default_value,
                        max = space_location.surface_properties["temperature"] or data.raw["surface-property"]["temperature"].default_value,
                    },
                    {
                        property = "magnetic-field",
                        min = space_location.surface_properties["magnetic-field"] or data.raw["surface-property"]["magnetic-field"].default_value,
                        max = space_location.surface_properties["magnetic-field"] or data.raw["surface-property"]["magnetic-field"].default_value,
                    },
                },
                auto_recycle = false,
                enabled = false,
                localised_name = {"recipe-name.muluna-telescope-observation-x",space_location.localised_name or {"space-location-name."..space_location.name}},
                order = "zz-" .. (space_location.order or "")
            }
            if space_location.name == "muluna" then
                recipe.results[1].amount = 5
            end
            Muluna.rro.soft_insert(data.raw["technology"]["muluna-telescope"].effects,
                {
                    type = "unlock-recipe",
                    recipe = recipe.name,
                }
                )
            Muluna:extend{recipe}
        end
    end
end
local space_platform = data.raw["surface"]["space-platform"]
local space_platform_data = rro.merge(table.deepcopy(data.raw["recipe"]["muluna-telescope-observation-".. parent_planet] ),
    {
        name = "muluna-telescope-observation-space-platform",
        surface_conditions = {
                    {
                        property = "gravity",
                        min = 0,
                        max = 0,
                    },
                },
        localised_name = "_nil",
        order = "zz-zzz[muluna-telescope-observation-space-platform]",
        icons = Muluna.icons.dual_icon("muluna-astronomical-data","space-platform"),
        results = {{type = "fluid", name = "muluna-astronomical-data",amount = 100}},
        ingredients = {{type = "item", name = "promethium-asteroid-chunk", amount = 10}}
    }
    


)

--space_platform_data.results[1].amount = 100

Muluna:extend{space_platform_data}

PlanetsLib.add_science_packs_from_vanilla_lab_to_technology(data.raw["technology"]["muluna-space-telescope"])

if data.raw["technology"]["maraxsis-promethium-productivity"] then
    rro.soft_insert(data.raw["technology"]["maraxsis-promethium-productivity"].effects, {
        type = "change-recipe-productivity",
        recipe = "muluna-telescope-observation-space-platform",
        change = 0.1
    })
end


