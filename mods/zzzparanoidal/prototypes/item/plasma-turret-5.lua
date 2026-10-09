local source = data.raw.item["bob-plasma-turret-4"]
if not source then
	return
end

local item = table.deepcopy(source)
item.name = "bob-plasma-turret-5"
item.place_result = item.name
item.localised_name = { "entity-name.bob-plasma-turret-5" }
item.subgroup = "paranoidal-split-defense-plasma-turrets"
item.order = "05"
require("prototypes.plasma-turret-5-graphics")(item)
data:extend({ item })
