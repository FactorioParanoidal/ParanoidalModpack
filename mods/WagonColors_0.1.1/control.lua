--[[
-- Author: Optera 2019
--]]

-- copy colors locomotive, train-stop <-> cargo-wagon, fluid-wagon.
local ColorCopyTypes = {
  ["cargo-wagon"] = { ["train-stop"] = true, ["locomotive"] = true, ["cargo-wagon"] = true, ["fluid-wagon"] = true },
  ["fluid-wagon"] = { ["train-stop"] = true, ["locomotive"] = true, ["cargo-wagon"] = true, ["fluid-wagon"] = true },
}


local function OnSettingsPasted(event)
  local source = event.source
  local destination = event.destination
  -- local player = game.players[player_index]
  
  if ColorCopyTypes[source.type] and ColorCopyTypes[source.type][destination.type] or
    ColorCopyTypes[destination.type] and ColorCopyTypes[destination.type][source.type] then
    local source_color = source.color or source.prototype.color
    if source_color then      
      destination.color = source_color
    end
  end
end

---- Bootstrap ----
do
local function init_events()
  script.on_event(defines.events.on_entity_settings_pasted, OnSettingsPasted)
end

script.on_load(function()
	init_events()
end)

script.on_init(function()
	init_events()
end)

end