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
    range_disable = settings.global["pickuptower-range-force-disable"].value,
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
  elseif pcg and pcg.valid and is_PT_name(pcg.name) then
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
  local rects = rendering.get_all_ids(cfg2.PT_mod_name)
  local target
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if target.entity == enty then
        -- PTlib.debugprint("Match uid : " .. id .. ", removed.")
        rendering.destroy(id)
      end
    end
  end
end

function PTrender.hide_rectangle(enty, player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_ids(cfg2.PT_mod_name)
  local target
  local match
  local players
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if target.entity == enty then
        -- PTlib.debugprint("Match uid : " .. id .. ", checking...")
        if rendering.get_visible(id) then
          match, players = match_players(rendering.get_players(id), player, true)
          if match then
            -- PTlib.debugprint("Match uid : " .. id .. ", hid " .. player.name .. ".")
            rendering.set_players(id, players)
          end
          -- if next(players) == nil then
          if #players == 0 then
            -- PTlib.debugprint("Match uid : " .. id .. ", now invisible.")
            rendering.set_visible(id, false)
          end
        else
          -- PTlib.debugprint("Match uid : " .. id .. ", already invisible.")
        end
      end
    end
  end
end

function PTrender.add_rectangle(enty, player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_ids(cfg2.PT_mod_name)
  local target
  local found = false
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if target.entity == enty then
        -- Existing rect found, no need to create new
        found = true
      end
    end
  end
  if not found then
    -- No rect found, create new
    local radius = tonumber(enty.name:match(cfg2.PT_radius_ptrn))
    local offset = {{-radius, -radius}, { radius,  radius}}
    local id
    if player and player.mod_settings["pickuptower-range-show"].value and is_PT_cursor_stack(player) then
      id = rendering.draw_rectangle{color=cfg2.PT_rect_color, filled=true, left_top=enty, right_bottom=enty, left_top_offset=offset[1], right_bottom_offset=offset[2], surface=enty.surface, players={player}, draw_on_ground=true, visible=true}
      -- PTlib.debugprint("Create new uid : " .. id .. ", for " .. player.name .. ".")
    else
      id = rendering.draw_rectangle{color=cfg2.PT_rect_color, filled=true, left_top=enty, right_bottom=enty, left_top_offset=offset[1], right_bottom_offset=offset[2], surface=enty.surface, players={}, draw_on_ground=true, visible=false}
      -- PTlib.debugprint("Create new uid : " .. id .. ".")
    end
    -- PTlib.debugprint("Rect type: \"" .. rendering.get_type(uid) .. "\"  uid : " .. id)
  end
end

function PTrender.show_rectangle(enty, player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not enty or not enty.valid then return end
  local rects = rendering.get_all_ids(cfg2.PT_mod_name)
  local target
  local found = false
  local match
  local players
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if target.entity == enty then
        -- Existing rect found, no need to create new
        found = true
        if rendering.get_visible(id) then
          match, players = match_players(rendering.get_players(id), player, false)
          players = rendering.get_players(id)
          if match then
            -- PTlib.debugprint("Match uid : " .. id .. ", already has " .. player.name .. ".")
          else
            -- PTlib.debugprint("Match uid : " .. id .. ", inserted " .. player.name .. ".")
            table.insert(players, player)
            rendering.set_players(id, players)
          end
        else
          -- PTlib.debugprint("Match uid : " .. id .. ", now visible.")
          rendering.set_players(id, {player})
          rendering.set_visible(id, true)
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
  local rects = rendering.get_all_ids(cfg2.PT_mod_name)
  local target
  local match
  local players
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      if rendering.get_visible(id) then
        match, players = match_players(rendering.get_players(id), player, true)
        if match then
          -- PTlib.debugprint("Match uid : " .. id .. ", hid " .. player.name .. ".")
          rendering.set_players(id, players)
        end
        -- if next(players) == nil then
        if #players == 0 then
          -- PTlib.debugprint("Match uid : " .. id .. ", now invisible.")
          rendering.set_visible(id, false)
        end
      else
        -- PTlib.debugprint("Match uid : " .. id .. ", already invisible.")
      end
    end
  end
end

function PTrender.show_all_rectangles(player)
  -- if not cfgR.set then init_settings() end
  -- if cfgR.range_disable then return end
  local rects = rendering.get_all_ids(cfg2.PT_mod_name)
  local target
  local match
  local players
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if target.entity.force == player.force then
        -- Existing rect found, no need to create new
        if rendering.get_visible(id) then
          match, players = match_players(rendering.get_players(id), player, false)
          players = rendering.get_players(id)
          if match then
            -- PTlib.debugprint("Match uid : " .. id .. ", already has " .. player.name .. ".")
          else
            -- PTlib.debugprint("Match uid : " .. id .. ", inserted " .. player.name .. ".")
            table.insert(players, player)
            rendering.set_players(id, players)
          end
        else
          -- PTlib.debugprint("Match uid : " .. id .. ", now visible.")
          rendering.set_players(id, {player})
          rendering.set_visible(id, true)
        end
      end
    end
  end
end

function PTrender.selection_changed(player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not player.mod_settings["pickuptower-range-show"].value then return end
  local selection = player.selected
  if selection and selection.valid and is_PT_name(selection.name) and not is_PT_upper_name(selection.name) then
    PTrender.add_rectangle(selection, player)
  end
end

function PTrender.cursor_changed(player)
  if not cfgR.set then init_settings() end
  if cfgR.range_disable then return end
  if not player.mod_settings["pickuptower-range-show"].value then return end
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
  local rects = rendering.get_all_ids(cfg2.PT_mod_name)
  local target
  local match
  local players
  for _, id in pairs(rects) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      target = rendering.get_left_top(id)
      if not target.entity or not target.entity.valid then
        -- PTlib.debugprint("No target uid : " .. id .. ", removed.")
        rendering.destroy(id)
      else
        rendering.set_color(id, cfg2.PT_rect_color)
      end
    end
  end
end

function PTrender.init()
  init_settings()
end



return PTrender