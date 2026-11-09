local order = 101
for _,planet in pairs(data.raw["planet"]) do
    if PlanetsLib.constants.planet_special_properties[planet.name] then
        local properties = PlanetsLib.constants.planet_special_properties[planet.name] or {}
        local lift_multiplier =  properties["rocket_lift_multiplier"]
        local part_multiplier =  properties["rocket_part_multiplier"]
        
        if lift_multiplier or part_multiplier then
            

            if lift_multiplier then
                if not data.raw["surface-property"]["PlanetsLib-lift-weight-multiplier"] then
                    data:extend{{
                        name = "PlanetsLib-lift-weight-multiplier",
                        type = "surface-property",
                        default_value = 1,
                        order = (data.raw["surface-property"]["robot-energy-usage"].order or "z"),
                        localised_unit_key = "surface-property-unit.multiplier"
                    }}
                end
                planet.surface_properties["PlanetsLib-lift-weight-multiplier"] = lift_multiplier
                
            end

            if part_multiplier then
                if not data.raw["surface-property"]["PlanetsLib-rocket-part-multiplier"] then
                    data:extend{{
                        name = "PlanetsLib-rocket-part-multiplier",
                        type = "surface-property",
                        default_value = 1,
                        order = (data.raw["surface-property"]["robot-energy-usage"].order or "z"),
                        localised_unit_key = "surface-property-unit.multiplier"
                    }}
                end
                planet.surface_properties["PlanetsLib-rocket-part-multiplier"] = part_multiplier 
            end

            for _,silo in pairs(data.raw["rocket-silo"]) do
                --local silo = data.raw["rocket-silo"]["rocket-silo"]
                local silo_item_name
                if data.raw["item"][silo.name] then
                    silo_item_name = silo.name
                end
                 
                if not silo.PlanetsLib_do_not_generate_variants and not string.find(silo.name,"PlanetsLib") then --Don't pass over existing silo variants. Skipping this check creates an infinite loop that consumes all RAM
                    PlanetsLib.create_planet_entity_variant(
                        planet.name,
                        silo,
                        {
                            rocket_parts_required = silo.rocket_parts_required*(part_multiplier or 1),
                            lift_weight = (silo.lift_weight or data.raw['utility-constants'].default_rocket_lift_weight or 1000000)*(lift_multiplier or 1),
                            rocket_parts_storage_cap = silo.rocket_parts_storage_cap and silo.rocket_parts_storage_cap*(part_multiplier or 1) or nil,
                        },
                        "PlanetsLib-enable-runtime-rocket-silo-replacements",
                        silo_item_name
                    )
                end
            end
        end 
    end
   
end