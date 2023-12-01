--local MATCH_CACHE = {}

local tracker = {
	["add"] = {},
	["remove"] = {},
	--["globals"] = {}
}

local matchTracker = {
	["add"] = {},
	["remove"] = {},
	--["globals"] = {}
}

local tickGroups = {}

--call from all the entity creation/place/build events
function trackEntityAddition(entity, glbl)
	--local glbl = getGlobal(entity.name)
	local func = tracker["add"][entity.name]
	if func then
		func(glbl, entity, entity.force)
	else
		for k,func in pairs(matchTracker["add"]) do
			if string.find(entity.name, k, 1, true) then
				func(glbl, entity, entity.force)
			end
		end
	end
end

--call from all the entity removal/died/mined events
function trackEntityRemoval(entity, glbl)
	--local glbl = getGlobal(entity.name)
	local func = tracker["remove"][entity.name]
	if func then
		func(glbl, entity, entity.force)
	else
		for k,func in pairs(matchTracker["remove"]) do
			if string.find(entity.name, k, 1, true) then
				func(glbl, entity, entity.force)
			end
		end
	end
end

--call from onTick
function runTickHooks(glbl, tick)
	for _,func in pairs(tickGroups) do
		func(glbl, tick)
	end
end

--[[
local function getOrCreateTickGroup(id, glbl)
	if not tickGroups[id] then
		tickGroups[id] = {id = id, getGlobal = glbl, calls = {}}
	end
	return tickGroups[id]
end

function getGlobal(name)
	local func = tracker["globals"][name]
	if not func then 
		for k,func2 in pairs(matchTracker["globals"]) do
			game.print("Checking for '" .. k .. "' in '" .. name .. "'")
			if string.find(name, k, 1, true) then
				func = func2
			end
		end
	end
	if func then
		return func()
	else
		game.print("Entity '" .. name .. "' with no remove hook?")
	end
end
--]]

function addTracker(name, add, _remove, tick--[[, globalID, glbl--]])
	log("Registering entity tracker for '" .. name .. "'")
	--local hook = getOrCreateTickGroup(globalID, glbl)
	--table.insert(hook.calls, tick)
	tracker["add"][name] = add
	tracker["remove"][name] = _remove
	table.insert(tickGroups, tick)
	--tracker["globals"][name] = glbl
end

--[[
function buildMatchCache()
	for n,proto in pairs(game.entity_prototypes) do
		for k,entry in pairs(MATCH_CACHE) do
			if string.find(n, k, 1, true) then
				addTracker(n, entry.onAdd, entry.onRemove, entry.onTick)
			end
		end
	end
end

function addMatcherTracker(name, add, _remove, tick)
	MATCH_CACHE[name] = {name = name, onAdd = add, onRemove = _remove, onTick = tick}
end
--]]

function addMatcherTracker(name, add, _remove, tick--[[, globalID, glbl--]])
	log("Registering string-search entity tracker for '" .. name .. "'")
	--local hook = getOrCreateTickGroup(globalID, glbl)
	--table.insert(hook.calls, tick)
	matchTracker["add"][name] = add
	matchTracker["remove"][name] = _remove
	table.insert(tickGroups, tick)
	--matchTracker["globals"][name] = glbl
end


--remote.add_interface("entitytracker", {addTracker = addTracker, addMatcherTracker = addMatcherTracker})