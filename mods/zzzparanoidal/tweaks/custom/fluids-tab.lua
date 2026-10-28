-- Все видимые и получаемые жидкости — во вкладке «Жидкости» Факториопедии (и выбора сигналов/фильтров),
-- тематическими рядами не длиннее строки сетки (10). Меню крафта не меняется: рецепты, наследующие
-- подгруппу/порядок от жидкости, закрепляются до переноса. Скрытые и неполучаемые жидкости не трогаются.
local M = {}

M.group = "fluids"
M.prefix = "paranoidal-fluids-"

-- Ряд → жидкости в порядке показа.
M.rows = {
	{"water", {"water", "steam", "angels-water-purified", "angels-water-saline", "angels-water-mineralized",
		"angels-thermal-water"}},
	{"waste-water", {"angels-water-yellow-waste", "angels-water-red-waste", "angels-water-green-waste",
		"angels-water-greenyellow-waste", "clowns-water-radioactive-waste"}},
	{"heavy-water", {"angels-liquid-water-semiheavy-1", "angels-liquid-water-semiheavy-2",
		"angels-liquid-water-semiheavy-3", "angels-liquid-water-heavy", "angels-gas-deuterium",
		"angels-liquid-coolant", "angels-liquid-coolant-used"}},
	{"oil", {"crude-oil", "angels-liquid-multi-phase-oil", "angels-liquid-mineral-oil", "angels-liquid-fuel-oil",
		"angels-liquid-naphtha", "lubricant", "bob-liquid-fuel", "diesel-fuel", "angels-gas-synthesis",
		"angels-gas-residual"}},
	{"hydrocarbon-gases", {"angels-gas-natural-1", "angels-gas-raw-1", "angels-liquid-condensates",
		"angels-liquid-ngl", "angels-gas-methane", "angels-gas-ethane", "angels-gas-butane", "angels-gas-propene",
		"angels-gas-ethylene", "gas-acetylene"}},
	{"elemental-gases", {"angels-gas-compressed-air", "angels-gas-hydrogen", "angels-gas-oxygen",
		"angels-gas-nitrogen", "angels-gas-argon", "angels-gas-chlorine", "clowns-gas-fluorine",
		"angels-gas-carbon-monoxide", "angels-gas-carbon-dioxide"}},
	{"acids", {"angels-gas-hydrogen-sulfide", "angels-gas-enriched-hydrogen-sulfide", "angels-gas-acid",
		"angels-gas-sulfur-dioxide", "sulfuric-acid", "angels-gas-hydrogen-chloride",
		"angels-liquid-hydrochloric-acid", "angels-gas-hydrogen-fluoride", "angels-liquid-hydrofluoric-acid",
		"angels-liquid-perchloric-acid"}},
	{"nitrogen", {"angels-gas-nitrogen-monoxide", "angels-gas-nitrogen-dioxide", "gas-nitrous-oxide",
		"angels-liquid-nitric-acid", "angels-gas-ammonia", "angels-gas-ammonium-chloride", "angels-gas-urea",
		"angels-gas-melamine"}},
	{"rocket-chemistry", {"angels-gas-monochloramine", "angels-gas-hydrazine", "angels-gas-methylamine",
		"angels-gas-dimethylamine", "angels-gas-dimethylhydrazine", "angels-gas-dinitrogen-tetroxide",
		"bob-nitroglycerin", "gas-hydrogen-cyanide", "liquid-acrylonitrile", "liquid-acetone-cyanohydrin"}},
	{"organics", {"angels-gas-benzene", "angels-liquid-toluene", "angels-liquid-ethylbenzene",
		"angels-liquid-styrene", "angels-gas-methanol", "angels-gas-formaldehyde", "angels-gas-acetone",
		"angels-liquid-phenol", "angels-liquid-bisphenol-a", "liquid-methyl-methacrylate"}},
	{"chlororganics", {"gas-vinyl-acetylene", "angels-gas-butadiene", "liquid-dichlorobutene",
		"liquid-chlorobutadiene", "angels-gas-chlor-methane", "gas-chloroethane", "gas-vinyl-chloride",
		"gas-phosgene", "angels-gas-allylchlorid", "angels-gas-epichlorohydrin"}},
	{"polymers", {"angels-liquid-polyethylene", "angels-liquid-plastic", "angels-liquid-glycerol",
		"angels-liquid-resin", "liquid-lactic-acid", "liquid-rubber-pre", "liquid-rubber-masterbatch",
		"angels-liquid-rubber"}},
	{"sludges", {"angels-water-thin-mud", "angels-water-light-mud", "angels-water-concentrated-mud",
		"angels-water-heavy-mud", "angels-water-viscous-mud", "angels-mineral-sludge", "angels-slag-slurry",
		"angels-crystal-seedling", "angels-crystal-slurry"}},
	{"ore-solutions", {"angels-ore8-sludge", "angels-ore8-solution", "angels-ore8-anode-sludge",
		"angels-ore8-slime", "angels-ore9-sludge", "angels-ore9-solution", "angels-ore9-anode-sludge",
		"angels-ore9-slime"}},
	{"metal-compounds", {"angels-liquid-chlorauric-acid", "angels-liquid-hexachloroplatinic-acid",
		"angels-liquid-titanium-tetrachloride", "angels-liquid-tungstic-acid", "angels-gas-tungsten-hexafluoride",
		"angels-gas-tungsten-hexachloride", "clowns-liquid-thorium-solution", "clowns-liquid-mercury",
		"clowns-liquid-dimethylmercury", "fluid-tetraethyllead"}},
	{"inorganic-solutions", {"angels-liquid-trichlorosilane", "angels-gas-silane",
		"angels-liquid-hexafluorosilicic-acid", "clowns-liquid-phosphoric-acid",
		"angels-liquid-aqueous-sodium-hydroxide", "angels-liquid-ferric-chloride-solution",
		"angels-liquid-cupric-chloride-solution"}},
	{"molten-metals", {"angels-liquid-molten-iron", "angels-liquid-molten-copper", "angels-liquid-molten-tin",
		"angels-liquid-molten-lead", "angels-liquid-molten-zinc", "angels-liquid-molten-nickel",
		"angels-liquid-molten-aluminium", "angels-liquid-molten-silicon"}},
	{"molten-rare-metals", {"angels-liquid-molten-titanium", "angels-liquid-molten-chrome",
		"angels-liquid-molten-manganese", "angels-liquid-molten-cobalt", "clowns-liquid-molten-magnesium",
		"angels-liquid-molten-silver", "angels-liquid-molten-gold", "angels-liquid-molten-platinum"}},
	{"molten-alloys", {"angels-liquid-molten-steel", "angels-liquid-molten-solder", "angels-liquid-molten-bronze",
		"angels-liquid-molten-brass", "angels-liquid-molten-gunmetal", "angels-liquid-molten-invar",
		"angels-liquid-molten-cobalt-steel", "angels-liquid-molten-nitinol", "angels-liquid-molten-glass",
		"angels-liquid-concrete"}},
	{"bio-liquors", {"angels-liquid-pulping-liquor", "angels-liquid-brown-liquor", "angels-liquid-white-liquor",
		"angels-liquid-black-liquor", "angels-liquid-green-liquor"}},
	{"bio-vegetable", {"angels-liquid-nutrient-pulp", "angels-liquid-raw-vegetable-oil",
		"angels-liquid-vegetable-oil", "angels-liquid-fermentation-raw", "angels-gas-ethanol",
		"angels-liquid-acetic-acid", "angels-liquid-acetic-anhydride", "angels-liquid-propionic-acid",
		"angels-liquid-cellulose-acetate-mixture", "angels-liquid-cellulose-acetate"}},
	{"bio-fish", {"angels-liquid-fish-atmosphere", "angels-liquid-polluted-fish-atmosphere",
		"angels-liquid-raw-fish-oil", "angels-liquid-fish-oil", "angels-gas-puffer-atmosphere", "bi-biomass"}},
	{"alien", {"angels-alien-spores", "angels-alien-goo", "bob-alien-acid", "bob-alien-explosive",
		"bob-alien-poison", "bob-alien-fire"}},
	{"yuoki", {"y-mechanical-force", "y-con_water", "y_hydrogen", "y_syngas_raw", "y_emulsion", "y_richemulsion",
		"y-liquid-uc2", "ye_blood", "ye_slurry", "ye_cornoil"}},
}
-- Видимые получаемые жидкости вне списка (новые моды): в конец вкладки, со своим order.
M.other_row = "other"

