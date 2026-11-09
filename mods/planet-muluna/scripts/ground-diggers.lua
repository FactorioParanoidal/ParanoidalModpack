-- Muluna's regolith digging technology is a trigger technology that completes when a
-- ground digger is built. PlanetsLib creates diggers from script (script_raised_built),
-- which does not count as a player build, so complete the research explicitly.
local Public = {}

local technology_name = "muluna-regolith-digging"
local digger_suffix = "-ground-digger"

-- Muluna's event helper requires every handler for an event to be filtered if any of them
-- is, so narrow build events down to ground digger names.
local filters = {}
local filter_names = {}
local constants = prototypes.mod_data["Planetslib"] and prototypes.mod_data["Planetslib"].data
for _, config in pairs(constants and constants.ground_diggers or {}) do
    for _, info in pairs(config.diggers or {}) do
        if not filter_names[info.digger] then
            filter_names[info.digger] = true
            table.insert(filters, {filter = "name", name = info.digger})
            table.insert(filters, {filter = "ghost_name", name = info.digger})
        end
    end
end
if #filters == 0 then
    table.insert(filters, {filter = "name", name = "electric-mining-drill-ground-digger"})
end

function Public.on_digger_built(event)
    local entity = event.entity or event.created_entity
    if not (entity and entity.valid) then return end
    if not string.find(entity.name, digger_suffix, 1, true) then return end

    -- Ground digger prototypes are shared between planets, so only Muluna's diggers
    -- should complete Muluna's technology.
    local planet = entity.surface and entity.surface.planet
    if not (planet and planet.name == "muluna") then return end

    local technology = entity.force.technologies[technology_name]
    if technology and not technology.researched then
        Muluna.complete_research(entity.force, technology_name)
    end
end

Muluna.events.on_event(Muluna.events.events.on_built(), Public.on_digger_built, filters)

return Public
