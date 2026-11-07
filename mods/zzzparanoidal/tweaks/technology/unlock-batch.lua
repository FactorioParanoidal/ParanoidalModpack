-- Phase-local unlock transfers, after OV.execute. Entries: {recipe, {target names}};
-- an empty target list removes only. Missing recipes/any missing target skip the entry.
-- Build the inverse index once, then replay transfers in order (including duplicates).
-- Index effect TABLES, not technology names: shared effects keep their original semantics.
local M = {}
function M.apply(moves, skip_infinite)
    local technologies = data.raw.technology
    local ready, wanted = {}, {}
    for _, move in ipairs(moves) do
        local recipe, targets = move[1], move[2]
        local available = data.raw.recipe[recipe] ~= nil
        for _, name in ipairs(targets) do available = available and technologies[name] ~= nil end
        if available then
            ready[#ready + 1] = move
            wanted[recipe] = {}
        end
    end
    if #ready == 0 then return end
    local eligible = {}
    for _, technology in pairs(technologies) do
        local effects = technology.effects
        if effects and (not skip_infinite or technology.max_level ~= "infinite") and not eligible[effects] then
            eligible[effects] = true
            for _, effect in ipairs(effects) do
                local locations = effect.type == "unlock-recipe" and wanted[effect.recipe]
                if locations then locations[effects] = true end
            end
        end
    end
    for _, move in ipairs(ready) do
        local recipe = move[1]
        local locations = wanted[recipe]
        for effects in pairs(locations) do
            for index = #effects, 1, -1 do
                local effect = effects[index]
                if effect.type == "unlock-recipe" and effect.recipe == recipe then table.remove(effects, index) end
            end
        end
        wanted[recipe] = {}
        for _, name in ipairs(move[2]) do
            local technology = technologies[name]
            technology.effects = technology.effects or {}
            local effects = technology.effects
            effects[#effects + 1] = { type = "unlock-recipe", recipe = recipe }
            if eligible[effects] or not skip_infinite or technology.max_level ~= "infinite" then
                eligible[effects] = true
                wanted[recipe][effects] = true
            end
        end
    end
end
return M
