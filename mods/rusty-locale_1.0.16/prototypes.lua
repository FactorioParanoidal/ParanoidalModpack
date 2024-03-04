local hierarchy = require '__rusty-locale__.type-hierarchy'


local _M = {}


local function is_known(type)
	return hierarchy.top_down[type] or hierarchy.bottom_up[type]
end


function _M.descendants(type)
--- Get the tree of descendants, rooted at the given type, or nil if the type doesn't exist.
	if type == nil then return hierarchy.bottom_up; end
	if not is_known(type) then log(("Checking descendants of unknown type `%s`!"):format(type)) end
	return _M.descendants(hierarchy.top_down[type])[type]
end

local function inherits(type, bases)
	if type == nil then return nil; end
	if bases[type] then return type; end
	return inherits(hierarchy.top_down[type], bases)
end
function _M.inherits(t, bases)
--- Check if type is a descendant either a single base prototype or any of several prototypes provided as a table {string: boolean}.
--- This returns the type that matched, or nil of none did.
	if type(bases) ~= 'table' then return _M.inherits(t, {[bases] = true}); end
	if not is_known(t) then log(("Checking inheritance of unknown type `%s`!"):format(t)) end
	return inherits(t, bases)
end

function _M.find(name, type, silent)
--- Find the prototype with the given name, whose type inherits from the given type, or nil if it doesn't exist.
	if type == nil then error "find needs a type - use find_by_name to search by name only instead."; end
	if name == nil then
		if silent then return nil; end
		error "Can't find a prototype with nil name"
	end
	
	for t, prototypes in pairs(data.raw) do
		local prototype = prototypes[name]
		if prototype and _M.inherits(t, type) then return prototype; end
	end
	if silent then return nil; end
	
	local existing_types = {}
	for t, _ in pairs(_M.find_by_name(name)) do table.insert(existing_types, t); end
	error(("No prototype called `%s` found for type `%s`, these prototypes with the name exist: %s\nPlease report this to https://mods.factorio.com/mod/rusty-locale")
		:format(name, type, serpent.line(existing_types)))
end

function _M.find_by_name(name)
--- Find all prototypes with the given name. Returns a table of {type: prototype}.
	local results = {}
	for t, prototypes in pairs(data.raw) do results[t] = prototypes[name]; end
	return results
end


return _M
