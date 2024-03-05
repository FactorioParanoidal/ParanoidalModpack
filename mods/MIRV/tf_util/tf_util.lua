local util = require("util")

local is_sprite_def = function(array)
  return array.width and array.height and (array.filename or array.stripes or array.filenames)
end

util.is_sprite_def = is_sprite_def

local recursive_hack_scale
recursive_hack_scale = function(array, scale)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite_def(v) then
        v.scale = (v.scale or 1) * scale
        if v.shift then
          v.shift[1], v.shift[2] = v.shift[1] * scale, v.shift[2] * scale
        end
      end
      if v.source_offset then
        v.source_offset[1] = v.source_offset[1] * scale
        v.source_offset[2] = v.source_offset[2] * scale
      end
      if v.projectile_center then
        v.projectile_center[1] = v.projectile_center[1] * scale
        v.projectile_center[2] = v.projectile_center[2] * scale
      end
      if v.projectile_creation_distance then
        v.projectile_creation_distance = v.projectile_creation_distance * scale
      end
      recursive_hack_scale(v, scale)
    end
  end
end
util.recursive_hack_scale = recursive_hack_scale

local recursive_hack_animation_speed
recursive_hack_animation_speed = function(array, scale)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite_def(v) then
        v.animation_speed = v.animation_speed * scale
      end
      recursive_hack_animation_speed(v, scale)
    end
  end
end
util.recursive_hack_animation_speed = recursive_hack_animation_speed

local recursive_hack_tint
recursive_hack_tint = function(array, tint, check_runtime)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite_def(v) then
        if not check_runtime or v.apply_runtime_tint then
          v.tint = tint
          v.apply_runtime_tint = false
          if v.hr_version then
            v.hr_version.apply_runtime_tint = false
            v.hr_version.tint = tint
          end
        end
      end
      recursive_hack_tint(v, tint, check_runtime)
    end
  end
end
util.recursive_hack_tint = recursive_hack_tint

local recursive_hack_make_hr
recursive_hack_make_hr = function(prototype)
  for k, v in pairs (prototype) do
    if type(v) == "table" then
      if is_sprite_def(v) and v.hr_version then
        prototype[k] = v.hr_version
        --v.scale = v.scale * 0.5
        v.hr_version = nil
      end
      recursive_hack_make_hr(v)
    end
  end
end
util.recursive_hack_make_hr = recursive_hack_make_hr

util.scale_box = function(box, scale)
  box[1][1] = box[1][1] * scale
  box[1][2] = box[1][2] * scale
  box[2][1] = box[2][1] * scale
  box[2][2] = box[2][2] * scale
  return box
end

util.scale_boxes = function(prototype, scale)
  for k, v in pairs {"collision_box", "selection_box"} do
    local box = prototype[v]
    if box then
      local width = (box[2][1] - box[1][1]) * (scale / 2)
      local height = (box[2][2] - box[1][2]) * (scale / 2)
      local x = (box[1][1] + box[2][1]) / 2
      local y = (box[1][2] + box[2][2]) / 2
      box[1][1], box[2][1] = x - width, x + width
      box[1][2], box[2][2] = y - height, y + height
    end
  end
end

util.remove_flag = function(prototype, flag)
  if not prototype.flags then return end
  for k, v in pairs (prototype.flags) do
    if v == flag then
      table.remove(prototype.flags, k)
      break
    end
  end
end

util.has_flag = function(prototype, flag)
  if not prototype.flags then return false end
  for k, v in pairs (prototype.flags) do
    if v == flag then
      return true
    end
  end
end

util.add_flag = function(prototype, flag)
  if not prototype.flags then return end
  table.insert(prototype.flags, flag)
end

util.base_player = function()

  local player = util.table.deepcopy(data.raw.player.player or error("Wat man cmon why"))
  player.ticks_to_keep_gun = (600)
  player.ticks_to_keep_aiming_direction = (100)
  player.ticks_to_stay_in_combat = (600)
  util.remove_flag(player, "not-flammable")
  return player
end

util.path = function(str)
  return "__MIRV__/" .. str
end

util.empty_sound = function()
  return
  {
    filename = util.path("tf_util/empty-sound.ogg"),
    volume = 0
  }
end

util.empty_sprite = function()
  return
  {
    filename = util.path("tf_util/empty-sprite.png"),
    height = 1,
    width = 1,
    frame_count = 1,
    direction_count = 1
  }
end

util.damage_type = function(name)
  if not data.raw["damage-type"][name] then
    data:extend{{type = "damage-type", name = name, localised_name = {name}}}
  end
  return name
end

util.ammo_category = function(name)
  if not data.raw["ammo-category"][name] then
    data:extend{{type = "ammo-category", name = name, localised_name = {name}}}
  end
  return name
end

util.base_gun = function(name)
  return
  {
    name = name,
    localised_name = {name},
    type = "gun",
    stack_size = 10,
    flags = {}
  }
end

util.base_ammo = function(name)
  return
  {
    name = name,
    localised_name = {name},
    type = "ammo",
    stack_size = 10,
    magazine_size = 1,
    flags = {}
  }
end

local base_speed = 0.25
util.speed = function(multiplier)
  return multiplier * (base_speed)
end

util.remove_from_list = function(list, name)
  local remove = table.remove
  for i = #list, 1, -1 do
    if list[i] == name then
      remove(list, i)
    end
  end
end

local recursive_hack_something
recursive_hack_something = function(prototype, key, value)
  for k, v in pairs (prototype) do
    if type(v) == "table" then
      recursive_hack_something(v, key, value)
    end
  end
  prototype[key] = value
end
util.recursive_hack_something = recursive_hack_something

local recursive_hack_blend_mode
recursive_hack_blend_mode = function(prototype, value)
  for k, v in pairs (prototype) do
    if type(v) == "table" then
      if util.is_sprite_def(v) then
        v.blend_mode = value
      end
      recursive_hack_blend_mode(v, value)
    end
  end
end

local recursive_hack_runtime_tint
recursive_hack_runtime_tint = function(prototype, value)
  for k, v in pairs (prototype) do
    if type(v) == "table" then
      if util.is_sprite_def(v) then
        v.apply_runtime_tint = value
        if v.hr_version then
          v.hr_version.apply_runtime_tint = value
        end
      end
      recursive_hack_runtime_tint(v, value)
    end
  end
end
util.recursive_hack_runtime_tint = recursive_hack_runtime_tint

util.copy = util.table.deepcopy

--util.prototype = require("data/tf_util/prototype_util")

util.flying_unit_collision_mask = function()
  return {"not-colliding-with-itself", "layer-15"}
end

util.ground_unit_collision_mask = function()
  return {"not-colliding-with-itself", "player-layer", "train-layer"}
end

util.projectile_collision_mask = function()
  return {"layer-15", "player-layer", "train-layer"}
end

util.unit_flags = function()
  return {"player-creation", "placeable-off-grid"}
end

util.shift_box = function(box, shift)
  local left_top = box[1]
  local right_bottom = box[2]
  left_top[1] = left_top[1] + shift[1]
  left_top[2] = left_top[2] + shift[2]
  right_bottom[1] = right_bottom[1] + shift[1]
  right_bottom[2] = right_bottom[2] + shift[2]
  return box
end


util.shift_layer = function(layer, shift)
  layer.shift = layer.shift or {0,0}
  layer.shift[1] = layer.shift[1] + shift[1]
  layer.shift[2] = layer.shift[2] + shift[2]
  return layer
end

return util
