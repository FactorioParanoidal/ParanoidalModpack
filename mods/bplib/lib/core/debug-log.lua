-- Generic and simplistic debug logging facility.

local strace = require("lib.core.strace")

---Log all arguments to the debug log. Also logs using `game.print` if
---`print_debug_log` is set. Arguments are automatically stringified by
---`serpent.line`.
---@param ... any
function debug_log(...) return strace.debug(...) end

---Crash with an error string containing all arguments stringified by `serpent.line`.
---@param ... any
function debug_crash(...)
	local x = table.pack(...)
	x.n = nil
	if #x == 1 then x = x[1] end
	local line = serpent.line(x, { nocode = true })
	error(line)
end
