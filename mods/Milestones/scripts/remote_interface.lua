On_milestone_reached_event = nil -- global

local interface = {}

function interface.get_on_milestone_reached_event()
	if not on_milestone_reached then on_milestone_reached = script.generate_event_name() end
	return on_milestone_reached
end

remote.add_interface("milestones", interface)
