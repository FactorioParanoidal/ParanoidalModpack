local LocalizationUtils = KuxCoreLib.require.LocalizationUtils
local TranslationService = KuxCoreLib.require.TranslationService

---@class KuxGuiLib.ElementSelectorView.localization ---@type {[string]:string|table}
local loc = {
	num_results = "__1__ results",
	search_prompt = "Search...",
	nothing_found = "Nothing found",
	search_instructions = "Search for items, fluids, entities, etc.",
	show_disabled = "D",
	show_hidden = "H",
	localised_search_unavailable = "Localised search unavailable",

	tooltip = {
		control_hint = "",
		show_disabled = "Show disabled item/recipes",
		show_hidden = "Show hidden item/recipes",
	}
}
LocalizationUtils.map_keys(loc, "ElementSelectorView", "Kux-GuiLib")
TranslationService.add_gui_localization(loc)
return loc