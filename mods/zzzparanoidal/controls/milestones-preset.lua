-- Пресет Milestones для Paranoidal: главные вехи прохождения (Angel's + Bob's + Bio + SpaceMod).
-- Milestones выбирает пресет с наибольшим числом required_mods, поэтому этот пресет заменяет
-- «Vanilla» в новой игре; в старой игре его подключает патч Milestones, если набор вех не меняли.
-- Аддоны других модов (bobenemies, bobmodules, Bio Industries, SpaceX) добавляются поверх.
-- Нагрузка: вехи-технологии проверяются только по событию исследования; предметы, жидкости
-- и убийства читаются раз в цикл одним словарём статистики на поверхность (патч Milestones 9.4.8).
-- Названия групп совпадают с группами аддонов, чтобы их вехи попадали в те же разделы.

local M = {}

local function item(name, quantity, next_formula, hidden)
	return { type = "item", name = name, quantity = quantity or 1, next = next_formula, hidden = hidden }
end

local function fluid(name, quantity)
	return { type = "fluid", name = name, quantity = quantity or 1 }
end

local function tech(name)
	return { type = "technology", name = name, quantity = 1 }
end

local function group(name)
	return { type = "group", name = name }
end

local MILESTONES = {
	group("Science"),
	item("automation-science-pack"),
	item("logistic-science-pack"),
	item("military-science-pack"),
	item("chemical-science-pack"),
	item("bob-advanced-logistic-science-pack"),
	item("production-science-pack"),
	item("utility-science-pack"),
	item("bob-science-pack-gold"),
	item("bob-alien-science-pack"),
	item("space-science-pack"),
	item("automation-science-pack", 1000, "x10"),
	item("logistic-science-pack", 1000, "x10"),
	item("military-science-pack", 1000, "x10", true),
	item("chemical-science-pack", 1000, "x10"),
	item("bob-advanced-logistic-science-pack", 1000, "x10", true),
	item("production-science-pack", 1000, "x10"),
	item("utility-science-pack", 1000, "x10"),
	item("bob-science-pack-gold", 1000, "x10", true),
	item("bob-alien-science-pack", 1000, "x10", true),
	item("space-science-pack", 1000, "x10"),

	-- Ключевые исследования: проверяются только в on_research_finished.
	group("Progress"),
	tech("burner-mechanics"),
	tech("steam-power"),
	tech("automation"),
	tech("electronics"),
	tech("electric-mining-drill"),
	tech("steel-processing"),
	tech("angels-ore-crushing"),
	tech("angels-water-treatment"),
	tech("angels-ore-floatation"),
	tech("angels-oil-processing"),
	tech("angels-gas-processing"),
	tech("plastics"),
	tech("angels-ore-leaching"),
	tech("angels-ore-refining"),
	tech("railway"),
	tech("construction-robotics"),
	tech("logistic-robotics"),
	tech("logistic-system"),
	tech("nuclear-power"),
	tech("angels-thorium-power"),
	tech("angels-fusion-power-1"),
	tech("rocket-silo"),
	{ type = "item", name = "rocket-part", quantity = 100, allow_hidden = true },

	group("Ore processing"),
	item("angels-ore-crusher"),
	item("angels-washing-plant"),
	item("angels-hydro-plant"),
	item("angels-ore-floatation-cell"),
	item("angels-electrolyser"),
	item("angels-ore-leaching-plant"),
	item("angels-ore-refinery"),
	item("angels-blast-furnace"),
	item("angels-induction-furnace"),
	item("angels-casting-machine"),
	item("angels-strand-casting-machine"),
	item("angels-chemical-furnace"),

	group("Resources"),
	item("iron-plate", 1000, "x10"),
	item("copper-plate", 1000, "x10"),
	item("steel-plate"),
	item("steel-plate", 1000, "x10"),
	item("bob-tin-plate"),
	item("bob-lead-plate"),
	item("bob-glass"),
	item("angels-mono-silicon"),
	item("bob-nickel-plate"),
	item("bob-zinc-plate"),
	item("bob-aluminium-plate"),
	item("bob-cobalt-plate"),
	item("bob-silver-plate"),
	item("bob-gold-plate"),
	item("bob-titanium-plate"),
	item("tungsten-plate"),
	item("angels-plate-platinum"),
	item("bob-bronze-alloy"),
	item("bob-brass-alloy"),
	item("bob-invar-alloy"),
	item("bob-gunmetal-alloy"),
	item("bob-cobalt-steel-alloy"),
	item("bob-nitinol-alloy"),
	item("bob-copper-tungsten-alloy"),
	item("tungsten-carbide"),
	item("plastic-bar"),
	item("plastic-bar", 1000, "x10"),
	item("bob-rubber"),
	item("resin"),
	item("bob-basic-circuit-board"),
	item("electronic-circuit"),
	item("electronic-circuit", 1000, "x10", true),
	item("advanced-circuit"),
	item("advanced-circuit", 1000, "x10", true),
	item("processing-unit"),
	item("processing-unit", 1000, "x10", true),
	item("bob-advanced-processing-unit"),
	item("bob-advanced-processing-unit", 100, "x10", true),

	group("Chemistry"),
	fluid("angels-water-purified"),
	fluid("angels-gas-hydrogen"),
	fluid("angels-gas-oxygen"),
	fluid("angels-gas-nitrogen"),
	fluid("angels-gas-chlorine"),
	fluid("crude-oil"),
	fluid("angels-gas-natural-1"),
	fluid("angels-gas-methane"),
	fluid("angels-liquid-naphtha"),
	fluid("sulfuric-acid"),
	fluid("lubricant"),

	group("Power"),
	item("steam-engine"),
	item("texugo-wind-turbine"),
	item("solar-panel"),
	item("accumulator"),
	item("steam-turbine"),
	item("nuclear-reactor"),
	item("uranium-fuel-cell"),
	item("angels-thorium-fuel-cell"),
	item("angels-deuterium-fuel-cell"),

	group("Logistics"),
	item("locomotive"),
	item("construction-robot"),
	item("logistic-robot"),
	item("roboport"),
	item("beacon"),
	item("spidertron"),

	group("Military"),
	item("gun-turret"),
	item("laser-turret"),
	item("tank"),
	item("power-armor"),
	item("power-armor-mk2"),
	item("bob-power-armor-mk5"),
	item("artillery-turret"),
	item("atomic-bomb"),
}

