-- ПР-023: два согласованных исключения для совместимости рецептов Beta 8.
-- После assembler-pipe-passthrough и OV.execute; остальные характеристики остаются 2.0.
for _, name in ipairs({
	"angels-washing-plant", "angels-washing-plant-2", "angels-washing-plant-3", "angels-washing-plant-4",
}) do
	local machine = data.raw["assembling-machine"][name]
	if machine and machine.fluid_boxes then
		local outputs, template = 0, nil
		for _, box in ipairs(machine.fluid_boxes) do
			if box.production_type == "output" then outputs = outputs + 1; template = box end
		end
		if outputs == 1 then
			local outlet = table.deepcopy(template)
			-- Западный центр уже занят проходным выходом 2.0. Не передвигаем его:
			-- отдельный западный выход выше на две клетки, трубы не соединяются между собой.
			outlet.pipe_connections = {
				{ flow_direction = "output", position = { -2, -2 }, direction = defines.direction.west },
			}
			table.insert(machine.fluid_boxes, outlet)
		end
	end
end

local washing = data.raw.recipe["angels-water-heavy-mud"]
if washing and data.raw.fluid["angels-gas-hydrogen-sulfide"] then
	local found = false
	for _, product in ipairs(washing.results or {}) do
		if product.type == "fluid" and product.name == "angels-gas-hydrogen-sulfide" then found = true end
	end
	if not found then
		table.insert(washing.results, { type = "fluid", name = "angels-gas-hydrogen-sulfide", amount = 20 })
	end
end

-- В Beta 8 две жидкости обрабатывал старший химзавод Extended Angels, не обычный ожижитель.
local chemical = data.raw["assembling-machine"]["angels-advanced-chemical-plant-3"]
if chemical and data.raw["recipe-category"]["angels-liquifying"] then
	local found = false
	for _, category in ipairs(chemical.crafting_categories) do
		if category == "angels-liquifying" then found = true end
	end
	if not found then table.insert(chemical.crafting_categories, "angels-liquifying") end
	local waste = data.raw.recipe["bi-mineralized-sulfuric-waste"]
	if waste then
		for _, ingredient in ipairs(waste.ingredients) do
			if ingredient.type == "item" and ingredient.name == "angels-stone-crushed" then ingredient.amount = 70 end
		end
	end
end
