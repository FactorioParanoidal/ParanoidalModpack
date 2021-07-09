function shallowcopy(old)
	if type(old) ~= 'table' then
		return old
	end

	local new = {}
	for i, v in pairs(old) do
		new[i] = v
	end
	return setmetatable(new, getmetatable(old))
end