-- Вехи, чьих прототипов нет в текущей сборке (например, другие startup-настройки), отбрасываются
-- здесь, чтобы Milestones не писал о них в чат. Пустые группы тоже не попадают в пресет.
local PROTOTYPE_TABLES = {
	item = "item",
	fluid = "fluid",
	technology = "technology",
}

local function is_available(milestone)
	local kind = PROTOTYPE_TABLES[milestone.type]
	if not kind then return true end
	local prototype = prototypes[kind][milestone.name]
	-- rocket-part скрыт, но учитывается статистикой производства (как в пресете Vanilla).
	return prototype ~= nil and (milestone.allow_hidden or not prototype.hidden)
end

local function build_milestones()
	local result = {}
	local pending_group
	for _, milestone in ipairs(MILESTONES) do
		if milestone.type == "group" then
			pending_group = milestone
		elseif is_available(milestone) then
			if pending_group then
				result[#result + 1] = { type = "group", name = pending_group.name }
				pending_group = nil
			end
			local copy = {}
			for key, value in pairs(milestone) do
				if key ~= "allow_hidden" then copy[key] = value end
			end
			result[#result + 1] = copy
		end
	end
	return result
end

function M.install()
	remote.add_interface("paranoidal_milestones", {
		milestones_presets = function()
			return {
				["Paranoidal"] = {
					-- Больше обязательных модов, чем у любого другого пресета: автоопределение выберет этот.
					required_mods = {
						"zzzparanoidal",
						"angelsrefining",
						"angelssmelting",
						"angelspetrochem",
						"bobplates",
						"bobelectronics",
						"bobwarfare",
						"Bio_Industries_2",
					},
					milestones = build_milestones(),
				},
			}
		end,
	})
end

M.MILESTONES = MILESTONES -- для офлайн-проверки имён

return M
