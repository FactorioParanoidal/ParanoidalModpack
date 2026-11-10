-- Stable GUI identity, separate from display order. Existing saves acquire IDs lazily in events.
local M = {}

function M.assign(force_data, milestone)
    force_data.next_milestone_id = (force_data.next_milestone_id or 0) + 1
    milestone.id = force_data.next_milestone_id
    return milestone.id
end

function M.ensure(force_data)
    local maximum = force_data.next_milestone_id or 0
    for _, list in ipairs({force_data.complete_milestones, force_data.incomplete_milestones}) do
        for _, milestone in ipairs(list) do
            if type(milestone.id) == "number" and milestone.id % 1 == 0 then
                maximum = math.max(maximum, milestone.id)
            end
        end
    end
    force_data.next_milestone_id = maximum
    local used = {}
    for _, list in ipairs({force_data.complete_milestones, force_data.incomplete_milestones}) do
        for _, milestone in ipairs(list) do
            local id = milestone.id
            if type(id) ~= "number" or id < 1 or id % 1 ~= 0 or used[id] then
                id = M.assign(force_data, milestone)
            end
            used[id] = true
        end
    end
end

function M.find_complete(force_data, id)
    for _, milestone in ipairs(force_data.complete_milestones) do
        if milestone.id == id then return milestone end
    end
end

return M
