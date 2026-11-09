-- The exact shape of `defines.prototypes.entity` has changed between Factorio
-- versions (array of type names vs. dictionary keyed by type name). Accept both
-- so custom pipette results are always registered.
for key,prototype_type in pairs(defines.prototypes.entity) do
    local entity_type = type(key) == "string" and key or prototype_type
    for _,entity in pairs(data.raw[entity_type] or {}) do
        if entity.PlanetsLib_pipette_result then
            assert(type(entity.PlanetsLib_pipette_result) == "string", "EntityPrototype::PlanetsLib_pipette_result: Must be a string.")
            assert(not entity.placeable_by,"EntityPrototype::PlanetsLib_pipette_result: This field is mutually exclusive with EntityPrototype::placeable_by.")
            PlanetsLib.constants.pipette_result[entity.name] = entity.PlanetsLib_pipette_result
        end
    end
end