local math2d = require("math2d")
local bigpack = require("__big-data-string__.pack")


local function map(t,f)
	local r = {} for k,v in pairs(t) do r[k] = f(v) end return r
end

local function encode(t)
	return table.concat(map(t,tostring), ",")
end



local function hack_connections(prototype)
	local connections = {}
	if prototype.heat_buffer then
		for _,connection in ipairs(prototype.heat_buffer.connections or {}) do
			local d = assert(connection.direction, "direction missing")
			local p = assert(connection.position, "position missing")
			p = math2d.position.ensure_xy(p)
			-- append triple
			table.insert(connections, d)
			table.insert(connections, p.x)
			table.insert(connections, p.y)
		end
	end
	data:extend{bigpack(prototype.name .. "-heat-buffer-connections", encode(connections))}
end


local function is_internal(prototype)
	return prototype.type == "reactor"
	   and string.sub(prototype.name, 1,17) == "realistic-reactor"
	   and not       (prototype.name        == "realistic-reactor")
end


for _,type in ipairs{"reactor","heat-pipe"} do
	for _,prototype in pairs(data.raw[type]) do
		if not is_internal(prototype) then
			hack_connections(prototype)
		end
	end
end

