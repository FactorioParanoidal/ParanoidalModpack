-- From zzzcompability (Tias): remove Bob's obsolete sand/glass research before core tech patches.
assert(data.raw and data.raw.technology, "Ожидалось наличие data.raw.technology, но оно равно nil")
data.raw.technology["sand-processing"] = nil
data.raw.technology["glass-processing"] = nil

for _, tech in pairs(data.raw.technology) do
	if tech.prerequisites then
		for i = #tech.prerequisites, 1, -1 do
			local prerequisite = tech.prerequisites[i]
			if prerequisite == "glass-processing" or prerequisite == "sand-processing" then
				table.remove(tech.prerequisites, i)
			end
		end
	end
end
