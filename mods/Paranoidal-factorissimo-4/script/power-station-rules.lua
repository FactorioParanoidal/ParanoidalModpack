-- Construction-only graph arithmetic. Capacities are steam units/second, not live flow.
local M = {}
local limits = {{10, 15, 20}, {24, 36, 48}, {40, 60, 80}, {90, 135, 180}}
local sizes = {30, 46, 60, 90}
local tolerance = {0.10, 0.05, 0.02}
local reserve = {30, 60, 120}
local surplus = {1.05, 1.10, 1.15}
local cleaning = {0.25, 0.50, 1}
local EPS = 0.000001

local function max_flow(nodes, edges, sources, sinks)
    local graph = {}
    for i = 1, nodes + 2 do graph[i] = {} end
    local start, finish = nodes + 1, nodes + 2
    local function add(a, b, cap)
        local forward, backward = {to = b, cap = cap}, {to = a, cap = 0}
        forward.reverse, backward.reverse = backward, forward
        graph[a][#graph[a] + 1], graph[b][#graph[b] + 1] = forward, backward
    end
    local total = 0
    for _, source in ipairs(sources) do add(start, source.node, source.rate); total = total + source.rate end
    for _, sink in ipairs(sinks) do add(sink.node, finish, sink.rate) end
    for _, edge in ipairs(edges) do add(edge[1], edge[2], total) end
    local result = 0
    while true do
        local queue, level = {start}, {[start] = 0}
        for _, v in ipairs(queue) do
            for _, edge in ipairs(graph[v]) do
                if edge.cap > EPS and level[edge.to] == nil then
                    level[edge.to] = level[v] + 1
                    queue[#queue + 1] = edge.to
                end
            end
        end
        if not level[finish] then return result end
        local cursor = {}
        local function send(v, available)
            if v == finish then return available end
            local list = graph[v]
            for i = cursor[v] or 1, #list do
                cursor[v] = i
                local edge = list[i]
                if edge.cap > EPS and level[edge.to] == level[v] + 1 then
                    local amount = send(edge.to, math.min(available, edge.cap))
                    if amount > EPS then
                        edge.cap = edge.cap - amount
                        edge.reverse.cap = edge.reverse.cap + amount
                        return amount
                    end
                end
            end
            cursor[v] = #list + 1
            return 0
        end
        while true do
            local amount = send(start, total)
            if amount <= EPS then break end
            result = result + amount
        end
    end
end
M.max_flow = max_flow

local function reachable(graph, start)
    local seen, queue = {[start] = true}, {start}
    for _, node in ipairs(queue) do
        for _, target in ipairs(graph[node]) do
            if not seen[target] then seen[target] = true; queue[#queue + 1] = target end
        end
    end
    return seen
end

local function thresholds(size)
    for i, known in ipairs(sizes) do if size == known then return limits[i] end end
    local area = size * size / 900
    return {math.ceil(10 * area), math.ceil(15 * area), math.ceil(20 * area)}
end

-- Uniform-temperature components are deliberately conservative: do not invent a mixing model.
function M.evaluate(snapshot, size)
    local result = {fuel = 0, power = 0, ecology = 0, blocks = 0, generators = {}}
    if snapshot.disqualified or #snapshot.sources == 0 or #snapshot.sinks == 0 then return result end
    local n, adjacency, reverse, weak = snapshot.nodes, {}, {}, {}
    for i = 1, n do adjacency[i], reverse[i], weak[i] = {}, {}, {} end
    for _, edge in ipairs(snapshot.edges) do
        local a, b = edge[1], edge[2]
        adjacency[a][#adjacency[a] + 1], reverse[b][#reverse[b] + 1] = b, a
        weak[a][#weak[a] + 1], weak[b][#weak[b] + 1] = b, a
    end
    local components, owner = {}, {}
    for i = 1, n do
        if not owner[i] then
            local c = {sources = {}, sinks = {}, tanks = {}, nodes = {i}}
            components[#components + 1] = c
            owner[i] = c
            for _, node in ipairs(c.nodes) do
                for _, target in ipairs(weak[node]) do
                    if not owner[target] then owner[target] = c; c.nodes[#c.nodes + 1] = target end
                end
            end
        end
    end
    for _, source in ipairs(snapshot.sources) do
        local c = owner[source.node]; c.sources[#c.sources + 1] = source
    end
    for _, sink in ipairs(snapshot.sinks) do
        local c = owner[sink.node]; c.sinks[#c.sinks + 1] = sink
    end
    for _, tank in ipairs(snapshot.tanks) do
        local c = owner[tank.node]; c.tanks[#c.tanks + 1] = tank
    end
    local threshold, rated, components_used = thresholds(size), 0, {}
    local total_supply, total_demand, waste = 0, 0, 0
    for _, c in ipairs(components) do
        local temperature, same = nil, true
        for _, source in ipairs(c.sources) do
            if temperature and math.abs(temperature - source.temperature) > EPS then same = false end
            temperature = source.temperature
        end
        if same and temperature and #c.sinks > 0 then
            local compatible = {}
            local supply, demand, loss = 0, 0, 0
            for _, source in ipairs(c.sources) do supply = supply + source.rate end
            for _, sink in ipairs(c.sinks) do
                if temperature >= sink.minimum and temperature <= sink.maximum then
                    compatible[#compatible + 1] = sink
                    demand = demand + sink.rate
                    local fraction = math.min(1, (sink.useful_temperature - sink.default_temperature)
                        / (temperature - sink.default_temperature))
                    loss = loss + sink.rate * (1 - math.max(0, fraction))
                end
            end
            local flow = max_flow(n, snapshot.edges, c.sources, compatible)
            if flow > EPS then
                c.sinks, c.supply, c.demand, c.flow, c.loss = compatible, supply, demand, flow, loss
                local counts, back_counts = {}, {}
                for _, source in ipairs(c.sources) do
                    for node in pairs(reachable(adjacency, source.node)) do counts[node] = (counts[node] or 0) + 1 end
                end
                for _, sink in ipairs(c.sinks) do
                    for node in pairs(reachable(reverse, sink.node)) do back_counts[node] = (back_counts[node] or 0) + 1 end
                    if counts[sink.node] and sink.entity then result.generators[#result.generators + 1] = sink.entity end
                end
                c.collector, c.capacity = false, 0
                for _, node in ipairs(c.nodes) do
                    if counts[node] == #c.sources and back_counts[node] == #c.sinks then c.collector = true; break end
                end
                for _, tank in ipairs(c.tanks) do
                    if counts[tank.node] == #c.sources and back_counts[tank.node] == #c.sinks then
                        c.capacity = c.capacity + tank.capacity
                    end
                end
                components_used[#components_used + 1] = c
                total_supply, total_demand = total_supply + supply, total_demand + demand
                rated = rated + flow
                waste = waste + loss
            end
        end
    end
    result.blocks = rated / 60
    if total_demand <= EPS then return result end
    for tier = 1, 3 do
        if result.blocks + EPS >= threshold[tier] then
            local imbalance = math.abs(total_supply - total_demand) / math.max(total_supply, total_demand)
            local bad, weight = 0, 0
            local all_power = true
            for _, c in ipairs(components_used) do
                local w = math.max(c.supply, c.demand)
                weight = weight + w
                if math.abs(c.supply - c.demand) / w > tolerance[tier] + EPS
                    or c.flow + EPS < math.min(c.supply, c.demand) * (1 - tolerance[tier]) then bad = bad + w end
                local sustained = c.collector and #c.sources >= 2 and c.supply + EPS >= c.demand * surplus[tier]
                    and c.flow + EPS >= c.demand
                local buffered = c.capacity + EPS >= c.demand * reserve[tier]
                    and math.abs(c.supply - c.demand) / w <= 0.10 + EPS
                    and c.flow + EPS >= math.min(c.supply, c.demand) * 0.90
                if not (sustained or buffered) then all_power = false end
            end
            if imbalance <= tolerance[tier] + EPS and (tier == 1 or bad <= weight * (tier == 2 and 0.05 or 0.02) + EPS)
                and (tier < 3 or waste <= total_demand * 0.01 + EPS) then result.fuel = tier end
            if all_power and #components_used > 0 then result.power = tier end
            if (snapshot.pollution or 0) > EPS and (snapshot.cleaning or 0) + EPS >= snapshot.pollution * cleaning[tier] then
                result.ecology = tier
            end
        end
    end
    return result
end

return M
