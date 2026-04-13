local PTlib = require("lib.PTlib")
local cfg2 = require("config.config-2")



local PTrender = {}


--
-- Local Variables
--
local cfgR = {}

-- Initial setting of frequently used variables and constants
local function init_settings()
  cfgR = {
    range_disable = settings.global[cfg2.mod_prefix .. "range-force-disable"].value,
  }
  cfgR.set = true
end

local function is_PT_name(name)
  if name:match(cfg2.PT_ptrn) then
    return true
  end
  return false
end

local function is_PT_upper_name(name)
  if name:match(cfg2.PT_upper_ptrn) then
    return true
  end
  return false
end

local function is_PT_cursor_stack(player)
  local pcs = player.cursor_stack
  local pcg = player.cursor_ghost
  if pcs and pcs.valid_for_read and pcs.valid and is_PT_name(pcs.name) then
    return true
  elseif pcg and is_PT_name(pcg.name.name) then   -- Weird!  But 2.0.15 needs this change to work
    return true
  end
end

local function match_players(players, player, remove)
  if not players then return false, {} end
  for k, v in pairs(players) do
    if v == player then
      if remove then table.remove(players, k) end
      return true, players
    end
  end
  return false, players
end


--
-- Main Rendering functions
--
function PTrender.remove_rectangle(enty)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_objects(cfg2.PT_mod_name)
  local target
  for _, rect in pairs(rects) do
    if rect.valid and rect.type == "rectangle" then
      target = rect.left_top
      if target.entity == enty then
        rect.destroy()
      end
    end
  end
end

