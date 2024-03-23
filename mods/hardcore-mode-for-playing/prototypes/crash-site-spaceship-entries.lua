-- по идее этого набора должно хватить на минимальный старт после падения на корабле.
data.raw.container["crash-site-spaceship"].minable = {
	mining_time = 5,
	results = {
		--трубы деревянные
		{ name = "bi-wood-pipe", amount = 150 },
		{ name = "bi-wood-pipe-to-ground", amount = 20 },
		-- одного насоса с твердотопливным питанием хватит в месте падения
		{ name = "salvaged-offshore-pump-0", amount = 1 },
		-- батарейка корабельная, используется как UPS
		{ name = "salvaged-generator", amount = 1 },
		{ name = "burner-inserter", amount = 20 },
		-- дробление 4 видов руд.
		{ name = "salvaged-assembling-machine", amount = 8 },
		-- плавка 4 видов руд
		{ name = "stone-furnace", amount = 4 },
		-- самые медленные конвейеры в игре
		{ name = "transport-belt", amount = 200 },
		--[[ производственные здания, без них невозможно ничего исследовать или собрать,
			механика мода запрещает стоить любые производящие здания непосредственно на поверхности планеты]]
		{ name = "factory-1", amount = 4 },
		-- автоматизационные исследовательские пакеты - для старта игры
		{ name = "salvaged-automation-science-pack", amount = 171 },
		-- базовый набор топлива, для питания всего этого добра
		{ name = "coal", amount = 1200 },
		-- для исследований начала игры очень даже достаточно, электрических лабораторий у нас для вас нет
		{ name = "salvaged-lab", amount = 1 },
		-- может быть использовано для хранения различных продуктов
		{ name = "wooden-chest", amount = 20 },
		-- для производства дерева, так как никакой добычи с леса быть не может. Ибо это чит.
		--	{ name = "coal-tree-seed", amount = 600 },
		-- пистолет для самообороны от кусак + несколько сотен магазинов(потому что до патронов можно и не дожить)
		{ name = "pistol", amount = 1 },
		{ name = "firearm-magazine", amount = 800 },
	},
}
data.raw.container["crash-site-spaceship-wreck-big-1"].minable = { mining_time = 5 }
data.raw.container["crash-site-spaceship-wreck-big-2"].minable = { mining_time = 5 }
data.raw.container["crash-site-spaceship-wreck-medium-1"].minable = { mining_time = 5 }
data.raw.container["crash-site-spaceship-wreck-medium-2"].minable = { mining_time = 5 }
data.raw.container["crash-site-spaceship-wreck-medium-3"].minable = { mining_time = 5 }
