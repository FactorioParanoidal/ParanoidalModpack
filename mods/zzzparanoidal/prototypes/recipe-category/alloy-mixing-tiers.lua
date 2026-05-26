-- Tier-categories для alloy-mixer (MK1-MK4). По умолчанию все 4 mixer'а имеют
-- одну категорию molten-alloy-mixing → не отличаются по доступу к рецептам.
-- Эти 3 категории + cumulative crafting_categories в data-final-fixes
-- (tweaks/recipe/angels-smelting-extended-port.lua) делают тиры значимыми.
data:extend({
	{ type = "recipe-category", name = "molten-alloy-mixing-2" },
	{ type = "recipe-category", name = "molten-alloy-mixing-3" },
	{ type = "recipe-category", name = "molten-alloy-mixing-4" },
})
