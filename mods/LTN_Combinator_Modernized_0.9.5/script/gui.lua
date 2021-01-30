local gui = require("__flib__.gui")
local event = require("__flib__.event")
--local migration = require("__flib__.migration")

local config = require "config"
local ltnc_util = require("script.util")
require("script.ltn-combinator")

local ltnc_gui = {}

-- Forward delcaration
local create_window
local create_net_config

-------------------------
--  Handlers
-------------------------

local function update_signal_table(ltnc, slot, signal)
  dlog("update_signal_table")
  if signal and signal.signal then
    local b = ltnc.signals[slot].button
    local type = signal.signal.type == "virtual" and "virtual-signal" or signal.signal.type
    b.elem_value = signal.signal
    b.children[1].caption = ltnc_util.format_number(signal.count, true)
    b.locked = true
  end
end -- update_signal_table()

local function update_ltn_signals(ltnc)
  for name, details in pairs(config.ltn_signals) do 
    local value = ltnc.combinator:get(name)
    local elem = nil
    if name == "ltn-network-id" then
      elem = ltnc["net_id_flow"]["ltnc-element__"..name]
    else
      elem = ltnc["ltn_signals_"..details.stop_type]["ltnc-element__"..name]
    end
    if  elem then
      if elem.type == "checkbox" then
        elem.state = (value > 0 and true or false)
      else
        elem.text = tostring(value)
      end
    end
  end
end -- update_ltn_signals()

local function update_net_id_buttons(ltnc, networkid)
  dlog("gui.lua: update_net_id_buttons")
  for i=1,32 do
    local bit = 2^(i-1)
    ltnc.net_id_table.children[i].style = (bit32.btest(networkid, bit) and "ltnc_net_id_button_pressed" or "ltnc_net_id_button")
    if global.network_icons[i] ~= nil then
      dlog(string.format("%s/%s", global.network_icons[i].type, global.network_icons[i].name))
      ltnc.net_id_table.children[i].sprite = global.network_icons[i].type .. "/" .. global.network_icons[i].name
      ltnc.net_id_table.children[i].caption = ""
    end
  end
end -- update_net_id_buttons()

local function update_visible_components(ltnc, pi)
  local stop_type = ltnc.combinator:get_stop_type()
  dlog(stop_type)
  if stop_type == nil then stop_type = config.LTN_STOP_NONE end
  if stop_type == config.LTN_STOP_NONE or stop_type == config.LTN_STOP_DEPOT then
    ltnc.signal_pane.visible = false
  else
    ltnc.signal_pane.visible = true
  end
  local prov = bit32.btest(stop_type, config.LTN_STOP_PROVIDER)
  local req = bit32.btest(stop_type, config.LTN_STOP_REQUESTER)
  ltnc.chk_depot.state = bit32.btest(stop_type, config.LTN_STOP_DEPOT)
  ltnc.chk_requester.state = req
  ltnc.chk_provider.state = prov
  if settings.get_player_settings(pi)["show-all-panels"].value then
    ltnc.ltn_req_fr.visible = true
    ltnc.ltn_prov_fr.visible = true
  else
    ltnc.ltn_req_fr.visible =  req
    ltnc.ltn_prov_fr.visible = prov
  end
end -- update_visible_components()

local function set_new_output_value(ltnc, new_value)
  ltnc.combinator:set_slot_value(ltnc.selected_slot, new_value)
  ltnc.signal_value_slider.enabled = false
  ltnc.signal_value_text.enabled = false
  ltnc.signal_value_confirm.enabled = false
  ltnc.signals[ltnc.selected_slot].button.children[1].caption = ltnc_util.format_number(new_value, true)
  ltnc.selected_slot = nil
end -- set_new_output_value()

-- Display the Net Config UI
function ltnc_gui.Open_Netconfig(player_index)
  dlog("gui.lua Netconfig")
  local player = game.get_player(player_index)
  local rootgui = player.gui.screen
  if rootgui["ltnc-net-config"] then
    ltnc_gui.Close(player_index, "ltnc-net-config")
  end
  
  local netconfig = create_net_config(player_index)
  for i = 1, 32 do
    if global.network_icons[i] ~= nil then
      local type = global.network_icons[i].type
      local name = global.network_icons[i].name
      local signal = {
        type = type == "virtual-signal" and "virtual" or type,
        name = name
      }
      netconfig.netconfig_table.children[i].children[2].elem_value = signal
    end
  end

  local pd = ltnc_util.get_player_data(player_index)
  pd.netconfig = netconfig
  --player.opened = pd.netconfig.net_config
