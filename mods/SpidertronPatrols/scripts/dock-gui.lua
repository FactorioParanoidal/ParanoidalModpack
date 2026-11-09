local DockGui = {}

local spidertron_prototypes = prototypes.get_entity_filtered{{filter = "type", type = "spider-vehicle"}}
DockGui.inventories_enabled = {
  trunk = false,
  ammo = false,
  trash = false,
  fuel = false,
  burnt_result = false,
}
for _, prototype in pairs(spidertron_prototypes) do
  if (prototype.get_inventory_size(defines.inventory.spider_trunk) or 0) > 0 then
    DockGui.inventories_enabled.trunk = true
  end
  if (prototype.get_inventory_size(defines.inventory.spider_ammo) or 0) > 0 then
    DockGui.inventories_enabled.ammo = true
  end
  --if (prototype.get_inventory_size(defines.inventory.spider_trash) or 0) > 0 then  -- Engine bug: always returns nil
  DockGui.inventories_enabled.trash = true
  --end
  if (prototype.get_inventory_size(defines.inventory.fuel) or 0) > 0 then
    DockGui.inventories_enabled.fuel = true
  end
  if (prototype.get_inventory_size(defines.inventory.burnt_result) or 0) > 0 then
    DockGui.inventories_enabled.burnt_result = true
  end
end

---@class DockGuiElements
---@field sp-relative-frame LuaGuiElement
---@field sp-dock-mode-trunk LuaGuiElement
---@field sp-dock-mode-trash LuaGuiElement
---@field sp-dock-mode-ammo LuaGuiElement
---@field sp-dock-mode-fuel LuaGuiElement
---@field sp-dock-mode-burnt-result LuaGuiElement

---@param player LuaPlayer
---@param dock_mode defines.inventory
local function build_gui(player, dock_mode)
  local anchor = {
    gui = defines.relative_gui_type.proxy_container_gui,
    position = defines.relative_gui_position.right
  }

  storage.spidertron_dock_guis[player.index] = gui.add(player.gui.relative, {
    {
      type = "frame",
      --style = "sp_relative_stretchable_frame",
      name = "sp-dock-relative-frame",
      direction = "vertical",
      anchor = anchor,
      --style_mods = {width = 300},
      children = {
        {type = "label", style = "frame_title", caption = {"gui-dock.connect-to-inventory"}, ignored_by_interaction = true},
        {type = "frame", direction = "vertical", style = "inside_shallow_frame_with_padding", children = {
          {
            type = "flow",
            direction = "vertical",
            style = "inset_frame_container_vertical_flow",
            children = {
              --{type = "label", caption = "My label"},
              {type = "flow", direction = "vertical", children = {
                {
                  type = "radiobutton", name = "sp-dock-mode-trunk", caption = {"gui-car.trunk"},
                  state = dock_mode == defines.inventory.spider_trunk,
                  visible = DockGui.inventories_enabled.trunk,
                  handler = {[defines.events.on_gui_checked_state_changed] = DockGui.dock_mode_changed},
                },
                {
                  type = "radiobutton", name = "sp-dock-mode-trash", caption = {"description.total-trash"},
                  state = dock_mode == defines.inventory.spider_trash,
                  visible = DockGui.inventories_enabled.trash,
                  handler = {[defines.events.on_gui_checked_state_changed] = DockGui.dock_mode_changed},
                },
                {
                  type = "radiobutton", name = "sp-dock-mode-ammo", caption = {"gui.ammo"},
                  state = dock_mode == defines.inventory.spider_ammo,
                  visible = DockGui.inventories_enabled.ammo,
                  handler = {[defines.events.on_gui_checked_state_changed] = DockGui.dock_mode_changed},
                },
                {
                  type = "radiobutton", name = "sp-dock-mode-fuel", caption = {"gui.fuel"},
                  state = dock_mode == defines.inventory.fuel,
                  visible = DockGui.inventories_enabled.fuel,
                  handler = {[defines.events.on_gui_checked_state_changed] = DockGui.dock_mode_changed},
                },
                {
                  type = "radiobutton", name = "sp-dock-mode-burnt-result", caption = {"gui-dock.burnt-result"},
                  state = dock_mode == defines.inventory.burnt_result,
                  visible = DockGui.inventories_enabled.burnt_result,
                  handler = {[defines.events.on_gui_checked_state_changed] = DockGui.dock_mode_changed},
                },
              }},
            }
          }
        }}
      }
    }
  })
