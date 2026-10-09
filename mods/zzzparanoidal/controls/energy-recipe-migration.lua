-- Recipe bridges retain pre-8.1.23 buffers until Lua can return incompatible ingredients.
local M = {}
local recipes = {
    ["paranoidal-energy-migration-angels-uranium-fuel-cell"] = true,
    ["paranoidal-energy-migration-uranium-fuel-cell"] = true,
    ["angels-uranium-fuel-cell"] = true,
}
function M.convert(machine)
    if not (machine and machine.valid and machine.type == "assembling-machine") then return end
    local recipe, quality = machine.get_recipe()
    if not (recipe and recipes[recipe.name]) then return end
    for _, stack in ipairs(machine.set_recipe("uranium-fuel-cell", quality)) do
        machine.surface.spill_item_stack{
            position = machine.position, stack = stack, force = machine.force,
            allow_belts = false, enable_looted = true, drop_full_stack = true,
            use_start_position_on_failure = true,
        }
    end
end
function M.migrate()
    for _, surface in pairs(game.surfaces) do
        for _, machine in pairs(surface.find_entities_filtered{type = "assembling-machine"}) do M.convert(machine) end
    end
    for _, force in pairs(game.forces) do
        for name in pairs(recipes) do
            if force.recipes[name] then force.recipes[name].enabled = false end
        end
    end
end
function M.install()
    -- Migrated ghosts/blueprints may retain a bridge recipe until construction or settings paste.
    -- Chain existing handlers (loader shells, etc.) instead of overwriting them.
    for _, event in ipairs({defines.events.on_built_entity, defines.events.on_robot_built_entity,
        defines.events.script_raised_built, defines.events.script_raised_revive,
        defines.events.on_entity_cloned, defines.events.on_entity_settings_pasted}) do
        local previous = script.get_event_handler(event)
        script.on_event(event, function(e)
            if previous then previous(e) end
            M.convert(e.destination or e.entity)
        end)
    end
end
return M
