require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.BigData
local BigData ={
	__class  = "BigData",
	__guid   = "3180d12b-7961-4a00-b425-6baaecb27180",
	__origin = "Kux-CoreLib/lib/data/BigData.lua",
}
if not KuxCoreLib.__classUtils.ctor(BigData) then return self end
---------------------------------------------------------------------------------------------------


local MAX = 10 * 20 ^ 21 -- 20 parameters * 20 recursion depth
local suffix = "Kux-CoreLib_BigData_"

if(KuxCoreLib.ModInfo.current_stage:match("^data")) then

	local function depth(n)
		return math.ceil(math.log(n / 10) / math.log(20)) - 1
	end

	local function insert(nodes, node, value)
		table.insert(node, value) -- store as parameter
		if 21 == #node then
			node = {""}
			table.insert(nodes, node)
		end
		return node
	end

	local function encode(data)
		local node = {""}
		local root = {node}
		local n = string.len(data)
		for i = 1,n,200 do
			local value = string.sub(data, i, i+199)
			node = insert(root, node, value)
		end
		while #root > 20 do
			local nodes,node = {},{""}
			for _, value in ipairs(root) do
				node = insert(nodes, node, value)
			end
			root = nodes
		end
		if #root == 1 then root = root[1] else
			table.insert(root, 1, "") -- no locale template
		end
		return #root < 3 and (root[2] or "") or root
	end

	function BigData.pack(name, stringdata)
		assert(type(name) == "string", "missing name!")
		assert(type(stringdata) == "string", "not a string!")
		local len = string.len(stringdata)
		assert(len <= MAX, "string too long!")
		if depth(len) > 4 then -- 10*20^(1+4) = 32MB
			log(string.format("WARNING! '%s' exceeds reasonable recursion depth of 4 (32MB). Expect performance degradation!", name))
		end
		data:extend{{
			-- type = "item",
			type = "flying-text", time_to_live = 0, speed = 1, -- reqired for a valid prototype
			name = "Kux-CoreLib_BigData_" .. name,
			icon = "__core__/graphics/empty.png",
			icon_size = 1,
			stack_size = 1,
			-- flags = {"hidden","hide-from-bonus-gui","hide-from-fuel-tooltip"},
			flags = {"hidden"},
			localised_name = string.format("BIGDATA[%s]", name),
			localised_description = encode(stringdata),
			order = "z",
		}}
	end
end

if(KuxCoreLib.ModInfo.current_stage:match("^control")) then

	local function decode(data)
		if type(data) == "string" then return data end
		local str = {}
		for i = 2, #data do
			str[i-1] = decode(data[i])
		end
		return table.concat(str, "")
	end

	function BigData.unpack(name)
		assert(type(name) == "string", "missing name!")
		-- local prototype = assert(game.item_prototypes[suffix ..  name],
		-- 				string.format("big data '%s' not defined!", name))
		local prototype = assert(prototypes.entity[suffix ..  name],
						string.format("big data '%s' not defined!", name))
		return decode(prototype.localised_description)
	end

end


---------------------------------------------------------------------------------------------------
function BigData.asGlobal() return KuxCoreLib.__classUtils.asGlobal(BigData) end
return BigData