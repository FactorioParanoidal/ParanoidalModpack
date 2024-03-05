local event = require("__flib__.event")
local table = require("__flib__.table")
local vivid = require("lib.vivid")

local constants = require("constants")
local visualizer = require("scripts.visualizer")

--- @param player_index number
local function init_player(player_index)
  --- @class PlayerTable
  global.players[player_index] = {
    enabled = false,
    --- @type table<number, number[]>
    entity_objects = {},
    --- @type table<number, Color>
    fluid_system_colors = {},
    fluid_system_color_index = 0,
    hovered = false,
    hover_enabled = false,
    --- @type constants.modes
    mode = constants.modes.fluid,
    --- @type MapPosition?
    last_position = nil,
    --- @type number
    overlay = nil,
    --- @type BoundingBox
    overlay_area = nil,
  }
end

local function generate_fluid_colors()
  --- @type table<string, Color>
  local colors = {}
  for name, fluid in pairs(game.fluid_prototypes) do
    local h, s, v, a = vivid.RGBtoHSV(fluid.base_color)
    v = math.max(v, 0.8)
    local r, g, b, a = vivid.HSVtoRGB(h, s, v, a)
    colors[name] = { r = r, g = g, b = b, a = a }
  end
  global.fluid_colors = colors
end

--- @param to_walk LuaEntity[]
--- @param entities table<number, LuaEntity>
--- @param fluid_system_id number
local function walk_fluid_system(to_walk, entities, fluid_system_id)
  local to_walk_next = {}
  for _, entity in pairs(to_walk) do
    local unit_number = entity.unit_number
    if not entities[unit_number] then
      entities[unit_number] = entity
      local fluidbox = entity.fluidbox
      for fluidbox_index = 1, #fluidbox do
        if fluidbox.get_fluid_system_id(fluidbox_index) == fluid_system_id then
          for _, connection in pairs(fluidbox.get_connections(fluidbox_index)) do
            local neighbour = connection.owner
            to_walk_next[neighbour.unit_number] = neighbour
          end
        end
      end
    end
  end
  return to_walk_next
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
local function toggle_hover(player, player_table)
  player_table.hover_enabled = not player_table.hover_enabled
  player.set_shortcut_toggled("pv-toggle-hover", player_table.hover_enabled)
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
local function toggle_overlay(player, player_table)
  if player_table.hovered then
    return
  end
  if player_table.enabled then
    visualizer.destroy(player, player_table)
  else
    visualizer.create(player, player_table)
  end
  player.set_shortcut_toggled("pv-toggle-overlay", player_table.enabled)
end

event.on_init(function()
  --- @type table<number, PlayerTable>
  global.players = {}

  generate_fluid_colors()

  for player_index in pairs(game.players) do
    init_player(player_index)
  end
end)

event.on_configuration_changed(function()
  generate_fluid_colors()
end)

event.on_player_created(function(e)
  init_player(e.player_index)
end)

event.register("pv-toggle-hover", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  toggle_hover(player, player_table)
end)

event.register("pv-toggle-overlay", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  toggle_overlay(player, player_table)
end)

event.on_lua_shortcut(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  if e.prototype_name == "pv-toggle-hover" then
    toggle_hover(player, player_table)
  elseif e.prototype_name == "pv-toggle-overlay" then
    toggle_overlay(player, player_table)
  end
end)

event.on_player_changed_position(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  if player_table and player_table.enabled then
    local last_position = player_table.last_position
    local position = player.position
    local floored_position = {
      x = math.floor(position.x),
      y = math.floor(position.y),
    }
    if floored_position.x ~= last_position.x or floored_position.y ~= last_position.y then
      visualizer.update(player, player_table)
    end
  end
end)

event.on_selected_entity_changed(function(e)
  local player_table = global.players[e.player_index]
  if not player_table or not player_table.enabled then
    local player = game.get_player(e.player_index)
    local selected = player.selected
    if selected and constants.type_to_shape[selected.type] then
      if player_table.entity_objects[selected.unit_number] then
        return
      end
      local fluidbox = selected.fluidbox
      if not fluidbox or #fluidbox == 0 then
        return
      end
      if player_table.hovered then
        visualizer.destroy(player, player_table)
      end
      if not player_table.hover_enabled then
        return
      end
      player_table.hovered = true

      -- Iterate all entities in each fluid system
      local entities = {}
      local fluid_system_ids = {}
      local fluidbox = selected.fluidbox
      for fluidbox_index = 1, #fluidbox do
        local fluid_system_id = fluidbox.get_fluid_system_id(fluidbox_index)
        if fluid_system_id then
          fluid_system_ids[fluid_system_id] = true
          local to_walk = table.map(fluidbox.get_connections(fluidbox_index), function(fluidbox)
            return fluidbox.owner
          end)
          while next(to_walk) do
            to_walk = walk_fluid_system(to_walk, entities, fluid_system_id)
          end
        end
      end
      visualizer.draw_entities(player, player_table, entities, { fluid_system_ids = fluid_system_ids })
    elseif player_table.hovered then
      player_table.hovered = false
      visualizer.destroy(player, player_table)
    end
  end
end)

event.on_gui_switch_state_changed(function(e)
  local player_table = global.players[e.player_index]
  if player_table and player_table.enabled then
    local element = e.element
    if element and element.valid and element.name == "pv_mode_switch" then
      player_table.mode = element.switch_state == "left" and constants.modes.fluid or constants.modes.system
      local player = game.get_player(e.player_index)
      visualizer.destroy(player, player_table)
      visualizer.create(player, player_table)
    end
  end
end)
