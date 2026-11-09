local rro = require("lib.objects")
local Public = {}

if not PlanetsLib.constants.entity_variants_list then PlanetsLib.constants.entity_variants_list = {} end
if not PlanetsLib.constants.inverted_entity_variants then PlanetsLib.constants.inverted_entity_variants = {} end
if not PlanetsLib.constants.entity_variants_list_inverse then PlanetsLib.constants.entity_variants_list_inverse = {} end
-- Creates "If entity placed on planet, replace entity with new_entity" rule.
-- Mass-assignment is possible by making entity a dictionary table and new_entity nil.
function Public.assign_entity_replacement(planet,entity,new_entity,bound_setting,name_suffix)
    assert(entity ~= new_entity,"PlanetsLib.assign_entity_replacement(planet,entity,new_entity,bound_setting) - entity must be different from new_entity.")
    if not bound_setting then --Since entity replacements can potentially break saves, every entity replacement must be bound to a startup setting that can be disabled to aid in safe uninstallation.
        bound_setting = "PlanetsLib-enable-entity-replacements"
    end

    -- Mass-assignment is possible by making planet a list of planets.
    if type(planet) == "table" and not planet.name then
        for key,single_planet in pairs(planet) do
            local single_planet_name = (type(single_planet) == "table" and single_planet.name) or single_planet
            Public.assign_entity_replacement(single_planet_name,entity,new_entity,bound_setting,name_suffix)
        end
        return
    end

    local planet_name = (type(planet) == "table" and planet.name) or planet

    local rule_enabled = settings.startup[bound_setting].value
    local disable_all = settings.startup["PlanetsLib-disable-all-entity-replacements"]
    if disable_all and disable_all.value then
        rule_enabled = false
    end

    if not PlanetsLib.constants.on_entity_placed_on_planet_replacements[planet_name] then PlanetsLib.constants.on_entity_placed_on_planet_replacements[planet_name] = {} end

    if type(entity) == "table" and new_entity == nil then
        for key,value in pairs(entity) do
            Public.assign_entity_replacement(planet_name,key,value.entity,bound_setting,value.name_suffix or name_suffix)
        end
        return
    end
    if PlanetsLib.constants.on_entity_placed_on_planet_replacements[planet_name][entity] then
        error("PlanetsLib.assign_entity_replacement(planet,entity,new_entity,bound_setting) - Assigning an entity variant of the same entity on the same planet more than once is currently not possible.")
    end
    PlanetsLib.constants.on_entity_placed_on_planet_replacements[planet_name][entity] = {old_entity=entity,entity=new_entity,enabled=rule_enabled}
    
    
    
    if not PlanetsLib.constants.entity_variants_list[entity] then  PlanetsLib.constants.entity_variants_list[entity] = {} end
    if not PlanetsLib.constants.entity_variants_list_inverse[new_entity] then PlanetsLib.constants.entity_variants_list_inverse[new_entity] = {} end
    table.insert(PlanetsLib.constants.entity_variants_list[entity],new_entity)
    table.insert(PlanetsLib.constants.entity_variants_list_inverse[new_entity],{entity=entity,suffix=name_suffix})
    --Check if recursive rules exist that would create a stack overflow error.
    
    if not PlanetsLib.constants.inverted_entity_variants[planet_name] then PlanetsLib.constants.inverted_entity_variants[planet_name] = {} end
    if not PlanetsLib.constants.inverted_entity_variants[planet_name][new_entity] then PlanetsLib.constants.inverted_entity_variants[planet_name][new_entity] = {} end
    PlanetsLib.constants.inverted_entity_variants[planet_name][new_entity]=entity
    assert(not (PlanetsLib.constants.inverted_entity_variants[planet_name][entity] and PlanetsLib.constants.inverted_entity_variants[planet_name][entity]==new_entity),
    "PlanetsLib.assign_entity_replacement(planet,entity,new_entity,bound_setting) - Recursive entity replacement ruleset created on planet ".. planet_name ..". " .. new_entity .. " <-> " .. entity)
    
end




