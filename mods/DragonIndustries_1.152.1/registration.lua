function registerObjectArray(objects)
	for _,obj in pairs(objects) do
		if type(obj) == "table" then
			data:extend({obj})
		end
	end
end

--This is an expensive function to call!
function getPrototypeByName(name)
	for catname,cat in pairs(data.raw) do
		for pname,proto in pairs(cat) do
			if name == pname then
				return proto
			end
		end
	end
end