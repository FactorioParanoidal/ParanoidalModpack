local libgui = require("__flib__.gui")

---@class NetUI
---@field elems? table<string, LuaGuiElement>
---@field network? uint @ The network id must be between 1 - 32 inclusive
---@field update_ui_network_id_buttons_callback? fun(o: LTNC)
local net_ui = {}

---@param self NetUI
local function update_ui(self)
  local gni = storage.network_descriptions[self.network]
  if gni then
    if gni.icon and helpers.is_valid_sprite_path(gni.icon) then
      local _, _, type, name = string.find(gni.icon, "(.*)/(.*)")
      type = type == "virtual-signal" and "virtual" or type

      ---@type SignalID
      local signal = {type = type, name = name}
      self.elems.icon.elem_value = signal
    end

    self.elems.tip.text = gni.tip or ""
  end

end

local handlers = {

  ---@param e EventData.on_gui_click
  ---@param self NetUI
  netui_close = function(self, e)
    net_ui.close(self, e)
  end,

  ---@param e EventData.on_gui_click
  ---@param self NetUI
  network_description_confirm = function(self, e)
    local nd = storage.network_descriptions
    ---@type NetworkData
    local desc = {}
    local tip = self.elems.tip.text
    local type = "bad"
    local name = "path"
    if self.elems.icon.elem_value then
      type = self.elems.icon.elem_value.type or "item"
      name = self.elems.icon.elem_value.name
    end

    local path = (type == "virtual" and "virtual-signal" or type) .. "/" .. name
    if helpers.is_valid_sprite_path(path) then
      desc.icon = path
    else
      desc.icon = nil
    end

    if tip ~= "" then
      desc.tip = tip
    else
      desc.tip = nil
    end
  
    nd[self.network] = desc

    if self.update_ui_network_id_buttons_callback then
      for _, p in ipairs(storage.players) do
        if p.uis.main then
          self.update_ui_network_id_buttons_callback(p.uis.main)
        end

      end

    end

    net_ui.close(self, e.player_index)

  end,

  network_description_reset = function(self, e)
    update_ui(self)
  end
}

libgui.add_handlers(handlers, function(e, handler)
  local self = storage.players[e.player_index].uis.netui
  if self then
    handler(self, e)
  end
end)

---Create the Network Description Editor for a single network
---@param player LuaPlayer
---@param self NetUI
---@return GuiElemDef
---@diagnostic disable:missing-fields
local function build_single_description(self, player)
  local elems = libgui.add(player.gui.screen, {
    {
      type = "frame",
      name = "net_config_main",
      direction = "vertical",
      handler = { [defines.events.on_gui_closed] = handlers.netui_close },
      { -- Title Bar
        type = "flow",
        style = "flib_titlebar_flow",
        drag_target = "net_config_main",
        {
          type = "label",
          style = "frame_title",
          caption = { "ltnc.net-description-title", self.network },
          ignored_by_interaction = true,
        },
        {
          type = "empty-widget",
          style = "flib_titlebar_drag_handle",
          ignored_by_interaction = true,
        },
        {
          type = "sprite-button",
          style = "frame_action_button",
          sprite = "utility/close",
          --hovered_sprite = "utility/close_black",
          --clicked_sprite = "utility/close_black",
          mouse_button_filter = { "left" },
          handler = { [defines.events.on_gui_click] = handlers.netui_close },
        }
      },
      { -- Main Panel
        type = "frame",
        style = "inside_shallow_frame_with_padding",
        {
          type = "flow",
          direction = "vertical",
          {
            type = "choose-elem-button",
            elem_type = "signal",
            name = "icon",
            style_mods = { size = 60 },
          },
          {
          type = "flow",
            {
              type = "sprite-button",
              style = "ltnc_confirm_button",
              name = "network_description_confirm",
              mouse_button_filter = { "left" },
              sprite = "utility/check_mark",
              handler = { [defines.events.on_gui_click] = handlers.network_description_confirm },
            },
            {
              type = "sprite-button",
              style = "ltnc_cancel_button",
              name = "network_description_cancel",
              mouse_button_filter = { "left" },
              sprite = "utility/reset",
              handler = { [defines.events.on_gui_click] = handlers.network_description_reset },
            },
          },
        },
        {
          type = "text-box",
          name = "tip",
          clear_and_focus_on_right_click = true,
          elem_mods = { word_wrap = true },
          style_mods = { height = 92 },
        },
      },
    }
  })
  return elems
end -- build_single_description()
---@diagnostic enable:missing-fields

---Open the network description editor
---@param e EventData.on_gui_click
---@param callback fun(o: LTNC)?
function net_ui.open_single(e, callback)
  local player = game.get_player(e.player_index)
  if not player or not player.valid then
    return
  end

  local pt = storage.players[e.player_index]
  if pt.uis.netui then
    net_ui.close(pt.uis.netui, e.player_index)
  end

  ---@type NetUI
  local new_ui = {}
  new_ui.network = e.element.get_index_in_parent()
  new_ui.elems = build_single_description(new_ui, player)
  new_ui.update_ui_network_id_buttons_callback = callback

  update_ui(new_ui)

  pt.uis.netui = new_ui
  pt.uis.netui.elems.net_config_main.force_auto_center()

end

---Close the description editor
---@param self NetUI
---@param input uint | GuiEventData
function net_ui.close(self, input)
  local ndx = input
  if type(input) == "table" then
    ndx = input.player_index
  end
  local pt = storage.players[ndx]

  if pt.uis.netui and pt.uis.netui.elems then
    pt.uis.netui.elems.net_config_main.destroy()
    pt.uis.netui = nil
  end

end

return net_ui
