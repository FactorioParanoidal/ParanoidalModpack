-- Factorio 2.1 removed the recipe category "basic-crafting" and took it from the vanilla assembling machines.
-- In 2.0 it marked recipes made only in assembling machines, never by hand (Paranoidal: mining drill bits
-- mk1-5). The build keeps it (user decision 2026-11-02): the category exists and the vanilla assembling
-- machines 1-3 craft it again, as in 2.0; the other assemblers list it themselves.
if not data.raw["recipe-category"]["basic-crafting"] then
	data:extend({ { type = "recipe-category", name = "basic-crafting" } })
end
for _, name in ipairs({ "assembling-machine-1", "assembling-machine-2", "assembling-machine-3" }) do
	local machine = data.raw["assembling-machine"][name]
	if machine then
		local present = false
		for _, category in pairs(machine.crafting_categories or {}) do
			if category == "basic-crafting" then present = true end
		end
		if not present then table.insert(machine.crafting_categories, "basic-crafting") end
	end
end
