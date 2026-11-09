-- Implementation of an internal event backplane.

local tinsert = table.insert

local lib = {}

-- strace support
local strace = nil
local TRACE = 10
local mod_name = script.mod_name

--selene: allow(unused_variable)

---Create an event.
---@deprecated Use `event` instead.
---@generic T1, T2, T3, T4, T5
---@param name string The name of the event
---@param p1 `T1` Unused, but required for type inference
---@param p2 `T2` Unused, but required for type inference
---@param p3 `T3` Unused, but required for type inference
---@param p4 `T4` Unused, but required for type inference
---@param p5 `T5` Unused, but required for type inference
---@return fun(handler: fun(p1: T1, p2: T2, p3: T3, p4: T4, p5: T5), first: boolean?) on Register a handler for the event. If `first` is true, the handler will be called before other handlers. `first` should be used advisedly, preferably only by the subsystem that owns the event.
---@return fun(p1: T1, p2: T2, p3: T3, p4: T4, p5: T5) raise Raise the event
local function create_event(name, p1, p2, p3, p4, p5)
	local bindings = {}
	local function on(f, is_first)
		if is_first then
			tinsert(bindings, 1, f)
		else
			bindings[#bindings + 1] = f
		end
	end
	local function raise(...)
		if strace then
			strace(TRACE, "mod", mod_name, "event", name, "message", ...)
		end
		for i = 1, #bindings do
			bindings[i](...)
		end
	end
	return on, raise
end
lib.create_event = create_event

---Set strace handler. `nil` disables tracing entirely.
---@param handler? fun(level: int, ...)
function lib.set_strace_handler(handler) strace = handler end

return lib
