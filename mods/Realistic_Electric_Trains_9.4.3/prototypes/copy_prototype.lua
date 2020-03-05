--copy_prototype.lua

require("util")

function copy_table(data, new_name)
	local p = table.deepcopy(data)
	p.name = new_name

	if p.minable and p.minable.result then
		p.minable.result = new_name
	end

	if p.place_result then
		p.place_result = new_name
	end

	if p.result then
		p.result = new_name
	end

	if p.results then
		for _,result in pairs(p.results) do
			if result.name == name then
				result.name = new_name
			end
		end
	end

	return p
end

function copy_prototype(type, name, new_name)
	local raw = data.raw[type][name]

	if not raw then 
		error("Prototype "..type..":"..name.." doesn't exist") 
	end

	return copy_table(raw, new_name)
end
