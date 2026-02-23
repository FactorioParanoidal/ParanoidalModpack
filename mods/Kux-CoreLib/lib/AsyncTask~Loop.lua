--- Loop factory
---@class KuxCoreLib.AsyncTask.LoopFactory
local LoopFactory = {}

---@class KuxCoreLib.AsyncTask.Loop
---@field type "numeric"|"values"|"func"|"dynamic"|"chunks"
---@field identifier string
---@field start integer? "numeric" only
---@field stop integer? "numeric" only
---@field values table? "values" only
---@field iterator LuaChunkIterator? "chunks" only
---@field func string? "func"|"dynamic" only

---@type KuxCoreLib.AsyncTask.private
local async = nil

---@param name string identifier
---@param surface LuaSurface
---@return KuxCoreLib.AsyncTask.Loop
function LoopFactory.chunks(name, surface)
	---@type KuxCoreLib.AsyncTask.Loop
	local loop = {type = "chunks", identifier = name, iterator = surface.get_chunks() }
	return loop
end

---@param name string identifier
---@param func function
---@return KuxCoreLib.AsyncTask.Loop
function LoopFactory.dynamic(name, func)
	if async.dynamic_functions[name] then error("Dynamic loop function " .. name .. " already registered") end
	async.dynamic_functions[name] = func
	---@type KuxCoreLib.AsyncTask.Loop
	local loop = { type = "dynamic", identifier = name}
	return loop
end

---@param name string identifier
---@return KuxCoreLib.AsyncTask.Loop
-- <p>function are registered with Async.configure_loop_functions, name must match one of these functions
function LoopFactory.func(name)
	return { type = "func", identifier = name }
end

--- Creates a 'for' loop
---@param name string identifier
---@param start integer
---@param stop integer
---@return KuxCoreLib.AsyncTask.Loop
function LoopFactory.numeric(name, start, stop)
	if start == nil or stop == nil then error("Unable to loop using start or stop as nil: " .. tostring(start) .. " - " .. tostring(stop)) end
	return { type = "numeric", identifier = name, start = start, stop = stop }
end

--- Creates a 'foreach' loop
---@param name string identifier
---@param values (number|boolean|string|table|userdata)[]
---@return KuxCoreLib.AsyncTask.Loop
function LoopFactory.values(name, values)
	return { type = "values", identifier = name, values = values }
end

function inject(_async) async = _async; return LoopFactory end
return inject