end -- Open_Netconfig()

-- Display the GUI for the player
function ltnc_gui.Open(player_index, entity)
  dlog("gui.lua: Open")
  --[[
      Check if player has an LTN Combinator open.
      If the player is trying to open the same LTN Combinator do nothing.
      If a different LTN Combinator, first close the open one, then open the new one.
      If opening something else, close the open LTN Combinator.
  ]]
  local player = game.get_player(player_index)
  local rootgui = player.gui.screen
  if rootgui["ltnc-main-window"] then
    if rootgui["ltnc-main-window"].tags.unit_number  == entity.unit_number then
      player.opened = rootgui["ltnc-main-window"]
      return
    end
    ltnc_gui.Close(player_index)
  end
  local ltnc = create_window(player_index, entity.unit_number)
  ltnc.ep.entity = entity

  -- Create an object to hold an interface with conbinator entity
  ltnc.combinator = ltn_combinator:new(entity)
  if not ltnc.combinator then
    dlog("Failed to create LTN-C object")
  end

  -- read stop type and set checkboxes
  update_visible_components(ltnc, player_index)

  -- read and apply ltn signals
  update_ltn_signals(ltnc)

  -- read on/off switch
  ltnc.on_off.switch_state = ltnc.combinator:is_enabled() and "right" or "left"

  -- read and update other signals
  for slot = 1, config.ltnc_misc_slot_count do
    local signal = ltnc.combinator:get_slot(slot)
    update_signal_table(ltnc, slot, signal)
  end

  -- read and setup the network ID Configurator
  local networkid = ltnc.combinator:get("ltn-network-id")
  update_net_id_buttons(ltnc, networkid)

  local pd = ltnc_util.get_player_data(player_index)
  pd.ltnc = ltnc

  if MOD_STD_UI then return end
  player.opened = pd.ltnc.main_window

end -- Open()

function ltnc_gui.Close(player_index, name)
  dlog("gui.lua: Close")
  local window = name or "ltnc-main-window"
  local player = game.get_player(player_index)
  local rootgui = player.gui.screen
  if window and rootgui[window] then
    rootgui[window].destroy()
    if window == "ltnc-main-window" then
      gui.update_filters("ltnc_handlers", player_index, nil, "remove")
    elseif window == "ltnc-net-config" then
      gui.update_filters("netconfig_handlers", player_index, nil, "remove")
    end
  end
  -- TODO: Figuire out how to play close sound
end -- Close()

local function change_signal_count(ltnc, e)
  local slot = ltnc.selected_slot

  local signal = ltnc.combinator:get_slot(slot)
  if not signal or not signal.signal then
    print({"ltnc.combinator-gone"})
    ltnc_gui.Close(e.player_index)
    return
  end

  local value = signal.count
  -- TODO: Get inteligent about this...  detect or setting for larger storage containers?
  -- Make display number of stacks?
  local stack_size = 25000 -- default fluid
  local max_slider = 1000000 -- Large default based on Angel's storage tanks?  Get smarter.
  if signal.signal.type == "item" then
    stack_size = game.item_prototypes[signal.signal.name].stack_size
    max_slider = stack_size * 256 -- More hard coded defaults to fix...
  end
  dlog(signal.signal.type .. " " .. stack_size)
  ltnc.signal_value_slider.set_slider_minimum_maximum(0,max_slider)
  ltnc.signal_value_slider.set_slider_value_step(stack_size)
  ltnc.signal_value_slider.slider_value = value * -1
  ltnc.signal_value_slider.enabled = true

  ltnc.signal_value_text.text = tostring(value)
  ltnc.signal_value_text.enabled = true
  ltnc.signal_value_text.focus()

  ltnc.signal_value_confirm.visible = true
  ltnc.signal_value_confirm.enabled = false
end -- change_signal_count()

