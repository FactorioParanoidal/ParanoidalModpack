local math = require("__flib__.math")

local config = require("script.config")
local flib_box = require("__flib__.bounding-box")
local table = require("__flib__.table")
local migration = require("__flib__.migration")

local M = {}

-- Needed a variable to hide a nil param from the language server :/
---@type Signal
M.nilSignal = nil

function M.debug_log(expr)
  if not __DebugAdapter then
    return
  end

  __DebugAdapter.print(expr)
end

---Set slider value and stacks textbox value from the items text box
---@param player LuaPlayer
function M.from_items(player)
  ---@type WorkingSlot
  local ws = storage.players[player.index].working_slot
  local value = tonumber(ws.items.text) --[[@as number]]
  if not value then
    return
  end

  ws.stacks.text = tostring(value / ws.stack_size)
  ws.slider.slider_value = math.abs(value)
end -- M.from_items()

---Set slider value and stacks textbox value from the items text box
---@param player LuaPlayer
function M.from_stacks(player)
  ---@type WorkingSlot
  local ws = storage.players[player.index].working_slot
  local value = tonumber(ws.stacks.text)
  if not value then
    return
  end

  value = math.clamp(value * ws.stack_size, math.min_int, math.max_int)
  value = value < 0 and math.ceiled(value, ws.stack_size) or  math.floored(value, ws.stack_size)
  ws.items.text = tostring(value)
  ws.items.style = "ltnc_entry_text"
  ws.slider.slider_value = math.abs(value)
end -- M.from_stacks()

---Set slider value and stacks textbox value from the items text box
---@param player LuaPlayer
function M.from_slider(player)
  ---@type WorkingSlot
  local ws = storage.players[player.index].working_slot
  local value = ws.slider.slider_value
  ws.stacks.text = tostring(value / ws.stack_size)
  ws.items.text = tostring(value)
  ws.items.style = "ltnc_entry_text"
end --M.from_slider()

---Encode the Network ID from the buttons that are enabled
---@param player LuaPlayer @ Player operating the combinator
function M.from_netid_buttons(player)
  local pt = storage.players[player.index]
  local netid_textbox = pt.main_elems["text_entry__ltn-network-id"]
  local netid_buttons = pt.main_elems.net_encode_table
  local netid = 0
  for i = 1, 31 do
    if netid_buttons.children[i].style.name == "ltnc_net_id_button_pressed" then
      netid = netid + 2^(i-1)
    end
  end
  if netid_buttons.children[32].style.name == "ltnc_net_id_button_pressed" then
    netid = netid - 2^(31)
  end
  netid_textbox.text = tostring(netid)
end -- M.from_netid_buttons()

---Check if the entered value is within bounds
---@param name LTNSignals
---@param value number? @ Value attempting to write to combinator.  nil is valid
---@return boolean @ True if valid setting for the combinator
function M.is_valid(name, value)
  if not value then return true end
  local signal = config.ltn_signals[name]
  return value >= signal.min and value <= signal.max
end

--- @param player LuaPlayer
--- @return (LuaItemStack|LuaRecord)?
function M.get_blueprint(player)
  local bp = player.blueprint_to_setup
  if bp
  and bp.valid_for_read then
    return bp
  end

  bp = player.cursor_stack
  if bp
  and bp.valid_for_read then
    while bp.type == "blueprint-book" do
      bp = bp.get_inventory(defines.inventory.item_main)[bp.active_index]
    end

    return bp
  end
  
  bp = player.cursor_record
  if bp then
    if not migration.is_newer_version("2.0.34", script.active_mods["base"])
    and bp.type == "blueprint-book" then
      game.print("Factorio version 2.0.35 required for this to work properly.  Please copy BP book to your inventory, or select the specific BP from your book.")
      return
    end

    while bp.type == "blueprint-book" do
      bp = bp.get_selected_record(player)
    end

    return bp
  end

  local prev_bp = storage.previous_opened_blueprint_for[player.index]
  if prev_bp
  and prev_bp.tick == game.tick
  and prev_bp.blueprint
  and prev_bp.blueprint.valid_for_read
  and prev_bp.blueprint.is_blueprint_setup()
  then
    return prev_bp.blueprint
  end
end

