local function copy_entity(_type, name, new_name)
	return flib.copy_prototype(data.raw[_type][name], new_name)
end

local salvaged_mining_drill_entity = copy_entity("mining-drill", "burner-mining-drill", "salvaged-mining-drill")

salvaged_mining_drill_entity.mining_speed = 0.1

data:extend({
	salvaged_mining_drill_entity,
})
--извлечённые пакеты для извлечённой лаборатории, дальше только своим ходом
data.raw["lab"]["salvaged-lab"].inputs = { "salvaged-automation-science-pack" }
