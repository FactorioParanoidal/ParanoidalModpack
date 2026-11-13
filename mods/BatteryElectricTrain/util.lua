function shallowcopy(old)
	if type(old) ~= 'table' then
		error("Попытка создать поверхностную копию объекта, не являющегося таблицей, вероятно, является ошибкой.")
	end

	local new = {}
	for i, v in pairs(old) do
		new[i] = v
	end
	return setmetatable(new, getmetatable(old))
end

function table_merge(t1, t2)
	local t1l = #t1
	for i, v in pairs(t2) do
		t1[t1l+i] = t2[i]
	end
    	return t1
end
