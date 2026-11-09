local Public = {}

local WARN_COLOR = { r = 255, g = 90, b = 54 }

---Whether the on-join warning should run.
--
-- The warning is only useful on the first tick of a newly started save; a
-- player joining an existing save must not be spammed with warnings. Keeping
-- this decision in a pure function lets the FUnit suite test both the tick and
-- setting axes without changing startup settings.
---@param tick integer
---@param setting_value boolean|nil
---@return boolean
function Public.should_warn_on_join(tick, setting_value)
	return setting_value == true and tick == 0
end

local function format_tech_list(techs, max_techs)
	max_techs = max_techs or 10
	if #techs <= max_techs then
		return table.concat(techs, ", ")
	else
		local shown = {}
		for i = 1, max_techs do
			table.insert(shown, techs[i])
		end
		return table.concat(shown, ", ") .. ", ... (see game logs for full list)"
	end
end

function Public.warn_unreachable_techs()
	if #prototypes.mod_data["Planetslib"].data.unlinked_prerequisites > 0 then
		return Public.warn_unlinked_prerequisites()
	end

	local hidden_prereq_successors = {}

	for _, tech in pairs(prototypes.technology) do
		if not tech.hidden then
			for _, prereq in pairs(tech.prerequisites) do
				if prereq.hidden then
					if not hidden_prereq_successors[prereq.name] then
						hidden_prereq_successors[prereq.name] = {}
					end
					table.insert(hidden_prereq_successors[prereq.name], tech.name)
				end
			end
		end
	end

	local warnings = {}
	local full_warnings = {}
	for prereq_name, successors in pairs(hidden_prereq_successors) do
		local tech_links = {}
		for _, tech_name in pairs(successors) do
			table.insert(tech_links, "[technology=" .. tech_name .. "]")
		end
		local full_successor_list = table.concat(tech_links, ", ")
		local formatted_successor_list = format_tech_list(tech_links)
		local warning_msg = formatted_successor_list .. " due to hidden prerequisite '" .. prereq_name .. "'"
		local full_warning_msg = full_successor_list .. " due to hidden prerequisite '" .. prereq_name .. "'"
		table.insert(warnings, warning_msg)
		table.insert(full_warnings, full_warning_msg)
	end

	if #warnings > 0 then
		local all_warnings = table.concat(warnings, ", ")
		local full_all_warnings = table.concat(full_warnings, ", ")
		log("PlanetsLib: " .. full_all_warnings)
		game.print({
			"",
			{ "planetslib.planetslib-print" },
			{ "planetslib.warn-unreachable-techs", all_warnings },
		}, { color = WARN_COLOR })
	end
end

function Public.warn_unlinked_prerequisites()
	local prerequisites = {}
	for _, prerequisite in pairs(prototypes.mod_data["Planetslib"].data.unlinked_prerequisites) do
		table.insert(prerequisites, prerequisite)
	end
	local full_all_warnings = table.concat(prerequisites, ", ")
	local all_warnings = format_tech_list(prerequisites)

	log("PlanetsLib: " .. full_all_warnings)
	game.print({
		"",
		{ "planetslib.planetslib-print" },
		{ "planetslib.notify-unlinked-prerequisites", all_warnings },
	}, { color = WARN_COLOR })
end

return Public
