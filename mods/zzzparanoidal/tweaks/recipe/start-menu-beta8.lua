-- User Beta 8 normal start menu, after Angels OV.execute and all late patches.
-- Only selected starting recipes move; do not move entire shared late-game subgroups.
-- Current icons/names, machine properties and the agreed pump recipe are preserved.
if not data.raw["item-group"].circuit then
	data:extend({ {
		type = "item-group", name = "circuit", order = "ab",
		icon = "__base__/graphics/technology/circuit-network.png", icon_size = 256,
	} })
end
if data.raw["item-group"].combat then data.raw["item-group"].combat.order = "d" end

local items = {}
for _, prototypes in pairs(data.raw) do
	for name, prototype in pairs(prototypes) do
		if prototype.stack_size then items[name] = prototype end
	end
end

local function move_row(subgroup_name, group, order, recipes)
	if not data.raw["item-group"][group] then return end
	local subgroup = data.raw["item-subgroup"][subgroup_name]
	if not subgroup or subgroup.group ~= group or subgroup.order ~= order then
		subgroup_name = "paranoidal-beta8-start-" .. subgroup_name
		if not data.raw["item-subgroup"][subgroup_name] then
			data:extend({ { type = "item-subgroup", name = subgroup_name, group = group, order = order } })
		end
	end
	for name, recipe_order in pairs(recipes) do
		local recipe = data.raw.recipe[name]
		if recipe then
			recipe.subgroup = subgroup_name
			recipe.order = recipe_order
			local product = recipe.main_product
			if not product and recipe.results and #recipe.results == 1 then
				local result = recipe.results[1]
				if result.type == "item" then product = result.name end
			end
			if product and items[product] then
				-- Alternate recipes can share a product but have different recipe orders.
				-- Preserve the item's own order instead of letting pairs() choose one.
				items[product].subgroup = subgroup_name
			end
		end
	end
end

