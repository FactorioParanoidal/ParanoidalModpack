---


---@class KuxGuiLib.ElementStackTrace.static
local ElementStackTrace = {
	__class = "KuxGuiLib.ElementStackTrace.static"
}

---@class ElementStackTrace
---@field stack table
local methods = {}

local meta = { __index = methods }

---
---@return ElementStackTrace
function ElementStackTrace.new()
	local self = {
		stack = {}
	}
	setmetatable(self, meta)
	return self
end

function methods:push(args)
	table.insert(self.stack, args)
end

function methods:pop()
	table.remove(self.stack)
end

function methods:toString()
	local lines = {}
	for index, args in ipairs(self.stack) do
		local params = ""

		if args.name and args.name:sub(1,1) ~= "@" then
			params = " '"..args.name.."'"
		else
			local parts = {}
			for k, v in pairs(args) do
				if k == "type" or k == "name" then goto next end
				if k ~= "tooltip" and k ~= "caption" and not k:match("^on_") then goto next end
				local s = type(v) == "string" and k.."=\""..v.."\"" or  k.."="..tostring(v)
				table.insert(parts, s)
				::next::
			end
			params = " " .. table.concat(parts, " ")
		end

		local message = "    "..args.type..params..""
		table.insert(lines, message)
	end

	return table.concat(lines, "\n")
end

return ElementStackTrace