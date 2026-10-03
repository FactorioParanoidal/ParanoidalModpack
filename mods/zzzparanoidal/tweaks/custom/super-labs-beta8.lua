-- Preserve the Beta 8 recipes/stats after flowfix, restack and module integration.
-- Do not touch BigLabFork's big-lab or replace third-party technology effects.
for _, source in ipairs(require("prototypes.super-labs-beta8")) do
    local target = assert(data.raw[source.type][source.name])
    for field, value in pairs(source) do
        if field ~= "effects" then
            target[field] = table.deepcopy(value)
        end
    end
    if source.icon then target.icons = nil end
    if source.type == "recipe" then
        target.category = "crafting"
        target.hidden = false
        target.hide_from_player_crafting = false
    elseif source.type == "technology" then
        target.hidden = false
        target.enabled = true
        target.research_trigger = nil
        target.unit.count_formula = nil
        local found = false
        for _, effect in ipairs(target.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == source.name then
                found = true
                break
            end
        end
        if not found then
            target.effects = target.effects or {}
            table.insert(target.effects, table.deepcopy(source.effects[1]))
        end
    end
end
