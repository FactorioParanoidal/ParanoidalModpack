require "arrays"

local function createCache()
	return {
		oreList = {},
		oreDropMap = {},
		oreDrops = {}
	}
end

local cache = createCache()

local function getDataHolder(isControlPhase)
	if isControlPhase then
		if not global.dragonindustries then
			global.dragonindustries = {}
		end
		local di = global.dragonindustries
		if not di.orecache then di.orecache = createCache() end
		return di.orecache
	else
		return cache
	end
end

local function loadResource(cache, name, proto, isControlPhase)
	local props = isControlPhase and proto.mineable_properties or proto.minable
	if props and ((not isControlPhase)or props.minable) then
		local products = isControlPhase and props.products or (props.results and props.results or {{type = "item", name = props.result}})
		if products and #products > 0 then
			table.insert(cache.oreList, name)
			local li = cache.oreDropMap[name]
			if not li then li = {} end
			for _,prod in pairs(products) do
				table.insert(li, prod.name and prod.name or prod[1])
				local item = prod.name and prod.name or prod[1]
				if not listHasValue(cache.oreDrops, item) then
					table.insert(cache.oreDrops, item)
				end
			end
			cache.oreDropMap[name] = li
		end
	end
end

local function loadAllOres(cache)
	if game then
		for name,resource in pairs(game.get_filtered_entity_prototypes({{filter="type", type="resource"}})) do
			loadResource(cache, name, resource, true)
		end
	else
		for name,proto in pairs(data.raw.resource) do
			loadResource(cache, name, proto, true)
		end
	end
end

function getAllOres()
	local cache = getDataHolder(game ~= nil)
	if cache == nil or #cache.oreList == 0 then
		loadAllOres(cache)
	end
	return cache.oreList
end

function getAllOreDropsFor(name)
	local cache = getDataHolder(game ~= nil)
	if cache == nil or #cache.oreList == 0 then
		loadAllOres(cache)
	end
	return cache.oreDropMap[name]
end

function getAllOreDrops()
	local cache = getDataHolder(game ~= nil)
	if cache == nil or #cache.oreList == 0 then
		loadAllOres(cache)
	end
	return cache.oreDrops
end