-- 1. Generates a deepcopy of entity, 
-- 2. Gives the deepcopy a unique name, 
-- 3. Gives the deepcopy the same localized name/description as entity.
-- 4. Merges deepcopy with new_properties, enabling the user to override steps 2/3 if desired.
-- 5. Makes the deepcopy replace entity when on each "planet".
-- 6. Adds new_entity to data.raw.
-- 7. Returns new_entity to make it easier to reference the generated entity in subsequent code.
local function create_planet_entity_variant(planet_names,entity,new_properties,bound_setting,item_name)
    assert(settings.startup[bound_setting],
    "PlanetsLib.assign_entity_replacement(planet_names,entity,new_properties,bound_setting,item_name) - bound_setting must refer to a valid boolean startup setting.")

    -- Never generate a variant of an already generated variant. Callers often
    -- iterate a prototype table (for example
    -- `for _, panel in pairs(data.raw["solar-panel"])`); without this guard the
    -- variants created during the loop are visited too, and each visit creates
    -- another variant until the game consumes all RAM. See issue #136.
    -- Checking the generated name additionally covers variants whose
    -- PlanetsLib_do_not_generate_variants marker was overridden by new_properties.
    if entity.PlanetsLib_do_not_generate_variants
        or (type(entity.name) == "string" and entity.name:find("-PlanetsLib-", 1, true) ~= nil) then
        return
    end

    if item_name == nil and data.raw["item"][entity.name] then
        item_name = entity.name
    end
    local first_planet_name = (type(planet_names) == "table" and planet_names[1]) or planet_names
    -- if not entity.fast_replaceable_group then
    --     entity.fast_replaceable_group = entity.name .. "-PlanetsLib-group"
    -- end
    local new_entity = table.deepcopy(entity)
    local name_suffix = "-PlanetsLib-" .. first_planet_name 
    new_entity.name = entity.name .. name_suffix

    -- Factorio defaults an unspecified fast_replaceable_group to the prototype
    -- name. Without this, the variant's effective group becomes its own name
    -- and the engine refuses to fast-replace/upgrade between the variant and
    -- the original entity (for example when upgrading a locomotive).
    if not new_entity.fast_replaceable_group then
        new_entity.fast_replaceable_group = entity.fast_replaceable_group or entity.name
    end

    if not entity.factoriopedia_alternative then
        new_entity.factoriopedia_alternative = entity.name
    end
    if not new_entity.placeable_by and item_name then
        new_entity.placeable_by = {{item = item_name, count =1}}
    end
    new_entity.hidden_in_factoriopedia = true
    
    
    if not new_entity.localised_name then
        new_entity.localised_name = {"entity-name." .. entity.name}
    end
    if not new_entity.localised_description then
        new_entity.localised_description = {"entity-description." .. entity.name}
    end
    
    if not new_entity.icons then
        new_entity.icons = {
            new_entity.icon and {
                icon = new_entity.icon,
                icon_size = new_entity.icon_size
            } or nil
        }
    end
    

    new_entity.flags = new_entity.flags or {}
    rro.soft_insert(new_entity.flags,"not-in-made-in")
    rro.soft_insert(new_entity.flags, "not-in-bonus-gui")
    new_entity.PlanetsLib_do_not_generate_variants = true
    new_entity = rro.merge(new_entity,new_properties) 
    
    

    local first_planet = type(planet_names) == "table" and planet_names[1] or planet_names
    if new_entity.icon or new_entity.icons then
        if data.raw["planet"][first_planet] and data.raw["planet"][first_planet].icon then
            table.insert(new_entity.icons , {
                icon = data.raw["planet"][first_planet].icon,
                icon_size = data.raw["planet"][first_planet].icon_size,
                scale = 64 / (data.raw["planet"][first_planet].icon_size or 64)* 0.25,
                shift = {10,-10},
                draw_background = true,
        })
        elseif data.raw["planet"][first_planet] and data.raw["planet"][first_planet].icons then
            for _,icon_entry in pairs(data.raw["planet"][first_planet].icons) do
                table.insert(new_entity.icons , {
                icon = icon_entry.icon,
                icon_size = icon_entry.icon_size,
                scale = 64 / (icon_entry.icon_size or 64)* 0.25,
                shift = {10,-10},
                draw_background = true,
            })
            end
        end
    end

    if type(planet_names) == "table" then
        for _,planet in pairs(planet_names) do
            Public.assign_entity_replacement(planet,entity.name,new_entity.name,bound_setting,name_suffix)
        end
    else
    
        
        new_entity.order = (new_entity.order or "") .. "z" .. (data.raw["planet"][planet_names] and data.raw["planet"][planet_names].order or "")
        Public.assign_entity_replacement(planet_names,entity.name,new_entity.name,bound_setting,name_suffix)
    end
    
    data:extend{new_entity}
    return new_entity
end

function Public.create_planet_entity_variant(planet_names,entity,new_properties,bound_setting,item_name)
    local call,err = pcall(create_planet_entity_variant,planet_names,entity,new_properties,bound_setting,item_name)
    if call then
        
    else
        log("entity:"..serpent.block(entity))
        error("PlanetsLib(): Error while generating entity variant for ".. entity.name .. " on planets " .. serpent.block(planet_names) .. "\n" .. "New properties:" .. serpent.block(new_properties) .. "\n" .. serpent.block(err))
    end

end

return Public