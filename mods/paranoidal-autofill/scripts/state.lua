-- Per-player rules in storage.
-- storage.players[index] = { on_build = bool, show = "learned"|"all",
--   rules = { {entity, enabled, items = { {name, quality, count} } } } }
-- rule.entity is always a main building; its variants use the same rule.

local compat = require("__paranoidal-autofill__/scripts/compat")

local M = {}

M.MAX_ITEMS = 10
M.MAX_COUNT = 10000
M.DEFAULT_COUNT = 10

function M.init()
	storage.players = storage.players or {}
	storage.pending = storage.pending or {}
end

function M.player(index)
	local data = storage.players[index]
	if not data then
		data = { on_build = true, show = "learned", rules = {} }
		storage.players[index] = data
	end
	return data
end

function M.clamp_count(n)
	n = math.floor(tonumber(n) or 0)
	if n < 1 then return 1 end
	if n > M.MAX_COUNT then return M.MAX_COUNT end
	return n
end

function M.default_count(item_name)
	local proto = prototypes.item[item_name]
	local stack = proto and proto.stack_size or M.DEFAULT_COUNT
	return math.max(1, math.min(M.DEFAULT_COUNT, stack))
end

function M.item_allowed(entity_name, item_name, quality)
	local info = compat.entity(entity_name)
	return info ~= nil and info.item_set[item_name] == true
		and prototypes.item[item_name] ~= nil
		and prototypes.quality[quality or "normal"] ~= nil
end

function M.find_rule(data, entity_name)
	for i, rule in ipairs(data.rules) do
		if rule.entity == entity_name then return rule, i end
	end
end

-- Rule for a placed building or its variant (hero turret rank, per-ore drill copy).
function M.rule_for(data, entity_name)
	local rule = M.find_rule(data, entity_name)
	if rule then return rule end
	local main = compat.canonical(entity_name)
	if main and main ~= entity_name then return M.find_rule(data, main) end
end

-- Drops what no longer exists or no longer fits after a mod change.
function M.validate(data)
	if type(data.rules) ~= "table" then data.rules = {} end
	if data.on_build == nil then data.on_build = true end
	if data.show ~= "all" then data.show = "learned" end
	local rules, seen = {}, {}
	for _, rule in ipairs(data.rules) do
		-- 1.0.0 could hold a variant: move it to the main building.
		local main = type(rule) == "table" and type(rule.entity) == "string" and compat.canonical(rule.entity)
		if main and not seen[main] then
			rule.entity = main
			seen[main] = true
			local items = {}
			for _, it in ipairs(type(rule.items) == "table" and rule.items or {}) do
				if type(it) == "table" and type(it.name) == "string"
					and M.item_allowed(rule.entity, it.name, it.quality) and #items < M.MAX_ITEMS then
					items[#items + 1] = { name = it.name, quality = it.quality or "normal", count = M.clamp_count(it.count) }
				end
			end
			rules[#rules + 1] = { entity = rule.entity, enabled = rule.enabled ~= false, items = items }
		end
	end
	data.rules = rules
end

function M.validate_all()
	for index, data in pairs(storage.players) do
		if game.get_player(index) then
			M.validate(data)
		else
			storage.players[index] = nil
		end
	end
end

return M
