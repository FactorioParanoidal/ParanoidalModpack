
-- Update helper metatables
local function refreshHelpers(obj)
	if type(obj) == "table" then 
		for key,val in pairs(obj) do
			refreshHelpers(val)
		end

		if rawget(obj, "__on") ~= nil then
			rawset(obj, "__mt", "helpers")
		end
	end
end

refreshHelpers(storage)



-- Update player cache metatables
if storage.cache then
	for __,cache in pairs(storage.cache) do
		if storage.markers then  rawset(cache.markers, "__mt", "entityAsIndex") end
		if storage.entities then rawset(cache.entities, "__mt", "entityAsIndex") end
	end
end


log("Even Distribution: Global metatables have been updated")