-- Serializable, bounded dispatcher jobs. No entity searches, GUI objects, functions or metatables in jobs.
local M = {}

function M.catalog(revision)
    return {kind = "catalog", revision = revision, phase = "read", nodes = {}, ids = {}, forces = {}, index = 1, path = {}}
end

function M.catalog_step(job, factories, describe)
    if job.phase == "read" then
        -- A building may disappear between steps. Restart enumeration safely; IDs already seen are skipped.
        if job.cursor and factories[job.cursor] == nil then job.cursor = nil end
        local key, factory = next(factories, job.cursor)
        job.cursor = key
        if not key then job.phase = "link"; return false end
        if not (factory.id and job.nodes[factory.id]) then
            local node = describe(factory)
            if node then
                job.nodes[node.id] = node
                job.ids[#job.ids + 1] = node.id
                local force = job.forces[node.force]
                if not force then
                    force = {ids = {}, counts = {}, total = 0, power_revision = 0, problem_revision = 0}
                    job.forces[node.force] = force
                end
                force.ids[#force.ids + 1] = node.id
                if node.built then
                    force.total = force.total + 1
                    force.counts[node.layout] = (force.counts[node.layout] or 0) + 1
                end
            end
        end
    elseif job.phase == "link" then
        local node = job.nodes[job.ids[job.index]]
        if not node then job.phase = "depth"; job.index = 1; return false end
        local parent = job.nodes[node.parent]
        node.tree_parent = parent and parent.force == node.force and parent.id or nil
        job.index = job.index + 1
    elseif job.phase == "depth" then
        local node = job.nodes[job.current or job.ids[job.index]]
        if job.unwind then
            local id = job.path[#job.path]
            if not id then job.unwind = nil; job.current = nil; job.index = job.index + 1; return false end
            node = job.nodes[id]
            local parent = job.nodes[node.tree_parent]
            node.depth = parent and (parent.depth or 0) + 1 or 0
            node.cyclic = node.cycle_parent ~= nil or parent and parent.cyclic or false
            node.visiting = nil
            job.path[#job.path] = nil
        elseif not node then
            job.phase = "done"
            return true
        elseif node.depth ~= nil then
            if job.current then job.unwind = true else job.index = job.index + 1 end
        elseif node.visiting then
            -- Cut only the display edge. The real parent remains available for navigation.
            node.cycle_parent = node.tree_parent
            node.tree_parent = nil
            node.depth = 0
            node.cyclic = true
            job.unwind = true
        else
            node.visiting = true
            job.path[#job.path + 1] = node.id
            if node.tree_parent then job.current = node.tree_parent else job.unwind = true end
        end
    end
    return false
end

function M.view(catalog, force_index, state, key, search)
    local force = catalog.forces[force_index] or {ids = {}, counts = {}, total = 0}
    return {kind = "view", catalog = catalog, force = force, key = key, phase = "reveal", index = 1,
        reveal = state.view == "tree" and state.reveal or nil,
        search = search, search_id = search and search:gsub("^#", ""):gsub("^\226\132\150", ""):gsub("^%s+", ""),
        tier = state.tier, problems = state.problems, sort = state.sort, tree = state.view == "tree",
        filtered = search ~= nil or state.tier ~= nil or state.problems, expanded = state.expanded or {},
        matched = {}, matches = {}, included = {}, items = {}, children = {}, roots = {}, rows = {}, positions = {}}
end

local function before(a, b, sort)
    if sort == "name" then
        if a.name ~= b.name then
            if a.name == nil then return false end
            if b.name == nil then return true end
            return a.name < b.name
        end
    elseif sort == "tier" then
        if a.tier ~= b.tier then return a.tier > b.tier end
    elseif sort == "place" then
        if a.surface ~= b.surface then return a.surface < b.surface end
        if a.depth ~= b.depth then return a.depth < b.depth end
    elseif sort == "power" and a.power ~= b.power then
        if a.power == nil then return false end
        if b.power == nil then return true end
        return a.power > b.power
    end
    return a.id < b.id
end

function M.view_step(job)
    local nodes, ids = job.catalog.nodes, job.force.ids
    if job.phase == "reveal" then
        local node = job.reveal and nodes[job.reveal]
        job.reveal = node and node.tree_parent or nil
        if job.reveal then job.expanded[job.reveal] = true else job.phase = "match" end
    elseif job.phase == "match" then
        local id = ids[job.index]
        if not id then job.phase = "include"; job.index = 1; return false end
        local node = nodes[id]
        local show = node.built and (not job.tier or node.layout == job.tier)
        if show and job.search then
            show = (node.name or ""):find(job.search, 1, true) ~= nil or tostring(id) == job.search_id
        end
        if show and job.problems then show = node.problem end
        if show then job.matches[#job.matches + 1] = id; job.matched[id] = true end
        job.index = job.index + 1
    elseif job.phase == "include" then
        local id = job.current or job.matches[job.index]
        if not id then job.phase = "items"; job.index = 1; return false end
        if job.included[id] then
            job.current = nil; job.index = job.index + 1
        else
            job.included[id] = true
            job.current = job.tree and nodes[id].tree_parent or nil
            if not job.current then job.index = job.index + 1 end
        end
    elseif job.phase == "items" then
        local id = ids[job.index]
        if not id then
            job.phase = "sort"; job.width = 1; job.left = 1; job.output = {}
            return false
        end
        if job.included[id] then
            local n = nodes[id]
            job.items[#job.items + 1] = {id = id, name = n.name, tier = n.tier, surface = n.surface, depth = n.depth,
                power = n.power, packed = not n.built, parent = n.tree_parent, cycle = n.cycle_parent,
                context = not job.matched[id]}
        end
        job.index = job.index + 1
    elseif job.phase == "sort" then
        -- Bottom-up merge sort: one output element per step, including very large lists.
        local n, width = #job.items, job.width
        if width >= n then job.phase = "children"; job.index = 1; return false end
        if job.left > n then
            job.items = job.output; job.output = {}; job.width = width * 2; job.left = 1
            return false
        end
        if not job.i then
            job.i = job.left; job.mid = math.min(job.left + width, n + 1)
            job.j = job.mid; job.last = math.min(job.left + width * 2 - 1, n)
        end
        if job.i >= job.mid and job.j > job.last then
            job.left = job.left + width * 2; job.i = nil
            return false
        end
        local take_left = job.j > job.last or (job.i < job.mid and before(job.items[job.i], job.items[job.j], job.sort))
        local index = take_left and job.i or job.j
        job.output[#job.output + 1] = job.items[index]
        if take_left then job.i = job.i + 1 else job.j = job.j + 1 end
    elseif job.phase == "children" then
        local item = job.items[job.index]
        if not item then
            job.phase = "flatten"; job.stack = {{items = job.roots, index = 1, depth = 0}}
            return false
        end
        local parent = job.tree and item.parent
        local list = job.roots
        if parent and job.included[parent] then
            list = job.children[parent] or {}; job.children[parent] = list
        end
        list[#list + 1] = item
        job.index = job.index + 1
    elseif job.phase == "flatten" then
        local frame = job.stack[#job.stack]
        if not frame then job.phase = "done"; return true end
        local item = frame.items[frame.index]
        if not item then job.stack[#job.stack] = nil; return false end
        frame.index = frame.index + 1
        local children = job.children[item.id]
        local expanded = job.filtered or job.expanded[item.id] == true
        local row = {id = item.id, depth = frame.depth, packed = item.packed, context = item.context, cycle = item.cycle,
            children = children and #children or 0, expanded = expanded, filtered = job.filtered}
        job.rows[#job.rows + 1] = row
        job.positions[item.id] = #job.rows
        if children and expanded then job.stack[#job.stack + 1] = {items = children, index = 1, depth = frame.depth + 1} end
    end
    return false
end

return M