end

---@param element LuaGuiElement
---@param dock LuaEntity
---@param gui_elements DockGuiElements
function DockGui.dock_mode_changed(element, dock, gui_elements)
  if element.name == "sp-dock-mode-trunk" then
    dock.proxy_target_inventory = defines.inventory.spider_trunk
    gui_elements["sp-dock-mode-trash"].state = false
    gui_elements["sp-dock-mode-ammo"].state = false
    gui_elements["sp-dock-mode-fuel"].state = false
    gui_elements["sp-dock-mode-burnt-result"].state = false
  elseif element.name == "sp-dock-mode-trash" then
    dock.proxy_target_inventory = defines.inventory.spider_trash
    gui_elements["sp-dock-mode-trunk"].state = false
    gui_elements["sp-dock-mode-ammo"].state = false
    gui_elements["sp-dock-mode-fuel"].state = false
    gui_elements["sp-dock-mode-burnt-result"].state = false
  elseif element.name == "sp-dock-mode-ammo" then
    dock.proxy_target_inventory = defines.inventory.spider_ammo
    gui_elements["sp-dock-mode-trunk"].state = false
    gui_elements["sp-dock-mode-trash"].state = false
    gui_elements["sp-dock-mode-fuel"].state = false
    gui_elements["sp-dock-mode-burnt-result"].state = false
  elseif element.name == "sp-dock-mode-fuel" then
    dock.proxy_target_inventory = defines.inventory.fuel
    gui_elements["sp-dock-mode-trunk"].state = false
    gui_elements["sp-dock-mode-trash"].state = false
    gui_elements["sp-dock-mode-ammo"].state = false
    gui_elements["sp-dock-mode-burnt-result"].state = false
  elseif element.name == "sp-dock-mode-burnt-result" then
    dock.proxy_target_inventory = defines.inventory.burnt_result
    gui_elements["sp-dock-mode-trunk"].state = false
    gui_elements["sp-dock-mode-trash"].state = false
    gui_elements["sp-dock-mode-ammo"].state = false
    gui_elements["sp-dock-mode-fuel"].state = false
  end
end

gui.add_handlers(DockGui,
  function(event, handler)
    local player = game.get_player(event.player_index)  ---@cast player -?
    local entity = player.opened
    if not entity or not entity.valid then return end
    local gui_elements = storage.spidertron_dock_guis[player.index]
    handler(event.element, entity, gui_elements)
  end
)

---@param event EventData.on_gui_opened
local function on_gui_opened(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if entity.name == "sp-spidertron-dock" or (entity.type == "entity-ghost" and entity.ghost_name == "sp-spidertron-dock") then
    local player = game.get_player(event.player_index)  ---@cast player -?
    local relative_frame = player.gui.relative["sp-dock-relative-frame"]
    if relative_frame then
      relative_frame.destroy()
    end

    build_gui(player, entity.proxy_target_inventory)
  else
    if entity.type == "proxy-container" then
      local player = game.get_player(event.player_index)  ---@cast player -?
      local relative_frame = player.gui.relative["sp-dock-relative-frame"]
      if relative_frame then
        relative_frame.destroy()
      end
    end
  end
end

---@param event EventData.on_gui_closed
local function on_gui_closed(event)
  local player = game.get_player(event.player_index)  ---@cast player -?
  local entity = event.entity
  if not entity or not entity.valid then return end
  if entity.name:sub(0, 19) ~= "sp-spidertron-dock-" then return end
  if entity and (entity.type == "container" or entity.type == "logistic-container") then
    local relative_frame = player.gui.relative["sp-dock-relative-frame"]
    if relative_frame then
      relative_frame.destroy()
    end
    storage.spidertron_dock_guis[player.index] = nil
  end
end

DockGui.events = {
  [defines.events.on_gui_opened] = on_gui_opened,
  [defines.events.on_gui_closed] = on_gui_closed,
}

DockGui.on_init = function()
  ---@type table<PlayerIndex, DockGuiElements>
  storage.spidertron_dock_guis = {}
end

DockGui.on_configuration_changed = function()
  storage.spidertron_dock_guis = storage.spidertron_dock_guis or {}
end

return DockGui