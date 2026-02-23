require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides translation functions
---@class KuxCoreLib.TranslationService : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.TranslationService
local TranslationService = {
	__class  = "KuxCoreLib.TranslationService",
	__guid   = "{e0c523bd-4c87-4eb9-8c30-a4761f3c3a32}",
	__origin = "Kux-CoreLib/lib/TranslationService.lua",
}
if not KuxCoreLib.__classUtils.ctor(TranslationService) then return self end
-----------------------------------------------------------------------------------------------------------------------
local Events = KuxCoreLib.require.Events
local LocalizationUtils = KuxCoreLib.require.LocalizationUtils

---@class KuxCoreLib.TranslationService.handler
local handler = {
	__class  = "KuxCoreLib.TranslationService.handler",
}

---queued loc registrations
local gui_localizations = {}

---@class KuxCoreLib.TranslationService.registry
local registry = {
	num_queued = 0,
	num_requests = 0,
	queue={}, ---@type {[string]: {[string]: {localised_string:LocalisedString, player_index:number}}} -- locale -> {hash -> {localised_string, player_index}
	requests={}, -- locale -> {id -> hash}
	translated={}, -- locale -> {hash -> LocalisedString}
	idx_hash_localised_string={} -- {hash -> LocalisedString}
}

---Gets a stable string as hash
---@param localizable_string LocalisedString
---@return string
---<p>We use a string as hash because table reference as key is not safe.</p>
local function getHash(localizable_string)
	--return type(localizable_string)=="table" and helpers.table_to_json(localizable_string) or tostring(localizable_string)
	if type(localizable_string) ~= "table" then  error("invalid key. table expected") end
	if #localizable_string == 1 then
		local first = localizable_string[1]
		if type(first) ~= "string" then error("invalid key, string expected at #1") end
		return first
	end
	return helpers.table_to_json(localizable_string)
end

---@param localizable_string LocalisedString
---@param locale string
---@return string
function TranslationService.loc(localizable_string, locale)
	if type(localizable_string) == "string" then localizable_string = {localizable_string} end -- <FEATURE
	if type(localizable_string) ~= "table" then return tostring(localizable_string) end -- no translate
	local hash = getHash(localizable_string)
	local loc = registry.translated[locale]
	if loc[hash] then return loc[hash] end
	return hash
end

---@param localizable_string LocalisedString
---@param locale string
---@return boolean
function TranslationService.hasTranslation(localizable_string, locale)
	if type(localizable_string) == "string" then localizable_string = {localizable_string} end -- <FEATURE
	if type(localizable_string) ~= "table" then return false end
	return (registry.translated[locale] or {})[getHash(localizable_string)]~=nil
end

local supertype = {
	item = "item",
	capsule = "item",
	gun = "item",
	armor = "item",
	mining_tool = "item",
	repair_tool = "item",
	rail_planner = "item",
	tool = "item",
	ammo = "item",
	module = "item",
	item_with_entity_data = "item",
	item_with_inventory = "item",
	item_with_label = "item",
	item_with_tags = "item",
	item_with_rocket_launcher = "item",
	fluid = "fluid",
	recipe = "recipe",
	technology = "technology",
	tile = "tile",
	virtual_signal = "virtual-signal",
	equipment = "equipment",
	shortcut = "shortcut"
}

---Gets the localisable string for the given prototype and field. (gets not the translation!)
---@param pt LuaPrototypeBase
---@param field "localised_name"|"localised_description"|"localised_tooltip"
---@return LocalisedString
function TranslationService.getLocalizableString(pt, field)
	local dic = {["localised_name"]="name",["localised_description"]="description",["localised_tooltip"]="tooltip"}
	return pt[field] or (supertype[pt.type].."-"..dic[field].."."..pt[dic[field]])
end

---@return string[]?
local function extract_keys(lstr)
	local keys = {}
	if type(lstr) == "string" then return end -- Nur einzelner Text, kein Key – ignorieren
	if type(lstr[1]) == "string" and lstr[1] ~= "" then
		keys[#keys+1]=lstr[1]
	end
	for i = 2, #lstr do
		for _,k in ipairs(extract_keys(lstr[i]) or {}) do keys[#keys+1]=k end
	end
end

local function fill_placeholders(text, placeholders)
	for i, v in ipairs(placeholders) do
		text = text:gsub("__"..i.."__", v)
	end
	return text
end


function request_core(locale, localizable_string, hash)
	local loc = registry.translated[locale]
	if loc[hash] then return end -- already translated

	registry.queue[locale] = registry.queue[locale] or {}
	if registry.queue[locale][hash] then return end -- already queued

	registry.requests[locale] = registry.requests[locale] or {}
	if registry.requests[locale][hash] then return end -- still requesting

	registry.queue[locale][hash] = {localised_string = localizable_string}
	registry.num_queued = registry.num_queued + 1
end

---@param player LuaPlayer
---@param localizable_string LocalisedString
function TranslationService.request(player, localizable_string)
	if localizable_string == nil then return end
	if type(localizable_string) == "string" then localizable_string = {localizable_string} end -- <FEATURE
	if type(localizable_string) ~= "table" then return end
	if not player.valid then return end
	if not player.connected then return end
	local locale = player.locale
	local hash = getHash(localizable_string)
	registry.translated[locale] = registry.translated[locale] or {}
	registry.idx_hash_localised_string[hash]=localizable_string -- stores all requested strings

	request_core(locale, localizable_string, hash)
end


---
---@param loc table
---<p>CALLED-BY: loc file
function TranslationService.add_gui_localization(loc)
	table.insert(gui_localizations, loc)
end


---
---@param player LuaPlayer
---<p>CALLED-BY: control.on_loaded</p>
function TranslationService.request_gui_localization(player)
	for _, loc in pairs(gui_localizations) do
		LocalizationUtils.request_translation(player, loc)
	end
end


---
---@return boolean
function TranslationService.is_idle()
	return registry.num_queued == 0 and registry.num_requests == 0
end

---@param localised_string LocalisedString
function request_internal(player_index, hash, localised_string)
	if localised_string == nil then return end
	local player = game.players[player_index]
	if not player or not player.valid or not player.connected then return end
	local locale = player.locale
	local id = player.request_translation(localised_string)
	if not id then return end -- request failed
--	print("TranslationService request :"..locale.." "..str(hash))
	registry.requests[locale][id] = hash
	registry.requests[locale][hash] = id
	registry.queue[locale][hash] = nil
	registry.num_requests = registry.num_requests + 1
	registry.num_queued = registry.num_queued - 1
end

---@param e EventData.on_string_translated
function handler.on_string_translated(e)
	local _ = "fnc{49483a93-e3fc-442e-a632-5630ebfc6c11}"
	local player = game.players[e.player_index]
	local locale = player.locale
	if not registry.requests[locale] then return end --requested by other mod
	local hash = registry.requests[locale][e.id]
	if not hash then return end  --requested by other mod
	--clean request
	registry.requests[locale][e.id] = nil
	registry.requests[locale][hash] = nil
	--save result
	registry.translated[locale][hash] = e.result
	registry.num_requests = registry.num_requests - 1
	--print("TranslationService result :"..locale.." "..str(hash).." "..str(e.result))
end

---
---@param locale string
---@return LuaPlayer?
local function findPlayer(locale)
	for _, player in pairs(game.players) do
		if not player.valid or not player.connected then goto next end
		if player.locale == locale then return player end
		::next::
	end
end

function handler.on_nth_tick_1(e)
	local _ = "fnc{cc5f09b5-19a9-45ae-a63e-7bcf896113fc}"
	if registry.num_queued == 0 then return end
	local count = 1000
	local orphaned = {}
	for locale, list in pairs(registry.queue) do
		local player = findPlayer(locale)
		if not player then
			orphaned[locale]=true
			goto next_locale
		end
		for hash, data in pairs(list) do
			request_internal(player.index, hash, data.localised_string)
			count = count - 1
			if count == 0 then return end
		end
		::next_locale::
	end
	for locale, _ in pairs(orphaned) do
		local c = 0 for _, _ in pairs(registry.queue[locale]) do c=c+1 end
		registry.num_queued = registry.num_queued - c
		registry.queue[locale]=nil
	end
end

Events.on_event(defines.events.on_string_translated, function (e) handler.on_string_translated(e) end)
Events.on_nth_tick(1, handler.on_nth_tick_1)
Events.on_loaded(function ()
	Events.on_next_tick({},function ()
		local locale = {}
		for _, player in pairs(game.players) do
			if not locale[player.locale] then
				TranslationService.request_gui_localization(player)
			end
		end
	end)
end)

---@param e EventData.on_player_locale_changed
Events.on_event(defines.events.on_player_locale_changed, function(e)
	local player = game.players[e.player_index]
	print (e.tick, "on_player_locale_changed", e.player_index, e.old_locale, player.locale)
	if registry.queue[player.locale] then return end
	for hash, localised_string in ipairs(registry.idx_hash_localised_string) do
		request_core(player.locale,localised_string,hash)
	end
end)

---@param e EventData.on_player_created
Events.on_event(defines.events.on_player_created, function(e)
	print (e.tick, "on_player_created", e.player_index)
end)
-----------------------------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(TranslationService)
return TranslationService


