if data.raw.technology["fe-c-accumulator"] and data.raw.technology["bob-electricity"] then
	data.raw.technology["fe-c-accumulator"].prerequisites = data.raw.technology["fe-c-accumulator"].prerequisites or {}
	table.insert(data.raw.technology["fe-c-accumulator"].prerequisites, "bob-electricity")
end
