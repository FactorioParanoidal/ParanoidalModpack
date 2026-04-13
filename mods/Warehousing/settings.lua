--[[ Copyright (c) 2017 David-John Miller AKA Anoyomouse
 * Part of the Warehousing mod
 *
 * See License.txt in the project directory for license information.
--]]
data:extend({
	{
		type = "bool-setting",
		name = "Warehousing-icon-scaling",
		setting_type = "startup",
		default_value = true,
		order = 'a-a',
	},
	{
		type = "bool-setting",
		name = "Warehousing-copy-logistic-system",
		setting_type = "startup",
		default_value = false,
		order = 'c-a',
	},
	{
		type = "bool-setting",
		name = "Warehousing-sixteen-mode",
		setting_type = "startup",
		default_value = false,
		order = 'c-b',
	},
})
