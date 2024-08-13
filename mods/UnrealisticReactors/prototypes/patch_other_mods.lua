local Setting = require "scripts.setting"


--[[do local recipe = data.raw.recipe["mixed-oxide"]
 if recipe and recipe.icon == "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-mixed-oxide.png" then
	data:extend({{
		type = "item",
		name = "rr-clowns-mox-cell",
		icon = "__UnrealisticReactors__/graphics/icons/mox_fuel_cell.png",
		icon_size = 32,
		--flags = {"goes-to-main-inventory"},
		subgroup = "intermediate-product",
		order = "r[uranium-processing]-a[uranium-fuel-cell]",
		fuel_category = "nuclear",
		burnt_result = "used-up-uranium-fuel-cell",
		fuel_value = "7GJ",
		stack_size = 50
	}})
	recipe.icon = "__UnrealisticReactors__/graphics/icons/clowns_mox_recipe.png"
	recipe.results[1].name="rr-clowns-mox-cell"
end end
]]
do
    local recipe = data.raw.recipe["MOX-fuel-reprocessing"]
    if recipe
        and recipe.results
        and recipe.results[2]
        and recipe.results[2].amount > 3 then
        recipe.results[2].amount = 3
    end
end



do
    local energy_items = mods["base"] and {
        "heat-pipe",
        "heat-exchanger",
        "steam-turbine",
        "nuclear-reactor",
    } or {}
    if mods["PlutoniumEnergy"] then table.insert(energy_items, "MOX-reactor") end

    for _, name in ipairs(energy_items) do
        data.raw.item[name].subgroup = "realistic-reactors-energy"
    end
end



if mods["base"] and Setting.startup("disable-vanilla-reactor") then
    data.raw.recipe["nuclear-reactor"].hidden = true
    data.raw.reactor["nuclear-reactor"].minable = { mining_time = 1.5, result = "realistic-reactor" }
    local effects = data.raw.technology["nuclear-power"].effects
    for i, effect in ipairs(effects) do
        if effect.recipe == "nuclear-reactor" and effect.type == "unlock-recipe" then
            table.remove(effects, i)
            break
        end
    end
end
