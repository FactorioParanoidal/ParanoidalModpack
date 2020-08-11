--------------------------------------------------------------------
-- a generic function to walk into structure to manage avoid error when it does not exists.
local function walk(from, fields)
	if type(from) ~= "table" then return nil end
	local x = from
	if type(fields)~="table" then fields = {fields} end
	for _,field in ipairs(fields) do
		if type(x)~="table" or x[field] == nil then
			return nil
		end
		x = x[field]
	end
	return x
end
return walk
