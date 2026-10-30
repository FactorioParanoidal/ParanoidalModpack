local util = require("util")

-- Energy fields of inserters are joules; any SI magnitude (k, M, ...) is accepted.
local function scale_energy(energy, factor)
  local joules = util.parse_energy(energy)
  return string.format("%dJ", math.ceil(joules * factor / 5) * 5)
end
--
local function change_sprite_scale(sprite, scale)
  if not sprite then
    return
  end
  sprite.scale = (sprite.scale or 1) * scale
  return sprite
end
--
local function calculate_performance(entity, wide, forced_ips)
  local performance = {
    rotation_speed = 1 / 60,
    extension_speed = 1 / 60,
    stack_size_bonus = 50,
    energy_per_movement = entity.energy_per_movement,
    energy_per_rotation = entity.energy_per_rotation
  }
  -- Researched hand size of the source: bulk inserters get up to +11, others +2.
  local old_stack_size = 1 + (entity.stack_size_bonus or 0)
  if entity.bulk then
    old_stack_size = old_stack_size + 11
  else
    old_stack_size = old_stack_size + 2
  end
  --log("old_stack_size: " .. tostring(old_stack_size))
  --log("entity.rotation_speed_tick: " .. tostring(entity.rotation_speed))
  --log("rotation_speed_sec: " .. tostring(entity.rotation_speed * 60))
  performance._ips_old = entity.rotation_speed * 60 * old_stack_size
  performance._ips_new = forced_ips or (((wide and 16) or 4.5) * performance._ips_old)
  local max_stack_size_bonus = 250
  local stack_limit_setting = settings.startup["nco-inserter-cranes-max-stack-size-bonus"]
  if stack_limit_setting and stack_limit_setting.value then
    max_stack_size_bonus = tonumber(stack_limit_setting.value)
  end
  local new_stack_size_bonus = math.min(max_stack_size_bonus, math.floor(performance._ips_new / 25 + 0.5) * 25)
  performance._new_speed_sec = performance._ips_new / new_stack_size_bonus
  performance.rotation_speed = math.floor(10000 * performance._new_speed_sec / 60) / 10000
  performance.extension_speed = math.floor(10000 * performance._new_speed_sec / 60) / 10000
  performance.stack_size_bonus = math.max(0, new_stack_size_bonus - 1 - 2)
  local energy_scale = (new_stack_size_bonus/max_stack_size_bonus) * (entity.rotation_speed/performance.rotation_speed) * ((wide and 16) or 4.5) * 1.75
  performance.energy_per_movement = scale_energy(performance.energy_per_movement, energy_scale)
  performance.energy_per_rotation = scale_energy(performance.energy_per_rotation, energy_scale)
  return performance
end

local function make_crane_entity(entityName, newName, wide, forced_ips)
  local entity = util.table.deepcopy(data.raw["inserter"][entityName])
  --log(serpent.block(entity))
  entity.name = newName
  if entity.filter_count and entity.filter_count < 5 then
    entity.filter_count = entity.filter_count + 1
  end
  entity.minable = {mining_time = 0.5, result = newName}

  entity.collision_box = {{-0.8, -0.8}, {0.8, 0.8}}
  entity.selection_box = {{-1, -1}, {1, 1}}
  if wide then
    entity.collision_box = {{-2.8, -0.8}, {2.8, 0.8}}
    entity.selection_box = {{-3, -1}, {3, 1}}
  end
  local entity_performance = calculate_performance(entity, wide, forced_ips)
  -- Cranes have their own hand size and take only the ordinary inserter capacity research.
  entity.bulk = false
  entity.next_upgrade = nil
  entity.extension_speed = entity_performance.extension_speed
  entity.rotation_speed = entity_performance.rotation_speed
  entity.stack_size_bonus = entity_performance.stack_size_bonus
  entity.energy_per_movement = entity_performance.energy_per_movement
  entity.energy_per_rotation = entity_performance.energy_per_rotation

  entity.pickup_position = {0.5, -1.7}
  entity.insert_position = {-0.5, 1.7}
  entity.allow_custom_vectors = true
  --hand
  entity.hand_size = 1.5
  entity.hand_base_picture = change_sprite_scale(entity.hand_base_picture, 2)
  entity.hand_base_shadow = change_sprite_scale(entity.hand_base_shadow, 2)

  entity.hand_closed_picture = change_sprite_scale(entity.hand_closed_picture, 1.25)
  entity.hand_closed_shadow = change_sprite_scale(entity.hand_closed_shadow, 1.25)

  entity.hand_open_picture = change_sprite_scale(entity.hand_open_picture, 1.5)
  entity.hand_open_shadow = change_sprite_scale(entity.hand_open_shadow, 1.5)
  --platform
  -- if individual picures are used there is no ground texture (yet)
  entity.platform_picture.north = change_sprite_scale(entity.platform_picture.north, 1.8)
  entity.platform_picture.east = change_sprite_scale(entity.platform_picture.east, 1.8)
  entity.platform_picture.south = change_sprite_scale(entity.platform_picture.south, 1.8)
  entity.platform_picture.west = change_sprite_scale(entity.platform_picture.west, 1.8)
  entity.localised_name = nil
  local newSheets = {}
  if entity.platform_picture.sheets then
    for _, v in pairs(entity.platform_picture.sheets) do
      table.insert(newSheets, change_sprite_scale(v, 1.8))
    end
  elseif entity.platform_picture.sheet then
    newSheets = {change_sprite_scale(entity.platform_picture.sheet, 1.8)}
    entity.platform_picture.sheet = nil
  end

  if #newSheets > 0 then
    entity.platform_picture.sheets = {}
    if wide then
      table.insert(
        entity.platform_picture.sheets,
        {
          filename = "__nco-InserterCranes__/graphics/ground_texture_4way.png",
          priority = "extra-high",
          width = 768,
          height = 768,
          shift = {0, 0},
          scale = 0.25
        }
      )
    end

    for _, v in pairs(newSheets) do
      table.insert(entity.platform_picture.sheets, v)
    end
  end
  --log(newName .. ": " ..serpent.block(entity))
  data:extend({entity})
end

return make_crane_entity
