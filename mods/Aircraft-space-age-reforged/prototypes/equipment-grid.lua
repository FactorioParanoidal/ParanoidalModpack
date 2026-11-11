local aircraft = require("shared.aircraft")
local definitions = {{type = "equipment-category", name = "aircraft"}}
for _, spec in ipairs(aircraft.aircraft) do
  if spec.grid then
    definitions[#definitions + 1] = {
      type = "equipment-grid", name = spec.grid, width = spec.grid_size[1], height = spec.grid_size[2],
      equipment_categories = {"armor", "aircraft"}
    }
  end
end
data:extend(definitions)
