local config = { }

---@type table<string, { type: ValveType, mode: ValveMode }>
config.valves = {
    ["valves-overflow"] = { type = "overflow", mode = "overflow" },
    ["valves-top_up"] = { type = "top_up", mode = "top-up" },
    ["valves-one_way"] = { type = "one_way", mode = "one-way" },
}

return config