require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.StageBridge: KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.StageBridge
local StageBridge = {
	__class  = "KuxCoreLib.StageBridge",
	__guid   = "{9a6f6b02-3b9f-4f43-aff2-530d78d99357}",
	__origin = "Kux-CoreLib/lib/data/StageBridge.lua",
}
if not KuxCoreLib.__classUtils.ctor(StageBridge) then return self end
---------------------------------------------------------------------------------------------------


local MAX = 10 * 20 ^ 21 -- 20 parameters * 20 recursion depth
local data_category="trivial-smoke"
local runtime_category = "trivial_smoke"



local function depth(n)
    return math.ceil(math.log(n / 10) / math.log(20)) - 1
end

local function insert(nodes, node, value)
    table.insert(node, value)
    if #node == 21 then
        newNode  = { "" }
        table.insert(nodes, newNode )
		return newNode
    end
    return node
end

local function encode(data)
    local node = { "" }
    local root = { node }
    local n = string.len(data)
    for i = 1, n, 200 do
        local value = string.sub(data, i, i + 199)
        node = insert(root, node, value)
    end

	while #root > 20 do
		local nodes = {}
		local newNode = { "" }
		table.insert(nodes, newNode) -- Ensure the first node exists
		for _, value in ipairs(root) do
			newNode = insert(nodes, newNode, value)
		end
		if #newNode > 1 and nodes[#nodes] ~= newNode then
			table.insert(nodes, newNode)
		end
		root = nodes
	end

    if #root == 1 then root = root[1]
	else table.insert(root, 1, "") -- no locale template
    end
    return #root < 3 and (root[2] or "") or root
end

local function packTo(prototype, string_data, name)
	assert(type(prototype) == "table", "invalid prototype")
	assert(type(name) == "string", "invalid name!")
    local n = string.len(string_data)
    assert(n <= MAX, "string too long!")
    if depth(n) > 4 then
        -- 10*20^(1+4) = 32MB
        log(string.format("WARNING! '%s' exceeds reasonable recursion depth of 4 (32MB). Expect performance degradation!", name))
    end
    prototype.localised_name = string.format("BIGDATA[%s]", name)
    prototype.localised_description = encode(string_data)
end

---@param name string setting name
---@param data_ number|boolean|string|table
function StageBridge.packSetting(name, data_)
	assert(type(name) == "string", "missing name!")
	assert(data.raw["string-setting"][name]==nil, "name already used. '"..name.."'")
	local strData = serpent.dump(data_)
	local pt = {
		type = "string-setting",
		name = name,
		setting_type = "startup",
		default_value = strData,
		hidden = true,
		order = "a",
	} --[[@as data.ModStringSettingPrototype]]
	data:extend{pt}
end

---@param name string
---@param data_ number|boolean|string|table
function StageBridge.packData(name, data_)
    assert(type(name) == "string", "missing name!")
	assert(data.raw[data_category][name]==nil, "name already used. '"..name.."'")
    local strData = serpent.dump(data_)
	--[[
    local pt = {
        type = "entity-ghost",
        name = name,
        icon = "__core__/graphics/empty.png",
        icon_size = 1,
        stack_size = 1,
        flags = { "not-on-map", "hide-alt-info", "not-blueprintable", "not-flammable" },
		hidden = true,
		hidden_in_factoriopedia = true,
        order = "ignore",
    }
	]]
	local pt = {
		type = data_category,
		name = name,
		flags = {"not-on-map"},
		duration = 60, -- Wie lange der Rauch bleibt (Ticks)
		spread_duration = 10, -- Wie lange es dauert, bis sich der Rauch verteilt
		start_scale = 0.5,
		end_scale = 0.1,
		color = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
		affected_by_wind = false,
		cyclic = true,
		animation = {
			filename = "__core__/graphics/empty.png", -- Leere Grafik als Platzhalter
			priority = "low",
			width = 1,
			height = 1,
			frame_count = 1,
			animation_speed = 1
		},
		order = "ignore",
		localised_name ="BIGSTRING-ignore"
	} --[[@as data.TrivialSmokePrototype]]
	packTo(pt, strData, name)
	data:extend{pt}
end

-----------------------------------------------------------------------------------------------------------------------
--- unpack
-----------------------------------------------------------------------------------------------------------------------

local function decode(data)
    if type(data) == "string" then return data end
    local str = {}
    for i = 2, #data do str[i - 1] = decode(data[i]) end
    local s = table.concat(str, "")
	return s
end

---@param name string
---@return any
function StageBridge.unpackSetting(name)
    assert(type(name) == "string", "missing name!")
	assert(settings.startup[name], string.format("data with name '%s' not defined!", name))
	local s = settings.startup[name].value --[[@as string]]
    local succes, value = serpent.load(s)
	return succes and value or error("failed to load data with name '"..name.."'")
end


---@param name string
---@return string|number|boolean|table|nil
function StageBridge.unpackData(name)
    assert(type(name) == "string", "missing name!")
	local pt = prototypes[runtime_category][name]
    assert(pt, string.format("data with name '"..name.."' not defined!", name))
	local s = decode(pt.localised_description)
	local succes, value = serpent.load(s)
	return succes and value or error("failed to load data with name '"..name.."'")
end

function StageBridge.hasData(name)
	assert(type(name) == "string", "missing name!")
	if prototypes then return prototypes[runtime_category][name] ~= nil end
	return data.raw[data_category][name] ~= nil
end

function StageBridge.hasSettings(name)
	assert(type(name) == "string", "missing name!")
	if settings then return settings.startup[name] ~= nil end
	return data.raw["string-setting"][name] ~= nil
end

-----------------------------------------------------------------------------------------------------------------------
--- Tests
-----------------------------------------------------------------------------------------------------------------------

if true then -- test encode/decode
	local temp = {}
	for i = 1, 1000 do
		table.insert(temp, "<"..tostring(i) .. string.rep(".", 200 - #tostring(i) - 2) .. ">")
	end
	local testing = table.concat(temp)
	local e = encode(testing)
	local d = decode(e)
	assert(testing == d, "encode/decode failed!")
end

return StageBridge

