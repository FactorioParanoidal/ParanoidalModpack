local lib = require("lib.lib")
local tech = require("lib.technology")

--== Prevent hidden prerequisites ==--

if settings.startup["PlanetsLib-unlink-hidden-prerequisites"].value then
	for _, technology in pairs(data.raw.technology) do
		if technology and technology.prerequisites and not technology.hidden then
			local valid_prereqs = {}
			for _, prereq_name in ipairs(technology.prerequisites) do
				local prereq_tech = data.raw.technology[prereq_name]
				if prereq_tech then
					if prereq_tech.hidden then
						if
							not lib.find(data.raw["mod-data"]["Planetslib"].data.unlinked_prerequisites, prereq_name)
						then
							table.insert(data.raw["mod-data"]["Planetslib"].data.unlinked_prerequisites, prereq_name)
						end
					else
						table.insert(valid_prereqs, prereq_name)
					end
				end
			end
			technology.prerequisites = valid_prereqs
		end
	end
end

if data.raw["lab"]["lab"] then
	local vanilla_lab = data.raw["lab"]["lab"]

	--== Legacy APIs:

	for _, value in pairs(data.raw["technology"]) do
		if
			(
				value["planetslib_ensure_all_packs_from_vanilla_lab"]
				and value["planetslib_ensure_all_packs_from_vanilla_lab"] == true
			)
			or (value["ensure_all_packs_from_vanilla_lab"] and value["ensure_all_packs_from_vanilla_lab"] == true) -- support for legacy field
		then
			tech.set_science_packs_from_lab(value, vanilla_lab)
		end
	end

	local vanilla_lab_inputs = tech.sort_science_pack_names(vanilla_lab.inputs)
	vanilla_lab.inputs = vanilla_lab_inputs

	if data.raw["lab"]["biolab"] then
		data.raw["lab"]["biolab"].include_all_lab_science = true
	end

	for _, new_lab in pairs(data.raw["lab"]) do
		if new_lab["include_all_lab_science"] == true then
			for _, input in pairs(vanilla_lab_inputs) do
				if not lib.contains(new_lab.inputs, input) then
					table.insert(new_lab.inputs, input)
				end
			end
			new_lab.inputs = tech.sort_science_pack_names(new_lab.inputs)
		elseif
			new_lab["planetslib_sort_sciences"] == true or new_lab["sort_sciences"] == true -- support for legacy field
		then
			local local_inputs = new_lab.inputs
			new_lab.inputs = tech.sort_science_pack_names(local_inputs)
		end
	end
end
