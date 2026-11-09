-- Ветка Space Age (ПР-079): рецепты утилизации жидкостей Мараксиса (maraxsis-fluid-void-<жидкость>) копируют
-- иконку жидкости в своём data-updates, до поздних замен иконок сборки (bobicons-beta8 и др.). 37 рецептов
-- остались со старыми иконками, а у жидкой ртути — со ссылкой на отсутствующий файл Hg.png: игра с графикой
-- не загружалась. Пересобираем их из итоговой иконки жидкости: значок «запрет» Мараксиса + слои жидкости.
-- До атласа графики и замен Reskins: они обработают копии так же, как саму жидкость.
if not mods["maraxsis"] then return end

local prefix = "maraxsis-fluid-void-"
local count = 0
for name, recipe in pairs(data.raw.recipe) do
	local fluid = name:sub(1, #prefix) == prefix and data.raw.fluid[name:sub(#prefix + 1)]
	if fluid and (fluid.icons or fluid.icon) then
		local icons = fluid.icons and table.deepcopy(fluid.icons)
			or { { icon = fluid.icon, icon_size = fluid.icon_size or 64 } }
		table.insert(icons, 1, { icon = "__core__/graphics/filter-blacklist.png", icon_size = 101 })
		recipe.icon, recipe.icon_size, recipe.icons = nil, nil, icons
		count = count + 1
	end
end
log("[maraxsis-void-icons] recipes=" .. count)