function ltnc_gui.RegisterTemplates()
  gui.add_templates{
    drag_handle = {type="empty-widget", style="flib_titlebar_drag_handle", elem_mods={ignored_by_interaction=true}},
    frame_action_button = {type="sprite-button", style="frame_action_button", mouse_button_filter={"left"}},
    ltnc_entry_text = {
      type="textfield", style="short_number_textfield",
      style_mods={horizontal_align="right", horizontally_stretchable="off"}
    },
    confirm_button = {template="frame_action_button", style="item_and_count_select_confirm", sprite="utility/check_mark"},
    close_button = {template="frame_action_button", sprite="utility/close_white", hovered_sprite="utility/close_black"},
    checkbox = {type="checkbox", state=false, style_mods={top_margin=8}},
    chk_stoptype = {template="checkbox", handlers="ltnc_handlers.stop_type"},
    network_id_table = function(rows)
      local t = {type="table", save_as="net_id_table", column_count=4, children={}}
      for i=1,rows do
        t.children[i] = {type="sprite-button", handlers="ltnc_handlers.net_id_toggle", name=i, style="ltnc_net_id_button", caption=i}
      end
      return t
    end,
    network_id_labels = function(count)
      local items = {}
      for i = 1, count do
        items[i] = {type="table", column_count=2, children={
          {type="label", caption="# "..i, style_mods={horizontally_stretchable=true, width=32}},
          {type="choose-elem-button", style="ltnc_net_id_button", name=i, elem_type="signal", handlers="netconfig_handlers.choose_button"},
        }}
      end
      return items
    end,
  }
end -- RegisterTemplates()

