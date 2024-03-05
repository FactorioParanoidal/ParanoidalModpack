--[[
--]]
require "util"
local config = require "config"

global.network_ui = global.network_ui or {}
global.network_icons = global.network_icons or {}

ltnc_network = {
}

ltnc_network.mod_init = function()
end

ltnc_network.event_map = function(events)
  -- [[ EVENTS ]] --
  events.map_gui_closed["ltnc-network-config"] = ltnc_network.close
  
  -- additional elements
  local key
  for i=1, 32 do
    key = string.format("ltnc-network-config_%d", i)
    events.map_elem_changed[key] = ltnc_network.on_icon_changed
  end
end

ltnc_network.open = function(event)
  if global.network_ui[event.player_index] then return end
  
  global.network_ui[event.player_index] = ltnc_network.build_ui(game.players[event.player_index].gui.center, event.player_index)
  
  local window = global.gui[event.player_index]
  
  if window.registered == false then
    window.combinator = nil
    window.main_frame.visible = false
  else
    game.players[event.player_index].opened = global.network_ui[event.player_index]
  end
  
  window.opened = global.network_ui[event.player_index]
end


ltnc_network.close = function(event)
  if not event.element or event.element.name ~= "ltnc-network-config" then return end

  if global.network_ui[event.player_index] ~= nil then
    global.network_ui[event.player_index].destroy()
    global.network_ui[event.player_index] = nil
  end
  
  local window = global.gui[event.player_index]
  window.opened = nil
  dlog("closing networking config")
  global.network_ui[event.player_index] = nil
end

ltnc_network.on_icon_changed = function(event)
  -- extract network id
  local networkid = tonumber(string.match(event.element.name, "%d+"))
  
  -- remove entry
  if event.element.elem_value == nil then
    global.network_icons[networkid] = nil
    return
  end
  
  -- add icon 
  local type = event.element.elem_value.type or ""
  local name = event.element.elem_value.name or ""
  
  type = (type == "virtual") and "virtual-signal" or type
  
  global.network_icons[networkid] = {type = type, name = name}  
end

ltnc_network.build_ui = function(parent, player_index)
  local network_config_container = parent.add {type="flow", direction="vertical", name="ltnc-network-config" }
  network_config_container.style.vertical_spacing = 0
  local network_config_frame = network_config_container.add {type="frame", caption={"ltnc.ltnc-network-config-title"}, direction="vertical", style="ltnc_network_frame"}

  network_config_frame.add {type="label", caption={"ltnc.ltnc-network-config-desc"}}
  local container = network_config_container.add {type="frame", style="ltnc_frame_style"}
  local table = container.add {type="table", column_count="12"}
  
  for i=1,32 do
    table.add {type="label", caption="#" .. i}
    local element = table.add {type="choose-elem-button", name="ltnc-network-config_" .. i, elem_type = "signal"}

    if global.network_icons[i] ~= nil then
      local signal = {  
        type = global.network_icons[i].type == "virtual-signal" and "virtual" or global.network_icons[i].type,
        name = global.network_icons[i].name
      }
      element.elem_value = signal
      
    end
  end
  
  return network_config_container
end 


  
return ltnc_network
