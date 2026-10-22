-- Radiation from carried radioactive items (Beta 8 RadioactiveDamage 0.0.4, reworked for 2.0).
-- Every INTERVAL ticks each radioactive item kind the character carries (main inventory, logistic
-- trash, cursor), plus a uranium ore deposit within ORE_RADIUS, deals DAMAGE once. Each source is a
-- separate hit, as in Beta 8, so the flat part of armor resistances applies per source.
-- Only the carrying character is damaged; the Beta 8 area stream also hit nearby buildings,
-- vehicles and players. Items of every quality count.

local INTERVAL = 10
local DAMAGE = 1
local DAMAGE_TYPE = "uranium-damage"
local DAMAGE_FORCE = "neutral"
local ORE_RADIUS = 10
local ITEM_NAMES = { "uranium-ore", "uranium-235", "uranium-238", "uranium-fuel-cell", "depleted-uranium-fuel-cell" }
local ORE_NAMES = { "uranium-ore" }

local MAIN = defines.inventory.character_main
local TRASH = defines.inventory.character_trash

-- Derived from prototypes only (identical on every peer); rebuilt after each load.
local items, filters, ores

local function resolve()
	items, filters = {}, {}
	for _, name in ipairs(ITEM_NAMES) do
		if prototypes.item[name] then
			items[#items + 1] = name
			filters[#filters + 1] = { name = name } -- no quality: matches every quality
		end
	end
	local found = {}
	for _, name in ipairs(ORE_NAMES) do
		local entity = prototypes.entity[name]
		if entity and entity.type == "resource" then found[#found + 1] = name end
	end
	ores = #found > 0 and found or nil
end

local function carries(inventory, filter)
	return inventory ~= nil and inventory.get_item_count_filtered(filter) > 0
end

local function count_sources(player, character)
	local main = character.get_inventory(MAIN)
	local trash = character.get_inventory(TRASH)
	local cursor = player.cursor_stack
	local held = cursor and cursor.valid_for_read and cursor.name or nil
	local sources = 0
	for index = 1, #items do
		local filter = filters[index]
		if held == items[index] or carries(main, filter) or carries(trash, filter) then
			sources = sources + 1
		end
	end
	if ores then
		local position = character.position
		local x, y = position.x, position.y
		if character.surface.count_entities_filtered({
			area = { { x - ORE_RADIUS, y - ORE_RADIUS }, { x + ORE_RADIUS, y + ORE_RADIUS } },
			name = ores,
			limit = 1,
		}) > 0 then
			sources = sources + 1
		end
	end
	return sources
end

local function irradiate()
	if not items then resolve() end
	if #items == 0 and not ores then return end
	for _, player in pairs(game.connected_players) do
		local character = player.character
		if character and character.valid then
			for _ = 1, count_sources(player, character) do
				character.damage(DAMAGE, DAMAGE_FORCE, DAMAGE_TYPE)
				if not character.valid then break end
			end
		end
	end
end

script.on_nth_tick(INTERVAL, irradiate)