function ltnc_gui.RegisterHandlers()
  gui.add_handlers{
    ltnc_handlers = {
      close_button = {
        on_gui_click = function(e)
          ltnc_gui.Close(e.player_index)
        end -- on_gui_click
      },
      slider = {

        --TODO: validate signal type for negativity
        on_gui_value_changed = function(e)
          local ltnc = global.player_data[e.player_index].ltnc
          ltnc.signal_value_confirm.enabled = true
          ltnc.signal_value_text.text = tostring(e.element.slider_value * -1)
        end
      },
      signal_text = {
        --TODO: validate signal type for negativity
        on_gui_text_changed = function(e)
          if not tonumber(e.element.text) then return end
          local ltnc = global.player_data[e.player_index].ltnc
          local value = tonumber(e.element.text)
          local min = -2^31
          local max = 2^31-1
          value = math.min(value, max)
          value = math.max(value, min)
          e.element.text = tostring(value)
          ltnc.signal_value_confirm.enabled = true
          ltnc.signal_value_slider.slider_value = math.abs(value)
        end,
        on_gui_confirmed = function(e)
          local ltnc = global.player_data[e.player_index].ltnc
          if not tonumber(ltnc.signal_value_text.text) then return end
          local new_value = ltnc.signal_value_text.text
          set_new_output_value(ltnc, new_value)
        end
      },
      confirm_button = {
        on_gui_click = function(e)
          local ltnc = global.player_data[e.player_index].ltnc
          if not tonumber(ltnc.signal_value_text.text) then return end
          local new_value = ltnc.signal_value_text.text
          set_new_output_value(ltnc, new_value)
        end
      },
      choose_button = {
        on_gui_elem_changed = function(e)
          if e.element.elem_value == nil then return end
          dlog("choose_button - on_gui_elem_changed - "..e.element.elem_value.name)
          local ltnc = global.player_data[e.player_index].ltnc
          local _, _, slot =  string.find(e.element.name, "__(%d+)")
          slot = tonumber(slot)
          ltnc.selected_slot = slot
          local signal = {signal=e.element.elem_value, count=0}
          ltnc.combinator:set_slot(slot, signal)
          e.element.locked = true
          change_signal_count(ltnc, {button=defines.mouse_button_type.left,
                                      element={number=0},
                                      player_index=e.player_index})
        end,
        on_gui_click = function(e)
          dlog("choose_button - on_gui_click: "..e.button)
          local ltnc = global.player_data[e.player_index].ltnc
          local _, _, slot =  string.find(e.element.name, "__(%d+)")
          slot = tonumber(slot)
          if e.button == defines.mouse_button_type.right then
            ltnc.combinator:remove_slot(slot)
            e.element.locked = false
            e.element.elem_value = nil
            e.element.children[1].caption = ""
          elseif e.button == defines.mouse_button_type.left and e.element.elem_value then
            ltnc.selected_slot = slot
            change_signal_count(ltnc, e)
          end
        end
      },
      on_off_switch = {
        on_gui_switch_state_changed = function(e)
          local ltnc = global.player_data[e.player_index].ltnc
          ltnc.combinator:set_enabled(e.element.switch_state == "right")
        end
      },
      stop_type = {
        --on_gui_checked_state_changed = function(e)
        on_gui_click = function(e)
          local ltnc = global.player_data[e.player_index].ltnc
          local stop_type = ltnc.combinator:get_stop_type()
          if not stop_type then
            print({"ltnc.combinator-gone"})
            ltnc_gui.Close(e.player_index)
            return
          end
          dlog("Current stop type: "..stop_type.." - shift: ".. (e.shift and "true" or "false"))
          if e.element.name == "chk-depot" then
            dlog("chk-depot")
            if e.element.state == true then
              ltnc.combinator:set_stop_type(config.LTN_STOP_DEPOT)
            else
              ltnc.combinator:set_stop_type(config.LTN_STOP_NONE)
            end
          elseif e.element.name == "chk-provider" then
            dlog("chk-provider")
            if e.element.state == false then
              ltnc.combinator:set_stop_type(bit32.bxor(stop_type, config.LTN_STOP_PROVIDER))
            else
              if (bit32.btest(stop_type, config.LTN_STOP_REQUESTER) and e.shift) then
                ltnc.combinator:set_stop_type(bit32.bor(config.LTN_STOP_REQUESTER, config.LTN_STOP_PROVIDER))
              else
                ltnc.combinator:set_stop_type(config.LTN_STOP_PROVIDER)
              end
            end
          elseif e.element.name == "chk-requester" then
            dlog("chk-requester")
            if e.element.state == false then
              ltnc.combinator:set_stop_type(bit32.bxor(stop_type, config.LTN_STOP_REQUESTER))
            else
              if (bit32.btest(stop_type, config.LTN_STOP_PROVIDER) and e.shift) then
                ltnc.combinator:set_stop_type(bit32.bor(config.LTN_STOP_REQUESTER, config.LTN_STOP_PROVIDER))
              else
                ltnc.combinator:set_stop_type(config.LTN_STOP_REQUESTER)
              end
            end
          end
          update_visible_components(ltnc, e.player_index)
          update_ltn_signals(ltnc)
        end
      },
      ltn_signal_entries = {
        on_gui_text_changed = function(e)
          dlog(e.element.name)
          if not tonumber(e.element.text) then return end
          local ltnc = global.player_data[e.player_index].ltnc
          local _, _, signal = string.find(e.element.name, "__(.*)")
          dlog(signal)
          local value = tonumber(e.element.text)

          -- Make sure input is within bounds
          local min = -2000000000
          local max = 2000000000
          if config.ltn_signals[signal] ~= nil then
            min = config.ltn_signals[signal].bounds.min
            max = config.ltn_signals[signal].bounds.max
          end
          value = math.min(value, max)
          value = math.max(value, min)
          e.element.text = tostring(value)

          ltnc.combinator:set(signal, value) 
          if signal == "ltn-network-id" then
            update_net_id_buttons(ltnc, value)
          end
        end,
        on_gui_checked_state_changed = function(e)
          dlog(e.element.name)
          local ltnc = global.player_data[e.player_index].ltnc
          local _, _, signal = string.find(e.element.name, "__(.*)")
          if e.element.state then
            ltnc.combinator:set(signal, 1)
          else
            ltnc.combinator:set(signal, 0)
          end
        end
      },
      net_id_toggle = {
        on_gui_click = function(e)
          dlog("net_id_toggle: on_gui_click "..e.element.name)
          local ltnc = global.player_data[e.player_index].ltnc
          local netid_textbox = ltnc.net_id_flow["ltnc-element__ltn-network-id"]
          local networkid = tonumber(netid_textbox.text)
          local new_netid = nil
          if e.element.name == "net_id_all" then
            new_netid = -1
          elseif e.element.name == "net_id_none" then
            new_netid = 0
          else
            --  can make number larger than signed 32-bit...  need to handle....
            local bit = 2^(tonumber(e.element.name)-1)
            new_netid = bit32.bxor(networkid, bit)
            -- If bit 31 (0-indexed) is set, need to make the number negative.  bit32 only returns values that are 32 bits wide
            -- as expected.   Then underlying data field is bigger, so the negativity isn't mananage the same.
            -- constant combiner will only take an signed, 32-bit int.  Get a bit hacky here...
            if bit32.btest(new_netid, 2^31) then
              new_netid = new_netid - 2^32
            end
          end
          netid_textbox.text = tostring(new_netid)
          ltnc.combinator:set("ltn-network-id", new_netid)
          update_net_id_buttons(ltnc, new_netid)
          -- e.element.style = (bit32.btest(new_netid, bit) and "ltnc_net_id_button_pressed" or "ltnc_net_id_button")
        end
      },
      encode_net_id = {
        on_gui_click = function(e)
          dlog("encode_net_id: on_gui_click "..e.element.name)
          local ltnc = global.player_data[e.player_index].ltnc
          local x = ltnc.main_window.location.x
          local y = ltnc.main_window.location.y
          if e.button == defines.mouse_button_type.left then
            if e.shift then
              ltnc_gui.Open_Netconfig(e.player_index)
              ltnc_gui.Close(e.player_index)
            else
              if ltnc.net_id_flow.visible then
                ltnc.net_id_flow.visible = false
                ltnc.main_window.location = {x + 110, y}
              else
                ltnc.net_id_flow.visible = true
                ltnc.main_window.location = {x - 110, y}
                --ltnc.main_window.location.x = ltnc.main_window.location.x - 128
              end
            end
          end
        end
      },
    },
    netconfig_handlers = {
      close_button = { 
        on_gui_click = function(e)
          ltnc_gui.Close(e.player_index, e.element.name)
        end
      },
      choose_button = {
        on_gui_elem_changed = function(e)
          local net = tonumber(e.element.name)
          if e.element.elem_value == nil then
            global.network_icons[net] = nil
          else
            local type = e.element.elem_value.type
            local name = e.element.elem_value.name
            type =  type == "virtual" and "virtual-signal" or type
            global.network_icons[net] = {type=type, name=name}
          end
        end
      }
    },
  }
  gui.register_handlers()
