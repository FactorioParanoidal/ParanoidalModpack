-- JSON сохраняет содержимое сверх размеров новой цистерны/сетки. Потери избытка согласованы при удалении Mobility.
local names = {
	"locomotive", "bob-locomotive-2", "bob-locomotive-3",
	"locomotive-mu", "bob-locomotive-2-mu", "bob-locomotive-3-mu",
	"cargo-wagon", "bob-cargo-wagon-2", "bob-cargo-wagon-3",
	"fluid-wagon", "bob-fluid-wagon-2", "bob-fluid-wagon-3",
}
local available = {}
for _, name in ipairs(names) do
	if prototypes.entity[name] then available[#available + 1] = name end
end

for _, surface in pairs(game.surfaces) do
	for _, entity in pairs(surface.find_entities_filtered({ name = available })) do
		if entity.type == "fluid-wagon" then
			local fluid = entity.get_fluid(1)
			local capacity = entity.prototype.get_fluid_capacity(entity.quality)
			if fluid and fluid.amount > capacity then
				fluid.amount = capacity
				entity.set_fluid(1, fluid)
			end
		end

		local grid = entity.grid
		if grid then
			local allowed = {}
			for _, category in pairs(grid.prototype.equipment_categories) do allowed[category] = true end
			local remove = {}
			for _, equipment in pairs(grid.equipment) do
				local fits = equipment.position.x + equipment.shape.width <= grid.width
					and equipment.position.y + equipment.shape.height <= grid.height
				local compatible = false
				for _, category in pairs(equipment.prototype.equipment_categories) do
					if allowed[category] then compatible = true; break end
				end
				if not fits or not compatible then remove[#remove + 1] = equipment end
			end
			for _, equipment in ipairs(remove) do grid.take({ equipment = equipment }) end
		end
	end
end
