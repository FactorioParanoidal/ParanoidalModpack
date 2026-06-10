require("__zzzparanoidal__.paralib")

-- SpaceModFeorasFork под 1.1: ×10 стоимости космо-техов + space/advanced-logistic/military-наука.
if mods["SpaceModFeorasFork"] then
	local techs = {
		"space-assembly", "space-construction", "space-casings", "protection-fields",
		"fusion-reactor", "space-thrusters", "fuel-cells", "habitation", "life-support-systems",
		"spaceship-command", "laser-cannon", "astrometrics", "ftl-theory-A", "ftl-theory-B",
		"ftl-theory-C", "ftl-theory-D1", "ftl-theory-D2", "ftl-propulsion",
		"exploration-satellite", "space-ai-robots", "space-fluid-tanks", "space-cartography",
	}
	local military = {
		["spaceship-command"] = true, ["ftl-theory-D1"] = true,
		["ftl-theory-D2"] = true, ["ftl-propulsion"] = true,
	}
	local function add_pack(unit, pack)
		if not data.raw.tool[pack] then return end
		for _, ing in ipairs(unit.ingredients) do
			if (ing.name or ing[1]) == pack then return end
		end
		table.insert(unit.ingredients, { pack, 1 })
	end
	for _, name in ipairs(techs) do
		local t = data.raw.technology[name]
		if t and t.unit and t.unit.ingredients then
			t.unit.count = math.floor(t.unit.count * 10)
			add_pack(t.unit, "bob-advanced-logistic-science-pack")
			add_pack(t.unit, "space-science-pack")
			if military[name] then
				add_pack(t.unit, "military-science-pack")
			end
		end
	end
end
