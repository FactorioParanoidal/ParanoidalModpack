-- JSON сохраняет предметы силосов до Lua-миграции, которая выдаёт 16 сундуков за штуку.
data:extend({
	{
		type = "item",
		name = "paranoidal-storage-silo-migration",
		localised_name = { "item-name.steel-chest" },
		icon = "__base__/graphics/icons/steel-chest.png",
		icon_size = 64,
		stack_size = 10,
		hidden = true,
		hidden_in_factoriopedia = true,
	},
})
