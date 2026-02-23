require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---
---@class KuxCoreLib.LocalizationUtils : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.LocalizationUtils
local LocalizationUtils = {
	__class  = "KuxCoreLib.LocalizationUtils",
	__guid   = "{d74e3752-c3ad-4e7d-b5c0-5239b6222b07}",
	__origin = "Kux-CoreLib/lib/LocalizationUtils.lua",
}
if not KuxCoreLib.__classUtils.ctor(LocalizationUtils) then return self end
-----------------------------------------------------------------------------------------------------------------------
local TranslationService = KuxCoreLib.require.TranslationService

---Maps the localisation string to keys. after mapping the 'loc' table contains the key for a `LocalisedString`
---@param loc {[string]: string|{[string]:string}} The localization data
---@param view_name string? The name of the view
---@param mod_name string? The name of the mod (default: current mod)
---Resulting key format: <pre>&lt;mod_name&gt;-&lt;view_name&gt;.&lt;key&gt;<br>&lt;mod_name&gt;.&lt;key&gt;</pre>
---<p>CALLED_BY: loc definition file</p>
function LocalizationUtils.map_keys(loc, view_name, mod_name)
	view_name = (view_name and #view_name>0) and ("-"..view_name) or ""
	mod_name = mod_name or script.mod_name
	for k1, v1 in pairs(loc) do
		if type(v1) == "string" then
			loc[k1] = mod_name..view_name.."."..k1
		elseif type(v1) == "table" then
			for k2, v2 in pairs(v1) do
				v1[k2] = mod_name..view_name.."-"..k1:gsub("^[^%w]+", "").."."..k2
			end
		else
			error("invalid value")
		end
	end
end

---@param player LuaPlayer
---@param loc {[string]: string|{[string]:string}} The localization data
---<p>CALLED_BY: control.on_loaded</p>
function LocalizationUtils.request_translation(player, loc)
	for k1, v1 in pairs(loc) do
		if type(v1) == "string" then
			TranslationService.request(player, v1)
		elseif type(v1) == "table" then
			for k2, v2 in pairs(v1) do
				TranslationService.request(player, v2)
			end
		else
			error("invalid value")
		end
	end
end


---Gets the localised name key of an object.
---@param obj nil|ElemID|Ingredient|Product|LuaItem|LuaFluidPrototype|LuaEntity|LuaRecipe|LuaEquipment|LuaEquipmentGrid|LuaEquipmentPrototype|LuaEntityPrototype|LuaFluidPrototype|LuaItemPrototype|LuaRecipePrototype|string
---@param expected_type string? -- Can also contain multiple types separated by "|"
---@return LocalisedString
function LocalizationUtils.localised_name(obj, expected_type)
	if not obj then return end

	-- Falls das Objekt eine eigene `localised_name` hat, direkt zurückgeben
	if obj.localised_name then
		local localised_name = obj.localised_name
		if _G.type(localised_name) == "table" --[[@cast localised_name table]] and _G.type(localised_name[1]) == "table" then
			_G.table.insert(localised_name, 1, "")
		end
		return localised_name
	end

	-- Prototyp abrufen (verwendet `getPrototypeAndType`, um doppelte Logik zu vermeiden)
	local prototype, base_type = getPrototypeAndCategory(obj, expected_type)
	if not prototype then return end

	-- Localized Name zurückgeben (falls vorhanden)
	if prototype.localised_name then
		return prototype.localised_name
	end

	-- Standard-Localized-Name aus Basis-Typ und Namen generieren
	return base_type .. "-name." .. prototype.name -- z. B. "item-name.iron-plate"
end



--[[ Usage:
	LocalizationUtils.extend(loc)

	loc("word_wrap_checkbox", {
		caption = "Word wrap",
		tooltip = "Enable/disable wrap"
	})
]]

function LocalizationUtils.extend(loc)
	local self = loc or {}
	return setmetatable(self, {
		__call = function(tbl, name, props)
			for k, v in pairs(props) do
				local group = "."..k
				tbl[group] = tbl[group] or {}
				tbl[group][name] = v
			end
		end
	})
end


-----------------------------------------------------------------------------------------------------------------------
return LocalizationUtils

--[[
local loc = {
	num_results = "__1__ results",
	search_prompt = "Search...",
	nothing_found = "Nothing found",
	search_instructions = "Search for items, fluids, entities, etc.",
	show_disabled = "D",
	show_hidden = "H",
	localised_search_unavailable = "Localised search unavailable",

	caption = {
		show_disabled ="D",
		show_hidden = "H"
	}
	tooltip = {
		control_hint = "",
		show_disabled = "Show disabled item/recipes",
		show_hidden = "Show hidden item/recipes",
	}
}

LocalizationUtils.map_keys(loc,"ViewName")
TranslationService.add_gui_localization(loc)
return loc

]]