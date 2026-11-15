-- Cursor fittings are made from the final ordinary pipe, not from an iron-pipe
-- template: material, fluid capacity, connections and graphics must survive R.
local copy = util.table.deepcopy
local shapes = {"elbow", "junction", "straight"}
local directions = {defines.direction.north, defines.direction.east,
  defines.direction.south, defines.direction.west}
local pictures = {
  elbow = {"corner_down_right", "corner_down_left", "corner_up_left", "corner_up_right"},
  junction = {"t_down", "t_left", "t_up", "t_right"},
  straight = {"straight_vertical", "straight_horizontal", "straight_vertical", "straight_horizontal"}
}
local ports = {elbow = {2, 3}, junction = {2, 3, 4}, straight = {1, 3}}
local registry = {families = {}, items = {}}
local additions = {}

local function ordinary_connections(pipe)
  local connections = pipe.fluid_box and pipe.fluid_box.pipe_connections
  if not connections or #connections ~= 4 then return end
  local result = {}
  for _, connection in ipairs(connections) do
    local position = connection.position
    if (connection.connection_type and connection.connection_type ~= "normal")
      or not position or (position[1] or position.x) ~= 0
      or (position[2] or position.y) ~= 0 then return end
    for i, direction in ipairs(directions) do
      if connection.direction == direction then
        if result[i] then return end
        result[i] = connection
      end
    end
  end
  for i = 1, 4 do if not result[i] then return end end
  if not pipe.pictures then return end
  for _, shape in ipairs(shapes) do
    for _, key in ipairs(pictures[shape]) do
      if not pipe.pictures[key] then return end
    end
  end
  return result
end

local names = {}
for name, item in pairs(data.raw.item) do
  if not item.hidden and item.place_result and data.raw.pipe[item.place_result]
    and not item.spoil_ticks then names[#names + 1] = name end
end
table.sort(names)

for _, base in ipairs(names) do
  local original_item = data.raw.item[base]
  local original = data.raw.pipe[original_item.place_result]
  local connections = ordinary_connections(original)
  if connections and not original.hidden and original.minable
    and original.minable.result == base and not original.minable.results
    and (original.minable.count or 1) == 1 then
    local family = {base}
    registry.items[base] = {base = base, shape = 0}
    for index, shape in ipairs(shapes) do
      local name = "flow-control-" .. base .. "-" .. shape
      local entity = copy(data.raw["storage-tank"]["pipe-" .. shape])
      entity.name = name
      entity.localised_name = {"flow-control-cursor." .. shape,
        original.localised_name or {"entity-name." .. original.name}}
      entity.localised_description = {"flow-control-cursor.description"}
      entity.minable = copy(original.minable or {mining_time = 0.1})
      entity.minable.results = nil
      entity.minable.result = base
      entity.placeable_by = {item = base, count = 1}
      entity.flags = copy(original.flags)
      entity.next_upgrade = nil
      for _, key in ipairs({"max_health", "resistances", "collision_box", "selection_box",
        "fast_replaceable_group", "corpse", "dying_explosion", "damaged_trigger_effect",
        "collision_mask", "heating_energy", "surface_conditions", "repair_speed_modifier",
        "healing_per_tick", "impact_category", "open_sound", "close_sound",
        "map_color", "friendly_map_color", "enemy_map_color", "se_allow_in_space"}) do
        entity[key] = copy(original[key])
      end
      entity.fluid_box = copy(original.fluid_box)
      entity.fluid_box.pipe_connections = {}
      for _, port in ipairs(ports[shape]) do
        local connection = copy(connections[port])
        connection.hide_connection_info = true
        entity.fluid_box.pipe_connections[#entity.fluid_box.pipe_connections + 1] = connection
      end
      entity.pictures.picture = {}
      for i, direction in ipairs({"north", "east", "south", "west"}) do
        entity.pictures.picture[direction] = copy(original.pictures[pictures[shape][i]])
      end
      -- Private cursor aliases also cover iron pipes: never normalize a player's
      -- separately crafted public fittings or change their existing mining option.
      local item = copy(original_item)
      item.name = name
      item.place_result = name
      item.localised_name = entity.localised_name
      item.localised_description = entity.localised_description
      item.hidden = true
      item.hidden_in_factoriopedia = true
      -- Physical 1:1 aliases, not disposable cursor tools or reserved stock.
      item.flags = {}
      for _, flag in ipairs(original_item.flags or {}) do
        if flag ~= "only-in-cursor" and flag ~= "primary-place-result" then
          item.flags[#item.flags + 1] = flag
        end
      end
      additions[#additions + 1] = item
      entity.hidden_in_factoriopedia = true
      additions[#additions + 1] = entity
      family[#family + 1] = name
      registry.items[name] = {base = base, shape = index}
    end
    registry.families[base] = family
  end
end
additions[#additions + 1] = {type = "mod-data", name = "flow-control-cursor", data = registry}
data:extend(additions)
