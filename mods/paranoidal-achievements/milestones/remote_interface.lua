-- Allocate once while control.lua loads, as for the other custom-event providers.
local event_id = script.generate_event_name()
local M = {}

remote.add_interface("milestones", {
    get_on_milestone_reached_event = function() return event_id end,
})

function M.raise(force, milestone, message)
    script.raise_event(event_id, {
        force = force,
        name = milestone.name,
        milestone_name = milestone.name,
        type = milestone.type,
        quality = milestone.quality,
        quantity = milestone.quantity,
        completion_tick = milestone.completion_tick,
        message = message,
    })
end

return M
