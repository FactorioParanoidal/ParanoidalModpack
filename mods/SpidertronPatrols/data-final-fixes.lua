sp_data_stage = "data-final-fixes"
require "prototypes.nullius"

-- Paranoidal fork: home spider vehicles keep their flags (upstream stopped inserters at every spider vehicle, the
-- home spidertron and Big Monsters' saucers included; Maraxsis' submarines carry these flags themselves).

local spiderling_grid = data.raw["equipment-grid"]["sp-spiderling-equipment-grid"]
if spiderling_grid and not mods["nullius"] then
  -- Won't exist if spiderlings are disabled or if another mod removes it
  spiderling_grid.equipment_categories = data.raw["equipment-grid"][data.raw["spider-vehicle"]["spidertron"].equipment_grid].equipment_categories
end

if mods["AutoTrash"] then
  -- Further workarounds for https://forums.factorio.com/viewtopic.php?f=7&t=98151
  local styles = data.raw["gui-style"].default

  styles.at_right_scroll_pane.maximal_height = 165
  -- Spidertron Patrols frame height is configurable and set at runtime
end
