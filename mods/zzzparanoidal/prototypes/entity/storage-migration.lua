-- Промежуточный контейнер сохраняет 256 слотов силоса до согласованной обрезки в Lua.
local target = "WideChests_steel-chest-warehouse-4x4"
local source = assert(data.raw.container[target], "Storage migration requires WideChests steel warehouse 4x4")
local entity = table.deepcopy(source)
entity.name = "paranoidal-storage-silo-migration"
entity.inventory_size = 256
entity.hidden = true
entity.hidden_in_factoriopedia = true
entity.next_upgrade = nil
entity.fast_replaceable_group = nil
entity.minable = nil
entity.placeable_by = nil
local logistic = table.deepcopy(entity)
logistic.name = "paranoidal-storage-logistic-silo-migration"
logistic.type = "logistic-container"
logistic.logistic_mode = "requester"
-- Не менять logistic-container на container в JSON: движок теряет часть инвентаря.
local warehouse = table.deepcopy(assert(data.raw.container["warehouse-basic"]))
warehouse.name = "paranoidal-storage-warehouse-migration"
warehouse.inventory_size = data.raw["logistic-container"]["warehouse-storage"].inventory_size
warehouse.hidden = true
warehouse.hidden_in_factoriopedia = true
warehouse.next_upgrade = nil
warehouse.fast_replaceable_group = nil
warehouse.minable = nil
warehouse.placeable_by = nil
data:extend({ entity, logistic, warehouse })
