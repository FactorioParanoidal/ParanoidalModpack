local names = {
    ["aai-small-ship-wreck"] = true,
    ["crash-site-spaceship"] = true,
}
local boards = {["crash-site-spaceship"] = {8, 8}}

for _, group in ipairs({
    {"aai-big-ship-wreck-", 3},
    {"aai-medium-ship-wreck-", 2},
    {"crash-site-spaceship-wreck-small-", 6, 1, 2},
    {"crash-site-spaceship-wreck-medium-", 3, 2, 4},
    {"crash-site-spaceship-wreck-big-", 2, 4, 8},
}) do
    for index = 1, group[2] do
        local name = group[1] .. index
        names[name] = true
        if group[3] then boards[name] = {group[3], group[4]} end
    end
end

return {
    names = names,
    boards = boards,
    mining_time = 1.5,
    target_prefix = "paranoidal-shipwreck-mining-",
}
