-- Diagnostic counters only. One cohort per surface and permission mode; no
-- scans, timers, entity references or reconstruction from the four-entry log.
local funnel = {}

function funnel.add(counts, key)
    -- A plan or ticket already in flight when this feature was installed has
    -- no measured raid at its head. Don't count its tail as a new opportunity.
    if counts then counts[key] = (counts[key] or 0) + 1 end
end

local function cohort(map)
    local f = map.colonyFunnel
    if not f then f = {}; map.colonyFunnel = f end
    local mode = map.universe.colonyOrders and "command" or "shadow"
    local counts = f[mode]
    if not counts then counts = {}; f[mode] = counts end
    return counts
end

-- Count the formation-time raider choice, not an arrival, an issue or a finished squad.
function funnel.groundSelected(map)
    funnel.add(cohort(map), "groundSelected")
end

function funnel.groundIssued(map)
    funnel.add(cohort(map), "groundIssued")
end

function funnel.raid(map, tick)
    local counts = cohort(map)
    -- The headline tick still dates the first eligible order, not the first raw issue.
    if not counts.raids then counts.first = tick end
    funnel.add(counts, "raids")
    return counts
end

-- Exactly one terminal reason per measured raid that stops before ready.
-- Keep output stable and omit empty reason groups, not zero funnel stages.
local reasons = {
    {"funnel-before", "funnel-busy", "funnel-fronts", "window-closed", "no-reserve", "funnel-unmatched", "funnel-probe"},
    {"funnel-during", "incomplete", "no-reserve", "both-guarded", "window-closed", "funnel-response", "funnel-witnesses", "funnel-redirect"},
    {"funnel-after", "status-no-target", "status-target-lost", "status-no-slot", "status-no-group", "status-out-of-range", "status-no-route",
        "status-repeat-repulse", "status-keep-task", "status-local-task", "status-unknown-task", "status-no-edge", "status-choice-budget", "status-shift-unconfirmed", "status-shift-off-route", "status-new-cover", "status-missing-reports", "status-occupied", "status-expired", "status-closed"}
}

local function show(lines, mode, f)
    lines[#lines+1] = {"rampant-colony.funnel", {"rampant-colony.funnel-" .. mode}, f.first or "—",
        f.raids or 0, f.observed or 0, f.advised or 0, f.live or 0, f.gathered or 0, f.ready or 0}
    lines[#lines+1] = {"rampant-colony.ground-issued", f.groundIssued or 0}
    lines[#lines+1] = {"rampant-colony.ground-selected", f.groundSelected or 0}
    for _, group in ipairs(reasons) do
        local parts = {""}
        for i = 2, #group do
            local reason = group[i]
            local n = f[group[1] .. ":" .. reason]
            if n then
                if #parts > 1 then parts[#parts+1] = "; " end
                parts[#parts+1] = {"rampant-colony.funnel-count", {"rampant-colony." .. reason}, n}
                -- Factorio limits a LocalisedString to 20 parameters.
                if #parts >= 8 then
                    lines[#lines+1] = {"rampant-colony." .. group[1], parts}; parts = {""}
                end
            end
        end
        if #parts > 1 then lines[#lines+1] = {"rampant-colony." .. group[1], parts} end
    end
end

function funnel.stop(counts, phase, reason)
    if counts then funnel.add(counts, phase .. ":" .. reason) end
end

function funnel.report(map, lines)
    local f = map.colonyFunnel or {}
    local mode = map.universe.colonyMind and (map.universe.colonyOrders and "command" or "shadow")
    if f.shadow or mode == "shadow" then show(lines, "shadow", f.shadow or {}) end
    if f.command or mode == "command" then show(lines, "command", f.command or {}) end
end

return funnel
