-- data.raw.item["solar-panel-equipment"]

-- local powers = {80, 60, 40, 30, 20, 10, 0}
-- local powers = {90, 70, 30, 10, 0} -- no 0 in factorio 0.17.44
local powers = {90, 70, 30, 10, 1} -- no 0 in factorio 0.17.44

local new_panels = {}
for panel_name, panel in pairs (data.raw["solar-panel"]) do
  -- panel.fast_replaceable_group = "solar-panel" -- why I need it?
  
  
  local str = panel.production
  
  -- local a = str -- 0.2kW
  -- log(string.match(a, '%S+$')) -- 0.2kW
  -- log(string.match(a, '%d[%d.,]*')) -- 0.2
  -- log(string.match(a, '%f[%d]%d[,.%d]*%f[%D]')) -- 0.2
  
  
  local value = tonumber(string.match(str, "%d+"))
  if (value == 0) then
    value = tonumber(string.match(str, "%d[%d.,]*"))
  end
  
  local unit = string.match(str, "%a+") 
  
  if value > 0 then
    for j, p in pairs (powers) do
      local new_panel = table.deepcopy (panel)
      new_panel.name = 'ssp-'..panel_name..'-'..p
   
      new_panel.production = (value*(p/100))..unit
      new_panel.order = "r-a-a"
--      new_panel.fast_replaceable_group = "solar-panel"
      new_panel.fast_replaceable_group = panel.fast_replaceable_group or "solar-panel" -- added in 0.2.2
      new_panel.localised_name = {'entity-name.'..panel_name}
      table.insert (new_panels, new_panel)
    end
  else
    log ('exception for solar panel ["' .. panel_name .. '"], production: ' .. str .. ' value: ' .. value .. ' unit: ' .. unit)
  end
end

data:extend(new_panels)