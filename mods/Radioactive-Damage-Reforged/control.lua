-- Radiation from carried radioactive items (Beta 8 RadioactiveDamage 0.0.4, reworked for 2.0).
-- Every INTERVAL ticks each radioactive item kind the character carries (main inventory, logistic
-- trash, cursor), plus a uranium ore deposit within ORE_RADIUS, deals DAMAGE once. Each source is a
-- separate hit, as in Beta 8, so the flat part of armor resistances applies per source.
-- Only the carrying character is damaged; the Beta 8 area stream also hit nearby buildings,
-- vehicles and players. Items of every quality count.
-- Other mods register radiating entities through the remote interface "radioactive_damage"
-- (set_source): every character within the radius takes the given damage per second, split over
-- the checks. A Geiger counter (per-player setting) clicks once a second for every character that
-- takes radiation, faster for a higher dose; near an area source it also clicks within hear_radius.

local INTERVAL = 10
local DAMAGE = 1
local DAMAGE_TYPE = "uranium-damage"
local DAMAGE_FORCE = "neutral"
local ORE_RADIUS = 10
local ITEM_NAMES = { "uranium-ore", "uranium-235", "uranium-238", "uranium-fuel-cell", "depleted-uranium-fuel-cell" }
local ORE_NAMES = { "uranium-ore" }
local ITEM_DPS = DAMAGE * 60 / INTERVAL -- dose rate of one carried source, for the Geiger counter
local GEIGER_PERIOD = 60 -- one 1 s clip per period
local GEIGER_LEVELS = { { 1, "rdr-geiger-low" }, { 4, "rdr-geiger-mid" }, { math.huge, "rdr-geiger-high" } }
local GEIGER_SETTING = "rdr-geiger-sound"

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

-- Area sources: registration number -> {entity, dps, radius, hear_radius}. Dropped when the
-- entity is gone or set to zero.
local function area_sources()
	return storage.sources
end

local function set_source(entity, dps, radius, hear_radius)
	if not (entity and entity.valid) then return end
	local id = script.register_on_object_destroyed(entity)
	storage.sources = storage.sources or {}
	if not dps or dps <= 0 or not radius or radius <= 0 then
		storage.sources[id] = nil
		return
	end
	storage.sources[id] = { entity = entity, dps = dps, radius = radius, hear_radius = math.max(radius, hear_radius or radius) }
end

remote.add_interface("radioactive_damage", {
	-- entity: LuaEntity; dps: damage per second (0 or nil removes the source); radius: tiles;
	-- hear_radius (optional, >= radius): the Geiger counter clicks there without damage.
	set_source = set_source,
})

-- Dose rate of the area sources at a character (damage per second) and whether one is heard.
local function area_dose(character, sources)
	local dps, heard = 0, false
	local surface, position = character.surface, character.position
	for id, source in pairs(sources) do
		local entity = source.entity
		if not entity.valid then
			sources[id] = nil
		elseif entity.surface == surface then
			local p = entity.position
			local dx, dy = p.x - position.x, p.y - position.y
			local d2 = dx * dx + dy * dy
			if d2 <= source.hear_radius * source.hear_radius then
				heard = true
				if d2 <= source.radius * source.radius then dps = dps + source.dps end
			end
		end
	end
	return dps, heard
end

local function geiger(player, rate)
	local setting = player.mod_settings[GEIGER_SETTING]
	if setting and not setting.value then return end
	for _, level in ipairs(GEIGER_LEVELS) do
		if rate < level[1] then
			player.play_sound({ path = level[2] })
			return
		end
	end
end

local function irradiate(event)
	if not items then resolve() end
	local sources = area_sources()
	if next(sources or {}) == nil then sources = nil end
	if #items == 0 and not ores and not sources then return end
	local click = event.tick % GEIGER_PERIOD == 0
	for _, player in pairs(game.connected_players) do
		local character = player.character
		if character and character.valid then
			local count = (#items > 0 or ores) and count_sources(player, character) or 0
			local dps, heard = 0, false
			if sources then dps, heard = area_dose(character, sources) end
			if click and (count > 0 or heard) then geiger(player, count * ITEM_DPS + dps) end
			for _ = 1, count do
				character.damage(DAMAGE, DAMAGE_FORCE, DAMAGE_TYPE)
				if not character.valid then break end
			end
			if dps > 0 and character.valid then
				character.damage(dps * INTERVAL / 60, DAMAGE_FORCE, DAMAGE_TYPE)
			end
		end
	end
end

script.on_nth_tick(INTERVAL, irradiate)