move_row("storage", "logistics", "a", {
	["wooden-chest"] = "a[items]-a[wooden-chest]", ["iron-chest"] = "a[items]-b[iron-chest]",
})
move_row("wooden-pole", "logistics", "d-1", { ["small-electric-pole"] = "a[energy]-a[small-electric-pole]" })
move_row("bob-logistic-tier-0", "bob-logistics", "b-0", { ["bob-basic-transport-belt"] = "a[transport-belt]-1[basic-transport-belt]" })
move_row("pipe", "bob-logistics", "d-a-1", { ["bi-wood-pipe"] = "a" })
move_row("pipe-to-ground", "bob-logistics", "d-a-2", { ["bi-wood-pipe-to-ground"] = "a" })
move_row("circuit-visual", "circuit", "e", { ["deadlock-copper-lamp"] = "a[light]-a[aardvark-lamp]" })
move_row("energy", "production", "b", {
	["texugo-wind-turbine"] = "b[steam-power]-c[texugo-wind-turbine]", ["torch"] = "c-a",
})
move_row("extraction-machine", "production", "c", {
	["burner-mining-drill"] = "a[items]-a[burner-mining-drill]", ["offshore-mk0-pump"] = "b[fluids]-c[offshore-mk0-pump]",
})
move_row("smelting-machine", "production", "d", { ["stone-furnace"] = "a[stone-furnace]" })
move_row("production-machine", "production", "e", { ["burner-lab"] = "g[lab]" })
move_row("intermediate-product", "intermediate-products", "g", {
	["iron-gear-wheel"] = "c[iron-gear-wheel]", ["motor"] = "g[engine-unit]-a[motor]",
	["electric-motor"] = "g[engine-unit]-b[electric-motor]",
	["engine-unit"] = "g[engine-unit]-c[engine-unit]",
	["electric-engine-unit"] = "g[engine-unit]-d[electric-engine-unit]",
})
-- Keep automation science in the shared science-pack row, before logistic science.
-- sci-component-1 and mining-drill-bit-mk0 already have their Beta 8 rows/orders.
move_row("gun", "combat", "a", { ["pistol"] = "a[basic-clips]-a[pistol]" })
move_row("ammo", "combat", "b", {
	["firearm-magazine"] = "a[basic-clips]-a[firearm-magazine]",
	["copper-nickel-firearm-magazine"] = "a[basic-clips]-a[firearm-magazine]",
	["pistol-rearm-ammo"] = "a[basic-clips]-a[firearm-magazine]",
})
move_row("defensive-structure", "combat", "g", { ["bi-wooden-fence"] = "a-a[stone-wall]-a[wooden-fence]" })
move_row("armor", "equipment", "a", { ["respirator"] = "f[hazard]" })
move_row("angels-processing-crafting", "angels-resource-refining", "a[init]-a[crafting]", {
	["angels-ore1-crushed-hand"] = "a[angelsore1-crushed-hand]",
	["angels-ore3-crushed-hand"] = "b[angelsore3-crushed-hand]",
	["angels-stone-from-crushed-stone"] = "d[stone-crushed]",
})
move_row("angels-ore-processing-a", "angels-resource-refining", "b[processing]-a", {
	["angels-ore1-crushed"] = "a[angelsore1-crushed]", ["angels-ore3-crushed"] = "c[angelsore3-crushed]",
	["angels-ore5-crushed"] = "e[angelsore5-crushed]", ["angels-ore6-crushed"] = "f[angelsore6-crushed]",
})
move_row("angels-ore-crusher", "angels-resource-refining", "z[building]-b[crusher]", { ["angels-burner-ore-crusher"] = "a[burner-ore-crusher]" })
move_row("angels-stone", "angels-smelting", "na", { ["stone-brick"] = "f[stone-brick]" })
move_row("angels-copper-casting", "angels-casting", "e", {
	["copper-plate"] = "j[angels-plate-copper]-a", ["angels-copper-ore-smelting"] = "j[angels-plate-copper]-b",
	["copper-cable"] = "k[angels-wire-copper]-a",
})
move_row("angels-iron-casting", "angels-casting", "g", {
	["iron-plate"] = "l[angels-plate-iron]-a", ["angels-iron-ore-smelting"] = "l[angels-plate-iron]-b", ["iron-stick"] = "m",
})
move_row("angels-lead-casting", "angels-casting", "h", {
	["angels-ore5-crushed-smelting"] = "k[angels-plate-lead]-a", ["bob-lead-plate"] = "k[angels-plate-lead]-b",
})
move_row("angels-tin-casting", "angels-casting", "nb", {
	["angels-ore6-crushed-smelting"] = "i[angels-plate-tin]-a", ["bob-tin-plate"] = "i[angels-plate-tin]-b",
})
move_row("angels-glass-casting", "angels-casting", "fa", { ["glass-from-ore4"] = "az" })

-- Restore ingredient presentation only; amounts, time and generator properties stay 2.0.
local wind = data.raw.recipe["texugo-wind-turbine"]
if wind and wind.ingredients then
	local rank = { wood = 1, ["small-electric-pole"] = 2, ["copper-cable"] = 3, ["iron-stick"] = 4, ["iron-gear-wheel"] = 5 }
	table.sort(wind.ingredients, function(a, b)
		local an, bn = a.name or a[1], b.name or b[1]
		local ar, br = rank[an] or 100, rank[bn] or 100
		if ar ~= br then return ar < br end
		return an < bn
	end)
end

for _, name in ipairs({ "pistol", "copper-nickel-firearm-magazine", "small-electric-pole" }) do
	local recipe = data.raw.recipe[name]
	if recipe then recipe.enabled = true; recipe.hidden = false end
end
-- Beta 8 used ordinary crafting. LargerLamps' AAI fallback assigns basic-crafting,
-- which the pack's character cannot use; fix this recipe, not all character categories.
local copper_lamp = data.raw.recipe["deadlock-copper-lamp"]
if copper_lamp then copper_lamp.category = "crafting" end

-- Keep the existing electric-lab/lamp unlocks; do not hide their recipes permanently.
for _, name in ipairs({ "big-lab", "deadlock-electric-copper-lamp" }) do
	if data.raw.recipe[name] then data.raw.recipe[name].enabled = false end
end
-- Explicit user decision: no new technology invented for this recipe.
local burner_generator = data.raw.recipe["burner-generator"]
if burner_generator then burner_generator.enabled = false; burner_generator.hidden = true end
-- burner-mining-drill stays behind burner-mechanics. iron-stick is gated in recipies.lua.
-- Do not revert offshore-mk0-pump: 20 bi-wood-pipe are explicitly retained.