function PTrender.hide_rectangle(enty, player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_objects(cfg2.PT_mod_name)
  local target
  local match
  local players
  for _, rect in pairs(rects) do
    if rect.valid and rect.type == "rectangle" then
      target = rect.left_top
      if target.entity == enty then
        -- PTlib.debugprint("Match uid : " .. rect.id .. ", checking...")
        if rect.visible then
          match, players = match_players(rect.players, player, true)
          if match then
            -- PTlib.debugprint("Match uid : " .. rect.id .. ", hid " .. player.name .. ".")
            rect.players = players
          end
          -- if next(players) == nil then
          if not rect.players or #rect.players == 0 then
            -- PTlib.debugprint("Match uid : " .. rect.id .. ", now invisible.")
            rect.visible = false
          end
        else
          -- PTlib.debugprint("Match uid : " .. rect.id .. ", already invisible.")
        end
      end
    end
  end
end

function PTrender.add_rectangle(enty, player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_objects(cfg2.PT_mod_name)
  local target
  local found = false
  for _, rect in pairs(rects) do
    if rect.valid and rect.type == "rectangle" then
      target = rect.left_top
      if target.entity == enty then
        -- Existing rect found, no need to create new
        found = true
        return
      end
    end
  end
  if not found then
    -- No rect found, create new
    local radius = tonumber(enty.name:match(cfg2.PT_radius_ptrn))
    local offset = {{-radius, -radius}, { radius,  radius}}
    local rect = rendering.draw_rectangle{color=cfg2.PT_rect_color, filled=true, left_top={entity=enty, offset=offset[1]}, right_bottom={entity=enty, offset=offset[2]}, surface=enty.surface, players={}, draw_on_ground=true, visible=false}
      -- PTlib.debugprint("Create new uid : " .. rect.id .. ".")
    if player and player.mod_settings[cfg2.mod_prefix .. "range-show"].value and is_PT_cursor_stack(player) then
      -- table.insert(rect.players, player)
      rect.players = {player}
      rect.visible = true
    end
    -- PTlib.debugprint("Rect type: \"" .. rect.type .. "\"  uid : " .. rect.id)
  end
end

function PTrender.show_rectangle(enty, player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_objects(cfg2.PT_mod_name)
  local target
  local found = false
  local match
  local players
  for _, rect in pairs(rects) do
    if rect.valid and rect.type == "rectangle" then
      target = rect.left_top
      if target.entity == enty then
        -- Existing rect found, no need to create new
        found = true
        if rect.visible then
          match, players = match_players(rect.players, player, false)
          if match then
            -- PTlib.debugprint("Match uid : " .. rect.id .. ", already has " .. player.name .. ".")
          else
            -- PTlib.debugprint("Match uid : " .. rect.id .. ", inserted " .. player.name .. ".")
            if rect.players then
              table.insert(rect.players, player)
            else
              rect.players = {player}
            end
          end
        else
          -- PTlib.debugprint("Match uid : " .. rect.id .. ", now visible.")
          rect.players = {player}
          rect.visible = true
        end
      end
    end
  end
  if not found then
    -- No rect found, create new
    PTrender.add_rectangle(enty, player)
  end
end


--
-- General Rendering calls
--
function PTrender.hide_all_rectangles(player)
  -- if not cfgR.set then init_settings() end
  -- if cfgR.range_disable then return end
  local rects = rendering.get_all_objects(cfg2.PT_mod_name)
  local target
  local match
  local players
  for _, rect in pairs(rects) do
    if rect.valid and rect.type == "rectangle" then
      if rect.visible then
        match, players = match_players(rect.players, player, true)
        if match then
          -- PTlib.debugprint("Match uid : " .. rect.id .. ", hid " .. player.name .. ".")
          rect.players = players
        end
        -- if next(players) == nil then
        if not rect.players or #rect.players == 0 then
          -- PTlib.debugprint("Match uid : " .. rect.id .. ", now invisible.")
          rect.visible = false
        end
      else
        -- PTlib.debugprint("Match uid : " .. rect.id .. ", already invisible.")
      end
    end
  end
end

function PTrender.show_all_rectangles(player)
  -- if not cfgR.set then init_settings() end
  -- if cfgR.range_disable then return end
  local rects = rendering.get_all_objects(cfg2.PT_mod_name)
  local target
  local match
  local players
  for _, rect in pairs(rects) do
    if rect.valid and rect.type == "rectangle" then
      target = rect.left_top
      if target.entity.force == player.force then
        -- Existing rect found, no need to create new
        if rect.visible then
          match, players = match_players(rect.players, player, false)
          if match then
            -- PTlib.debugprint("Match uid : " .. id .. ", already has " .. player.name .. ".")
          else
            -- PTlib.debugprint("Match uid : " .. id .. ", inserted " .. player.name .. ".")
            table.insert(rect.players, player)
          end
        else
          -- PTlib.debugprint("Match uid : " .. id .. ", now visible.")
          rect.players = {player}
          rect.visible = true
        end
      end
    end
  end
end

function PTrender.selection_changed(player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not player.mod_settings[cfg2.mod_prefix .. "range-show"].value then return end
  local selection = player.selected
  if selection and selection.valid and is_PT_name(selection.name) and not is_PT_upper_name(selection.name) then
    PTrender.add_rectangle(selection, player)
  end
end

function PTrender.cursor_changed(player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not player.mod_settings[cfg2.mod_prefix .. "range-show"].value then return end
  if is_PT_cursor_stack(player) then
    -- PTlib.debugprint("Tower found : " .. selection.name .. "  Radius: " .. pickupradius)
    PTrender.show_all_rectangles(player)
  else
    PTrender.hide_all_rectangles(player)
  end
end


--
-- Multiple Rendering calls
--
function PTrender.clear_rendering()
  rendering.clear(cfg2.PT_mod_name)
  -- PTlib.debugprint("Removed all render objects")
end

function PTrender.update_legacy()
  -- Update possible legacy Rendering left by former versions
  local rects = rendering.get_all_objects(cfg2.PT_mod_name)
  local target
  local match
  local players
  for _, rect in pairs(rects) do
    if rect.valid and rect.type == "rectangle" then
      target = rect.left_top
      if not target.entity or not target.entity.valid then
        -- PTlib.debugprint("No target uid : " .. rect.id .. ", removed.")
        rect.destroy()
      else
        rect.color = cfg2.PT_rect_color
      end
    end
  end
end

function PTrender.init()
  init_settings()
end



return PTrender