local function shown(proto)
	return proto and not proto.hidden and not proto.hidden_in_factoriopedia and not proto.parameter
		and not proto.factoriopedia_alternative
end

-- Жидкость считается рабочей, если её даёт доступный рецепт, месторождение, тайл (насос) или фильтр
-- выходной трубы котла/насоса.
function M.sources(raw)
	local unlocked = {}
	for _, tech in pairs(raw.technology or {}) do
		if not tech.hidden then
			for _, effect in pairs(tech.effects or {}) do
				if effect.type == "unlock-recipe" and effect.recipe then unlocked[effect.recipe] = true end
			end
		end
	end
	local src = {}
	for name, recipe in pairs(raw.recipe or {}) do
		if not recipe.hidden and not recipe.parameter and (recipe.enabled ~= false or unlocked[name]) then
			for _, result in pairs(recipe.results or {}) do
				if result.type == "fluid" and result.name then src[result.name] = true end
			end
		end
	end
	for _, resource in pairs(raw.resource or {}) do
		for _, result in pairs(resource.minable and resource.minable.results or {}) do
			if result.type == "fluid" and result.name then src[result.name] = true end
		end
	end
	for _, tile in pairs(raw.tile or {}) do
		if tile.fluid then src[tile.fluid] = true end
	end
	for _, boiler in pairs(raw.boiler or {}) do
		local box = boiler.output_fluid_box
		if not boiler.hidden and box and box.filter then src[box.filter] = true end
	end
	for _, pump in pairs(raw["offshore-pump"] or {}) do
		local box = pump.fluid_box
		if not pump.hidden and box and box.filter then src[box.filter] = true end
	end
	return src
