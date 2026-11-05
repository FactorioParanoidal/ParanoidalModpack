-- Levels that unlock new buildings or items stay visible in the technology list and its search.
-- upgrade = true makes the list show only the current level of a chain and hide the others
-- (automation-7..9 were invisible until automation-6 was researched). Bonus chains keep it.
local chains = {
    {"automation-", 7, 9},             -- MilesBobsExpansion2: assembling machines 7-9
    {"electronics-machine-", 4, 5},    -- MilesBobsExpansion2: electronics assembling machines 4-5
    {"Schall-tank-", 1, 2},
    {"Schall-tank-F-", 0, 2},
    {"Schall-tank-H-", 0, 2},
    {"Schall-tank-SH-", 0, 2},
    {"bet-charger-", 2, 3},
    {"bet-fuel-", 2, 4},
    {"pickup-tower-", 1, 4},
    {"tpr-smog-protection-", 1, 10},   -- gas mask, filter module, closed breathing inside the chain
    {"angels-ironworks-", 1, 5},
    {"angels-alloys-smelting-", 1, 3},
}
local singles = {"electric-steel-furnace"}

local technologies = data.raw.technology
for _, chain in pairs(chains) do
    for level = chain[2], chain[3] do
        local technology = technologies[chain[1] .. level]
        if technology then technology.upgrade = false end
    end
end
for _, name in pairs(singles) do
    if technologies[name] then technologies[name].upgrade = false end
end
