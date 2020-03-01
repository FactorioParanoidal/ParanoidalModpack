-- data.raw.item["solar-panel-equipment"]

-- local powers = {80, 60, 40, 30, 20, 10, 0}
-- local powers = {90, 70, 30, 10, 0} -- no 0 in factorio 0.17.44
local powers = {90, 70, 30, 10, 1} -- no 0 in factorio 0.17.44

local new_panels = {}
for panel_name, panel in pairs (data.raw["solar-panel"]) do
  --panel.localised_name = {'entity-name.'..panel_name} -- just for description
  panel.fast_replaceable_group = "solar-panel"
  for j, p in pairs (powers) do
    local new_panel = table.deepcopy (panel)
    new_panel.name = 'ssp-'..panel_name..'-'..p
    local str = panel.production
    local value = tonumber(string.match(str, "%d+"))
    local unit = string.match(str, "%a+")  
    new_panel.production = (value*(p/100))..unit
    new_panel.order = "r-a-a"
    new_panel.fast_replaceable_group = "solar-panel"
    new_panel.localised_name = {'entity-name.'..panel_name}
    table.insert (new_panels, new_panel)
  end
end

data:extend(new_panels)