---@param entities BlueprintEntity[] # E.g. from LuaPlayer.get_blueprint_entities()
---@return BoundingBox # Box that contains all blueprint entities
---@return uint # The building grid size needed to build this blueprint
function M.get_blueprint_bounding_box(entities)
  local box = flib_box.from_position(entities[1].position, true)
  local names = {}
  for _, e in ipairs(entities) do
    names[e.name] = true
  end

  local name_filter = {}
  for k, _ in pairs(names) do
    table.insert(name_filter, k)
  end

  -- Define a bounding box the size of the blueprint to be placed
  local grid_size = 1
  ---@diagnostic disable-next-line:missing-fields
  local protos = prototypes.get_entity_filtered{{filter = "name", name = name_filter}}
  for _, entity in pairs(entities) do
    local collision_box = protos[entity.name].collision_box
    grid_size = math.max(grid_size, protos[entity.name].building_grid_bit_shift)
    box = flib_box.expand_to_contain_box(
      box,
      flib_box.from_dimensions(
        entity.position,
        flib_box.width(collision_box),
        flib_box.height(collision_box)
      )
    )
  end

  -- Expand bounding box to be full tiles based on the entity with the largest building grid size
  box.left_top.x = grid_size * math.floor(box.left_top.x / grid_size)
  box.left_top.y = grid_size * math.floor(box.left_top.y / grid_size)
  box.right_bottom.x = grid_size * math.ceil(box.right_bottom.x / grid_size)
  box.right_bottom.y = grid_size * math.ceil(box.right_bottom.y / grid_size)
  return box, grid_size
end


---@param box BoundingBox # Bounding box of blueprint to place
---@param pos MapPosition # Position to center new bounding box around
---@param grid_size uint? # Building grid size to base centering.  Default: 1
---@return MapPosition # Center position of new bounding box
function M.get_placed_blueprint_center(box, pos, grid_size)
  local grid_size = grid_size or 1
  local pos_x = pos.x or pos[1]
  local pos_y = pos.y or pos[2]
  pos_x = (flib_box.width(box) / grid_size) % 2 == 0
          and math.floor(pos_x / grid_size + .5 ) * grid_size
          or math.floor(pos_x / grid_size) * grid_size + grid_size / 2
  pos_y = (flib_box.height(box) / grid_size) % 2 == 0
          and math.floor(pos_y / grid_size + .5 ) * grid_size
          or math.floor(pos_y / grid_size) * grid_size + grid_size / 2
  if pos.x then
    return { x = pos_x, y = pos_y }
  else
    return { pos_x, pos_y }
  end
end

  --- Recursive function to find combinator up to <max_depth> connections away
  --- @param find_name string # The entity to look for
  --- @param start_list table<uint, LuaEntity> # List of entities to start search from
  --- @param max_depth uint # Max number of connections away to search (Poles are a connection)
  --- @return LuaEntity?
function M.find_connected_entity(find_name, start_list, max_depth)
  local seen = {}
  local walk_entities
  walk_entities = function(name, entity_list, depth)
    local next_entity_list = {}
    for unit, e in pairs(entity_list) do
      --- @cast e LuaEntity
      if e.name == name then
        -- We've found the closest entity <name>
        return e
      end

      -- Mark this entity as processed so we don't process it again.
      -- This it is seen on the next entity or if there are loops in the circuit network
      seen[unit] = true
      local connectors = e.get_wire_connectors(false)
      if not connectors then
        return
      end

      -- Outer loop get are the possible wire connections (red / green)
      for _, connector in pairs(connectors) do
        -- Inner loop works through all the adjacent entities on a network.
        for _, connection in ipairs(connector.connections) do
          if not seen[connection.target.owner.unit_number] then
            next_entity_list[connection.target.owner.unit_number] = connection.target.owner
          end
        end
      end
    end

    if depth == max_depth then
      -- Reached the maximum depth and did't find an LTN combinator.
      return
    end

    -- If there are more un-seen entities another connection away, recurse
    if next(next_entity_list) then
      return walk_entities(name, next_entity_list, depth + 1)
    end
  end

  return walk_entities(find_name, start_list, 0)
end

local shift = 0x1000000
local normalize = 1000000

--- Pack a position into 42 bits.  This will give plenty of space for
--- the fully possible factorio map of 2,000,000 x 2,000,000 tiles
--- with half tile resolution.
--- @param expr MapPosition
--- @return integer # Return 0 if not a valid coordinate
function M.pack_position(expr)
  local x = expr.x or expr[1]
  local y = expr.y or expr[2]
  if not x or not y then
    return 0
  end

  -- Normalize and double to handle positions in the middle of tiles
  x = (x + normalize) * 2
  y = (y + normalize) * 2
  -- Shift x coordinate to the high 24 bits (x << 24) + y
  return x * shift + y
end -- pack_position()

--- Unpack an integer representation of a tile location
--- @param posint integer
--- @return MapPosition # Return origin if posint == nil
function M.unpack_position(posint)
if not posint then
  return { x = 0, y = 0 }
end

return {
  x = math.floor(posint / shift) / 2 - normalize,
  y = math.floor(posint % shift) / 2 - normalize
}
end -- unpack_position()

return M