end -- RegisterHandlers()

-- Define the GUIs
-- Net Config
function create_net_config(player_index)
  local rootgui = game.get_player(player_index).gui.screen
  local netconfig = gui.build(rootgui, {
    {type="frame", direction="vertical", save_as="net_config", name="ltnc-net-config", children={
      -- Title Bar
      {type="flow", save_as="titlebar.flow", children={
        {type="label", style="frame_title", caption={"ltnc.netconfig-title"}, elem_mods={ignored_by_interaction=true}},
        {template="drag_handle"},
        {template="close_button", name="ltnc-net-config", handlers="netconfig_handlers.close_button"},
      }},
      {type="frame", style="inside_shallow_frame_with_padding", style_mods={padding=8}, children={
        {type="table", save_as="netconfig_table", column_count=4, children=gui.templates.network_id_labels(32)}
      }},
    }},
  })
  netconfig.net_config.force_auto_center()
  netconfig.titlebar.flow.drag_target = netconfig.net_config
  return netconfig
end

-- Main Window
function create_window(player_index, unit_number)
  local rootgui = game.get_player(player_index).gui.screen
  local ltnc = gui.build(rootgui, {
    {type="frame", direction="vertical", save_as="main_window", name="ltnc-main-window", tags={unit_number=unit_number}, children={
      -- Title Bar
      {type="flow", save_as="titlebar.flow", children={
        {type="label", style="frame_title", caption={"ltnc.window-title"}, elem_mods={ignored_by_interaction=true}},
        {template="drag_handle"},
        {template="close_button", name="ltnc-main-window", handlers="ltnc_handlers.close_button"}
      }},
      {type="frame", style="inside_shallow_frame_with_padding", style_mods={padding=8}, children={
        -- Network ID Configurator pane
        {type="flow", direction="vertical", save_as="net_id_flow", visible=false, style_mods={horizontal_align="center", padding=2, right_padding=8}, children={
          {type="frame", direction="vertical", style="inside_shallow_frame_with_padding", style_mods={padding=8}, children={
            gui.templates.network_id_table(32),
          }},
          {type="button", name="net_id_all", handlers="ltnc_handlers.net_id_toggle", style_mods={top_margin=8}, caption={"ltnc.btn-all"}},
          {type="button", name="net_id_none", handlers="ltnc_handlers.net_id_toggle", caption={"ltnc.btn-none"}},
        }},
        -- Combinator Main Pane
        {type="flow", direction="vertical", style_mods={horizontal_align="center"}, children={
          -- Entity preview
          {type="frame", style="container_inside_shallow_frame", style_mods={bottom_margin=8}, children={
            {type="entity-preview", save_as="ep", style_mods={
              width=280, height=128, horizontally_stretchable=true
            }},
          }},
          -- Netowrk ID
          {type="table", save_as="ltn_signals_network", column_count=3,
            style_mods={cell_padding=2, horizontally_stretchable=true},
            -- Content added later with Add LTN signals
          },
          -- On/Off siwtch and Stop Type
          {type="table", column_count=3, style_mods={right_cell_padding=10, left_cell_padding=10}, children={
            {type="flow", style_mods={horizontal_align="left"}, direction="vertical", children={
              {type="label", style_mods={top_margin=8}, caption={"ltnc.output"}},
              {type="switch", save_as="on_off", handlers="ltnc_handlers.on_off_switch",
              left_label_caption={"ltnc.off"}, right_label_caption={"ltnc.on"}
              },
            }},
            {type="flow", direction="vertical", children={
              {template="chk_stoptype", save_as="chk_provider", name="chk-provider",
              caption={"ltnc.provider"}, elem_mods={tooltip={"ltnc.provider-tip"}
              }},
              {template="chk_stoptype", save_as="chk_requester", name="chk-requester",
              caption={"ltnc.requester"}, elem_mods={tooltip={"ltnc.requester-tip"}}
              }},
            },
            {type="flow", direction="vertical", children={
              {template="chk_stoptype", save_as="chk_depot", name="chk-depot",
              caption={"ltnc.depot"}, elem_mods={tooltip={"ltnc.depot-tip"}}
              }},
            },
          }},
          {type="line", style_mods={top_margin=5}},
          -- Signal Table
          {type="label", style_mods={top_margin=5}, caption={"ltnc.output-signals"}},
          {type="flow", direction="vertical", style_mods={horizontal_align="center"}, children={
            {type="frame", direction="vertical", style="slot_button_deep_frame",
              children={
                {type="table", style="slot_table", save_as="signal_table",
                style_mods={width=280, minimal_height=80}, column_count=7}
              },
            },
            {type="flow", style_mods={vertical_align="center", top_padding=10}, children={
              {type="slider", save_as="signal_value_slider",
              elem_mods={enabled=false},
              style_mods={horizontally_stretchable=true, right_padding=10},
              minimum_value=-1, maximum_value=50,
              handlers="ltnc_handlers.slider",
              },
              {template="ltnc_entry_text", save_as="signal_value_text", enabled=false,
              elem_mods={numeric=true, text="0", allow_negative=true},
              handlers="ltnc_handlers.signal_text",
              },
              {template="confirm_button", style_mods={left_padding=5}, enabled=false,
              save_as="signal_value_confirm", handlers="ltnc_handlers.confirm_button"}
            }}
          }},
        }},
       -- LTN Signal Pane,
        {type="flow", direction="vertical", save_as="signal_pane", style_mods={left_padding=8, width=300, horizontal_align="center"}, children={
          {type="frame", direction="vertical", style="container_inside_shallow_frame",
          style_mods={padding=8}, children={
            {type="table", save_as="ltn_signals_common", column_count=3,
             style_mods={cell_padding=2, horizontally_stretchable=true},
            },
          }},
          {type="frame", direction="vertical", save_as="ltn_prov_fr", style="container_inside_shallow_frame",
           style_mods={top_margin=12, padding=8}, elem_mods={visible=false}, children={
            {type="table", save_as="ltn_signals_provider", column_count=3,
             style_mods={cell_padding=2, horizontally_stretchable=true},
            },
          }},
          {type="frame", direction="vertical", save_as="ltn_req_fr", style="container_inside_shallow_frame",
           style_mods={top_margin=12, padding=8}, elem_mods={visible=false}, children={
            {type="table", save_as="ltn_signals_requester", column_count=3,
             style_mods={cell_padding=2, horizontally_stretchable=true},
            },
          }},
        }},
      }},
    }},
  })
  -- TODO: Templatize this
  -- Create the slot buttons.
  local signals = {}
  for i=1, config.ltnc_misc_slot_count do
    signals[i] = {button = nil}
    signals[i].button = ltnc.signal_table.add({
      name = "ltnc-signal-button__"..i,
      type = "choose-elem-button",
      style = "flib_slot_button_default",
      elem_type = "signal",
    })
    signals[i].button.add({
      type = "label",
      style = "signal_count",
      ignored_by_interaction = true,
      caption = "",
    })
  end

  -- Add LTN signals
  for name, details in pairs(config.ltn_signals) do
    local table = "ltn_signals_"..details.stop_type
    if name == "ltn-network-id" then
      ltnc[table].add({type="sprite-button", name="ltnc-encode-net-id", style="ltnc_net_net_button", sprite="virtual-signal/"..name,
                       tooltip={"ltnc.net-config-tip"}})
      ltnc[table].add({type="label", name="ltnc-label__"..name, style="ltnc_entry_label", caption={"ltnc.encode-net-id"}})
      ltnc["net_id_flow"].add({type="label", name="ltnc-label__"..name, style="ltnc_entry_label", caption={"virtual-signal-name."..name}})
      ltnc["net_id_flow"].add({type="textfield", name="ltnc-element__"..name, style="ltnc_netid_text",
                        text=details.default, numeric=true, allow_decimal=false, allow_negative=true})
    else
      ltnc[table].add({type="sprite", name="ltnc-sprite__"..name, style="ltnc_entry_sprite", sprite="virtual-signal/"..name})
      ltnc[table].add({type="label", name="ltnc-label__"..name, style="ltnc_entry_label", caption={"virtual-signal-name."..name}})
      if name == "ltn-disable-warnings" then
          ltnc[table].add({type="checkbox", name="ltnc-element__"..name, style="ltnc_entry_checkbox", state=details.default})
      else
        local elem = ltnc[table].add({type="textfield", name="ltnc-element__"..name, style="ltnc_entry_text",
                                      text=details.default, numeric=true, allow_decimal=false, allow_negative=false})
        if details.bounds.min < 0 then
            elem.allow_negative = true
        end
      end
    end
  end

  -- Depot signal should not be visible
  for _, part in pairs{"sprite", "label", "element"} do
    ltnc.ltn_signals_common["ltnc-"..part.."__ltn-depot"].visible = false
  end

  gui.update_filters("ltnc_handlers.choose_button", player_index, {"ltnc-signal-button"}, "add")
  gui.update_filters("ltnc_handlers.ltn_signal_entries", player_index, {"ltnc-element"}, "add")
  gui.update_filters("ltnc_handlers.encode_net_id.on_gui_click", player_index, {"ltnc-encode-net-id"}, "add")
  ltnc.titlebar.flow.drag_target = ltnc.main_window
  ltnc.main_window.force_auto_center()
  ltnc.signals = signals
  return ltnc
end -- create_window()

--------------------------
-- Event registration
--------------------------

ltnc_gui.RegisterHandlers()
ltnc_gui.RegisterTemplates()

event.on_init(function()
  gui.init()
  gui.build_lookup_tables()
  --global.network_icons = global.network_icons or {}
end)

event.on_load(function()
  gui.build_lookup_tables()
end)

event.register(defines.events.on_gui_opened, function(e)
  if gui.dispatch_handlers(e) then return end
  if not (e.entity and e.entity.valid) then return end
  if e.entity.name == "ltn-combinator" then
    ltnc_gui.Open(e.player_index, e.entity)
  else
    ltnc_gui.Close(e.player_index)
  end
end)

event.register({"ltnc-close", "ltnc-escape"}, function(e)
  ltnc_gui.Close(e.player_index)
end)

return ltnc_gui