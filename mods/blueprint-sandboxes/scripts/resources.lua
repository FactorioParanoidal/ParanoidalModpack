-- Custom Planners to add/remove Resources
local Resources = {}

Resources.name = BPSB.pfx .. "sandbox-resources"
Resources.pfx = BPSB.pfx .. "sbr-"
local pfxLength = string.len(Resources.pfx)

Resources.nameScalar = { default = 1 }
Resources.nameScalar["crude-oil"] = 1
Resources.nameScalar["mineral-water"] = 5

Resources.categoryScalar = { default = 10000 }
Resources.categoryScalar["basic-fluid"] = 1
Resources.categoryScalar["basic-solid"] = 10000
Resources.categoryScalar["oil"] = 1
Resources.categoryScalar["hard-resource"] = 8000
Resources.categoryScalar["kr-quarry"] = 1500

-- Whether the Thing is a Resource Planner
function Resources.IsResourcePlanner(name)
    return string.sub(name, 1, pfxLength) == Resources.pfx
end

-- Extract the Resource Name from a Resource Planner
function Resources.GetResourceName(name)
    return string.sub(name, pfxLength + 1)
end

-- Determine the amount to spawn for a Resource Planner
function Resources.GetResourceAmount(resourceName)
    local resourcePrototype = game.entity_prototypes[resourceName]

    local nameScalar = Resources.nameScalar[resourceName] or Resources.nameScalar["default"]
    local categoryScalar = Resources.categoryScalar[resourcePrototype.resource_category] or Resources.categoryScalar["default"]

    local richness = 1
    local autoplace_controls = game.surfaces["nauvis"].map_gen_settings.autoplace_controls[resourceName]
    if autoplace_controls then
        richness = autoplace_controls.richness
        if richness < 0 then richness = 1
        else richness = math.max(0.5, richness)
        end
    end

    local normal = resourcePrototype.normal_resource_amount
    local minimum = resourcePrototype.minimum_resource_amount

    return nameScalar * categoryScalar * richness * math.max(normal, minimum)
end

-- Determine how often to spawn for a Resource Planner
function Resources.GetResourceSpacing(resourceName)
    local box = game.entity_prototypes[resourceName].map_generator_bounding_box
    return {
        x = math.max(1, math.ceil(box.right_bottom.x - box.left_top.x)),
        y = math.max(1, math.ceil(box.right_bottom.y - box.left_top.y)),
    }
end

-- Add Resources when a Resource Planner is used
function Resources.OnAreaSelectedForAdd(event)
    local resourceName = Resources.GetResourceName(event.item)
    local density = Resources.GetResourceAmount(resourceName)
    local spacing = Resources.GetResourceSpacing(resourceName)
    for x = event.area.left_top.x, event.area.right_bottom.x, spacing.x do
        for y = event.area.left_top.y, event.area.right_bottom.y, spacing.y do
            event.surface.create_entity({
                name = resourceName,
                position = { x = x, y = y },
                amount = density,
                raise_built = true,
            })
        end
    end
end

-- Removed Resources when a Resource Planner is used
function Resources.OnAreaSelectedForRemove(event)
    for _, entity in pairs(event.entities) do
        entity.destroy({ raise_destroy = true })
    end
end

-- Add/Remove Resources when a Resource Planner is used
function Resources.OnAreaSelected(event, add)
    if (Lab.IsLab(event.surface) or SpaceExploration.IsSandbox(event.surface))
            and Resources.IsResourcePlanner(event.item)
    then
        if add then
            Resources.OnAreaSelectedForAdd(event)
        else
            Resources.OnAreaSelectedForRemove(event)
        end
    end
end

return Resources
