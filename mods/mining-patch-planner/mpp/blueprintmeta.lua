local EAST = defines.direction.east
local NORTH = defines.direction.north
local SOUTH = defines.direction.south
local WEST = defines.direction.west

---@class EvaluatedBlueprint
---@field valid boolean Are all blueprint entities valid
---@field w number
---@field h number
---@field tw number Runtime transposed width
---@field th number Runtime transposed height
---@field ox number Start offset x
---@field oy number Start offset y
---@field entities BlueprintEntityEx[] All entities in the blueprint
---@field entity_names table<string, number>
---@field miner_name string Mining drill name
local bp_meta = {}
bp_meta.__index = bp_meta

---@class BlueprintEntityEx : BlueprintEntity
---@field capstone_x boolean
---@field capstone_y boolean

---Blueprint analysis data
---@param bp LuaItemStack
---@return EvaluatedBlueprint
function bp_meta:new(bp)
	---@type EvaluatedBlueprint
	local new = setmetatable({}, self)

	new.valid = true
	new.w, new.h = bp.blueprint_snap_to_grid.x, bp.blueprint_snap_to_grid.y
	new.ox, new.oy = 0, 0
	if bp.blueprint_position_relative_to_grid then
		new.ox = bp.blueprint_position_relative_to_grid.x
		new.oy = bp.blueprint_position_relative_to_grid.y
	end
	new.entities = bp.get_blueprint_entities() or {}
	new.entity_names = bp.cost_to_build

	new:evaluate_tiling()
	new:evaluate_miners()

	return new
end

---Marks capstone BlueprintEntities
function bp_meta:evaluate_tiling()
	local sw, sh = self.w, self.h
	local buckets_x, buckets_y = {}, {}

	for i, ent in pairs(self.entities) do
		local x, y = ent.position.x, ent.position.y
		ent.direction = ent.direction or NORTH
		if not buckets_x[x] then buckets_x[x] = {} end
		table.insert(buckets_x[x], ent)
		if not buckets_y[y] then buckets_y[y] = {} end
		table.insert(buckets_y[y], ent)

	end

	for _, bucket in pairs(buckets_y) do
		for i = 1, #bucket-1 do
			local e1 = bucket[i] ---@type BlueprintEntityEx
			local e1x = e1.position.x
			for j = 2, #bucket do
				local e2 = bucket[j] ---@type BlueprintEntityEx
				local e2x = e2.position.x
				if e1x + sw == e2x or e1x - sw == e2x then
					e2.capstone_x = true
				end
			end
		end
	end

	for _, bucket in pairs(buckets_x) do
		for i = 1, #bucket-1 do
			local e1 = bucket[i] ---@type BlueprintEntityEx
			local e1y = e1.position.y
			for j = 2, #bucket do
				local e2 = bucket[j] ---@type BlueprintEntityEx
				local e2y = e2.position.y
				if e1y + sh == e2y or e1y - sh == e2y then
					e2.capstone_y = true
				end
			end
		end
	end
end

function bp_meta:evaluate_miners()
	for _, ent in pairs(self.entities) do
		local name = ent.name
		if game.entity_prototypes[name].type == "mining-drill" then
			--local proto = game.entity_prototypes[name]
			self.miner_name = name
			return
		end
	end
end

---@return BlueprintEntityEx[]
function bp_meta:get_mining_drills()
	local miner_name = self.miner_name
	local mining_drills = {}
	for _, ent in pairs(self.entities) do
		if ent.name == miner_name then
			mining_drills[#mining_drills+1] = ent
		end
	end
	return mining_drills
end

function bp_meta:check_valid()
	for k, v in pairs(self.entity_names) do
		if not game.entity_prototypes[k] and not game.item_prototypes[k] then
			self.valid = false
			return false
		end
	end
	self.valid = true
	return true
end

---Returns resource categories for a blueprint
---@return table<string, boolean>
function bp_meta:get_resource_categories()
	local categories = {}
	local proto = game.entity_prototypes[self.miner_name]
	if proto.resource_categories then
		for cat, bool in pairs(proto.resource_categories) do
			categories[cat] = bool
		end
	end
	return categories
end

---@return table<string, GridBuilding>
function bp_meta:get_entity_categories()
	---@type table<string, GridBuilding>
	local categories = {
		["mining-drill"] = "miner",
		["beacon"] = "beacon",
		["transport-belt"] = "belt",
		["underground-belt"] = "belt",
		["splitter"] = "belt",
		["inserter"] = "inserter",
		["container"] = "container",
		["logistic-container"] = "container",
		["loader"] = "inserter",
		["loader-1x1"] = "inserter",
		["electric-pole"] = "pole",
	}

	---@type table<string, GridBuilding>
	local category_map = {}

	for _, ent in pairs(self.entities) do
		local name = ent.name
		local category = category_map[name]
		if not category then
			local ent_type = game.entity_prototypes[name].type
			category = categories[ent_type] or "other"
			category_map[name] = category
		end
	end

	return category_map
end

return bp_meta
