local chain = require("lib.chain")
local technologies = data.raw.technology

-- 1. Beta 8 cost of foreign infinite technologies. A missing or finite technology is skipped with a log line:
-- the formula is meaningful only for an infinite tier.
for _, entry in ipairs(require("prototypes.infinite-costs")) do
    local technology = technologies[entry.technology]
    if not technology then
        log("paranoidal-upgrade-tech: skipped cost of '" .. entry.technology .. "': technology is missing")
    elseif technology.max_level ~= "infinite" or not technology.unit then
        log("paranoidal-upgrade-tech: skipped cost of '" .. entry.technology .. "': not an infinite unit-based technology")
    else
        technology.unit.count = nil
        technology.unit.count_formula = entry.count_formula
        technology.unit.time = entry.time or technology.unit.time
    end
end

-- 2. Own chains must survive all other mods: same name, prerequisites and packs that exist.
-- Failing here names the broken reference instead of a generic engine error.
local tools = data.raw.tool
for _, name in ipairs(chain.names(require("prototypes.chains"))) do
    local technology = technologies[name]
    if not technology then error("paranoidal-upgrade-tech: technology '" .. name .. "' was removed by another mod") end
    for _, prerequisite in ipairs(technology.prerequisites or {}) do
        if not technologies[prerequisite] then
            error("paranoidal-upgrade-tech: '" .. name .. "' requires missing technology '" .. prerequisite .. "'")
        end
    end
    for _, ingredient in ipairs(technology.unit and technology.unit.ingredients or {}) do
        local pack = ingredient[1] or ingredient.name
        if not tools[pack] then
            error("paranoidal-upgrade-tech: '" .. name .. "' uses missing science pack '" .. tostring(pack) .. "'")
        end
    end
end
