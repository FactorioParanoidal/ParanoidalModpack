-- osha_mini_containers хардкодит vanilla-рецепты: mini passive-provider/storage крафтятся
-- с advanced-circuit, которого у больших passive-provider-chest/storage-chest нет
-- (большие = steel-chest + electronic-circuit×3). Синхронизируем мини с большими аналогами.
-- active/buffer/requester совпадают с большими, steel-chest оставлен как есть.
-- Плюс: порядок мини в меню синхронизируется с большими (osha перепутал passive/active).
if mods["osha_mini_containers"] then
	for _, name in ipairs({
		"mini-logistic-chest-passive-provider",
		"mini-logistic-chest-storage",
	}) do
		local recipe = data.raw.recipe[name]
		if recipe then
			recipe.ingredients = {
				{ type = "item", name = "mini-steel-chest", amount = 1 },
				{ type = "item", name = "electronic-circuit", amount = 3 },
			}
		end
	end

	-- Порядок в меню: osha перепутал passive/active относительно больших сундуков.
	-- Наследуем order от больших аналогов, чтобы мини шли тем же рядом.
	local order_sync = {
		["mini-steel-chest"] = "steel-chest",
		["mini-logistic-chest-passive-provider"] = "passive-provider-chest",
		["mini-logistic-chest-storage"] = "storage-chest",
		["mini-logistic-chest-active-provider"] = "active-provider-chest",
		["mini-logistic-chest-buffer"] = "buffer-chest",
		["mini-logistic-chest-requester"] = "requester-chest",
	}
	for mini, big in pairs(order_sync) do
		local mini_item, big_item = data.raw.item[mini], data.raw.item[big]
		if mini_item and big_item and big_item.order then
			mini_item.order = "a[storage]-" .. big_item.order .. "[" .. mini .. "]"
		end
	end
end