end

function M.apply(raw, emit)
	local fluids = raw.fluid or {}
	local group = raw["item-group"] and raw["item-group"][M.group]
	if not group then
		emit("[fluids-tab] item-group fluids is absent")
		return
	end
	-- Ванильная кнопка вкладки (Bob заменял её иконкой исследования).
	group.icons = nil
	group.icon = "__base__/graphics/item-group/fluids.png"
	group.icon_size = 128

	local source = M.sources(raw)
	local target, listed, missing, skipped, others = {}, {}, {}, {}, {}
	local rows = {}
	for index, row in ipairs(M.rows) do rows[#rows + 1] = {key = row[1], names = row[2], index = index} end
	rows[#rows + 1] = {key = M.other_row, names = {}, index = #rows + 1}

	for _, row in ipairs(rows) do
		for position, name in ipairs(row.names) do
			listed[name] = true
			local fluid = fluids[name]
			if not fluid then
				missing[#missing + 1] = name
			elseif shown(fluid) and source[name] then
				target[name] = {row = row, order = string.format("%02d", position)}
			elseif shown(fluid) then
				skipped[#skipped + 1] = name
			end
		end
	end
	local other = rows[#rows]
	for name, fluid in pairs(fluids) do
		if not listed[name] and shown(fluid) then
			if source[name] then
				others[#others + 1] = name
				target[name] = {row = other, order = ("zz-" .. (fluid.order or "") .. "-" .. name):sub(1, 200)}
			else
				skipped[#skipped + 1] = name
			end
		end
	end

	-- Сначала закрепляем унаследованную подгруппу рецептов (main_product в документации API), потом двигаем
	-- жидкости. Наследование order не описано: order такой жидкости не меняем вовсе.
	local pinned, unpinned, keep_order, blocked = 0, {}, {}, {}
	for _, recipe in pairs(raw.recipe or {}) do
		local results = recipe.results or {}
		local product
		if recipe.main_product and recipe.main_product ~= "" then
			for _, result in ipairs(results) do
				if result.name == recipe.main_product then product = result break end
			end
		elseif recipe.main_product == nil and #results == 1 then
			product = results[1]
		end
		if product and product.type == "fluid" and target[product.name] then
			local fluid = fluids[product.name]
			if recipe.order == nil and not recipe.hidden then keep_order[product.name] = true end
			if recipe.subgroup == nil then
				-- Подгруппу по умолчанию у жидкости не угадываем: такую жидкость не переносим.
				if fluid.subgroup == nil then
					unpinned[#unpinned + 1] = recipe.name
					blocked[product.name] = true
				else
					recipe.subgroup = fluid.subgroup
					pinned = pinned + 1
				end
			end
		end
	end

	local moved, used = 0, {}
	for name, t in pairs(target) do
		if not blocked[name] then
			local fluid = fluids[name]
			fluid.subgroup = M.prefix .. t.row.key
			if not keep_order[name] then fluid.order = t.order end
			used[t.row.key] = t.row
			moved = moved + 1
		end
	end
	-- Подгруппы-ряды: только непустые.
	for key, row in pairs(used) do
		raw["item-subgroup"][M.prefix .. key] = {
			type = "item-subgroup",
			name = M.prefix .. key,
			group = M.group,
			order = string.format("0[paranoidal]-%02d", row.index),
		}
	end

	for i = #others, 1, -1 do
		if blocked[others[i]] then table.remove(others, i) end
	end
	table.sort(missing); table.sort(skipped); table.sort(others); table.sort(unpinned)
	emit(string.format("[fluids-tab] moved=%d pinned-recipes=%d other=%d skipped-no-source=%d absent=%d",
		moved, pinned, #others, #skipped, #missing))
	if #unpinned > 0 then emit("[fluids-tab] not moved, recipes inherit implicit subgroup: " .. table.concat(unpinned, ", ")) end
	if #others > 0 then emit("[fluids-tab] unlisted (row other): " .. table.concat(others, ", ")) end
	if #skipped > 0 then emit("[fluids-tab] visible without source, left in place: " .. table.concat(skipped, ", ")) end
	if #missing > 0 then emit("[fluids-tab] listed but absent: " .. table.concat(missing, ", ")) end
	return {moved = moved, pinned = pinned, others = others, skipped = skipped, missing = missing,
		unpinned = unpinned, target = target}
end

return M
