-- Beta 8: только согласованные переносы открытий, после OV и поздних правок.
-- Цены исследований, рецептуры и остальные открытия сохраняются.
local function move_unlock(recipe, from, to)
	local source = data.raw.technology[from]
	local target = data.raw.technology[to]
	if not (data.raw.recipe[recipe] and source and target) then return end

	for index = #(source.effects or {}), 1, -1 do
		local effect = source.effects[index]
		if effect.type == "unlock-recipe" and effect.recipe == recipe then
			table.remove(source.effects, index)
		end
	end
	target.effects = target.effects or {}
	for _, effect in ipairs(target.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == recipe then return end
	end
	table.insert(target.effects, { type = "unlock-recipe", recipe = recipe })
end

move_unlock("angels-bio-resin-wood-reprocessing", "angels-bio-wood-processing-3", "angels-bio-wood-processing")
move_unlock("angels-wood-bricks", "angels-bio-wood-processing", "angels-bio-wood-processing-3")
move_unlock("angels-solid-tetrasodium-pyrophosphate", "phosphorus-processing-2", "phosphorus-processing-1")
move_unlock("clowns-diammonium-phosphate-fertilizer", "angels-bio-farm-2", "phosphorus-processing-1")
