local shared = require("shared")
-- The legs are always drawn from the vanilla inserters, whatever other mods have done to them by now: the Beast's own
-- sprites (hand-down, hand-shadow, platform) are made from exactly those files, and another mod's inserter graphics are
-- laid out differently or not there at all. So it doesn't matter when this mod is loaded.
local vanilla_inserters = require("prototypes.vanilla-inserters")
local health_multiplier = settings.startup["the-beast-health-multiplier"].value
local damage_multiplier = settings.startup["the-beast-damage-multiplier"].value

-- Every damage in an attack or a trigger, scaled by the startup setting.
local function scale_damage(value)
  if type(value) ~= "table" then return value end
  if value.type == "damage" and type(value.damage) == "table" and value.damage.amount then
    value.damage.amount = value.damage.amount * damage_multiplier
  end
  for _, child in pairs(value) do scale_damage(child) end
  return value
end

-- Dark purple on the map, to tell them apart from biters.
local map_color = {r = 0.42, g = 0.05, b = 0.6}

-- Sprites -----------------------------------------------------------------------------------------------------------
-- A creature's torso is a RotatedAnimation drawn from the building's own sprites, which are Sprites, Animations,
-- RotatedSprites and the rest. The engine lays the frames of each type out in its own way (stripes, filenames, slice,
-- lines_per_file, back_equals_front, per-frame rectangles), so a layer copied across as it was reads other pixels, or
-- pixels outside the file, and the game doesn't start (Wind-Turbines-Reforged's stripes did that). So every layer is
-- rebuilt here in a form that means the same pixels whichever type reads it: one file and the corner of its first
-- frame, and the frames of an animation only where they are in one plain grid in one file. A torso that turns (a car,
-- rolling stock, a turret's head) keeps the building's own rotated sprite, which already is of a rotated type.

-- How it is drawn rather than where its pixels are, so copied as they are.
local look_keys = {"priority", "flags", "shift", "scale", "tint", "tint_as_overlay", "blend_mode", "draw_as_glow", "draw_as_shadow", "premul_alpha", "invert_colors", "usage", "surface", "allow_forced_downscale", "dice", "dice_x", "dice_y"}
-- The engine's limit on how long an animation is, frames included as many times as they are shown: breathing in and out
-- shows 2n - 2 frames.
local max_breath_frames = 128

local function frame_size(layer)
  local width, height, size = layer.width, layer.height, layer.size
  if type(size) == "number" then
    width, height = width or size, height or size
  elseif type(size) == "table" then
    width, height = width or size[1], height or size[2]
  end
  if type(width) ~= "number" or type(height) ~= "number" or width <= 0 or height <= 0 then return nil end
  return width, height
end

local function corner(layer)
  local x, y = layer.x or 0, layer.y or 0
  if x == 0 and y == 0 and type(layer.position) == "table" then x, y = layer.position[1] or 0, layer.position[2] or 0 end
  return x, y
end

local function mask_tint(out, layer, mask_color)
  if layer.apply_runtime_tint then
    out.apply_runtime_tint = nil
    out.tint = mask_color
    out.tint_as_overlay = true
  end
end

-- One layer of a torso that doesn't turn: one direction, and either its first frame or, from one plain grid of frames
-- in one file, the frames of the animation (frame_count, set by breathe). A list of files gives only its first file's
-- first frame, as where the other frames are depends on the type. Nil if it has no frame this can read.
local function still_layer(layer, mask_color)
  local width, height = frame_size(layer)
  if not width then return nil end
  local out = {}
  for _, key in pairs(look_keys) do out[key] = table.deepcopy(layer[key]) end
  mask_tint(out, layer, mask_color)
  out.width, out.height, out.direction_count = width, height, 1
  local count = math.max(1, math.floor(tonumber(layer.frame_count) or 1))
  local across, frames, index = 0, 1, 0
  if type(layer.stripes) == "table" then
    local stripe = layer.stripes[1]
    if not (type(stripe) == "table" and type(stripe.filename) == "string") then return nil end
    out.filename = stripe.filename
    out.x, out.y = stripe.x or 0, stripe.y or 0
    across = math.max(1, stripe.width_in_frames or 1)
    -- In a rotated animation a stripe's rows are its directions, so only its first row is the first direction's frames.
    local rows = (layer.direction_count or 1) > 1 and 1 or math.max(1, stripe.height_in_frames or 1)
    frames = math.min(count, across * rows)
  elseif type(layer.filenames) == "table" then
    if type(layer.filenames[1]) ~= "string" then return nil end
    out.filename = layer.filenames[1]
    out.x, out.y = 0, 0
  elseif type(layer.filename) == "string" then
    out.filename = layer.filename
    out.x, out.y = corner(layer)
    across = layer.line_length or 0
    frames = count
  else
    return nil
  end
  -- The building shows its frames in its own order. If it shows every one of the first m, those are all in the file and
  -- they're the animation; if it skips some, maybe not even the first is, so the first one it shows, still.
  local sequence = layer.frame_sequence
  if type(sequence) == "table" and sequence[1] then
    local shown, last = {}, 0
    for _, frame in ipairs(sequence) do
      if type(frame) == "number" then
        shown[frame] = true
        last = math.max(last, frame)
      end
    end
    local every = last > 0
    for frame = 1, last do every = every and shown[frame] == true end
    if every then
      frames = math.min(frames, last)
      -- This atlas replacement packs 20 logical frames into 16 cells. Keep its timing when breathing.
      if out.filename == "__zzzparanoidal__/graphics/atlas-sprites/Bio_Industries_2/entities/bio_garden/bio_garden_anim_trees.png" then
        out.frame_sequence = table.deepcopy(sequence)
      end
    else
      index = math.max(0, math.min(frames, sequence[1]) - 1)
      frames = 1
    end
  end
  if index > 0 then
    local per_row = across > 0 and across or math.huge
    out.x = out.x + (index % per_row) * width
    out.y = out.y + math.floor(index / per_row) * height
  end
  -- A rotated sprite's own rectangle for its first direction, within the cell of the sheet.
  local frame = type(layer.frames) == "table" and layer.frames[1]
  if type(frame) == "table" then
    out.x, out.y = out.x + (frame.x or 0), out.y + (frame.y or 0)
    out.width, out.height = frame.width or width, frame.height or height
    local shift, offset = layer.shift or {0, 0}, frame.shift or {0, 0}
    out.shift = {(shift[1] or shift.x or 0) + (offset[1] or offset.x or 0), (shift[2] or shift.y or 0) + (offset[2] or offset.y or 0)}
  end
  if frames > 1 then out.line_length = across end
  out.frame_count = frames
  return out
end

-- One layer of a torso that turns, from the building's own RotatedAnimation (a car, a turret's head): the same type,
-- so all of it is kept as it is.
local function rotated_animation_layer(layer, mask_color)
  local out = table.deepcopy(layer)
  mask_tint(out, layer, mask_color)
  return out
end

-- One layer of rolling stock's RotatedSprite as a RotatedAnimation of one frame per direction. Rows of a file of
-- filenames are `slice` frames there, so that is set to the sprite's own line_length. It only stores half a circle
-- (back_equals_front), which a rotated animation can't say, so its sheets are listed twice when they hold exactly that
-- half; otherwise it is left turning at half the rate. Per-frame rectangles go: the whole cells of the sheet are read.
local function rotated_sprite_layer(layer, mask_color)
  local directions = math.floor(tonumber(layer.direction_count) or 0)
  if not frame_size(layer) or directions < 1 then return nil end
  local out = table.deepcopy(layer)
  mask_tint(out, layer, mask_color)
  out.frames, out.back_equals_front, out.allow_low_quality_rotation = nil, nil, nil
  out.frame_count, out.frame_sequence, out.repeat_count, out.run_mode = 1, nil, nil, nil
  local across = layer.line_length or 0
  if type(layer.filenames) == "table" then
    if across <= 0 or not layer.lines_per_file then return nil end
    out.slice = across
    if layer.back_equals_front and directions == #layer.filenames * layer.lines_per_file * across then
      for _, file in ipairs(layer.filenames) do out.filenames[#out.filenames + 1] = file end
      out.direction_count = directions * 2
    end
  elseif type(layer.filename) == "string" then
    local x, y = corner(layer)
    if layer.back_equals_front and across > 0 and directions % across == 0 and x == 0 and y == 0 then
      out.filenames, out.filename = {layer.filename, layer.filename}, nil
      out.lines_per_file, out.slice = directions / across, across
      out.direction_count = directions * 2
    end
  else
    return nil
  end
  return out
end

-- Layers of a torso that doesn't turn all show as many frames, so the still ones repeat their first, and it all plays
-- back and forth so it looks like it's breathing. Only the longest-running layers move.
local function breathe(layers)
  local frames = 1
  for _, layer in pairs(layers) do
    frames = math.max(frames, layer.frame_sequence and #layer.frame_sequence or layer.frame_count)
  end
  frames = math.min(frames, max_breath_frames)
  if frames == 1 then
    for _, layer in pairs(layers) do layer.frame_count = 1 end
    return
  end
  local there_and_back, still = {}, {}
  for i = 1, frames do there_and_back[i] = i end
  for i = frames - 1, 2, -1 do there_and_back[#there_and_back + 1] = i end
  for i = 1, #there_and_back do still[i] = 1 end
  for _, layer in pairs(layers) do
    local source_sequence = layer.frame_sequence
    local moves = (source_sequence and #source_sequence or layer.frame_count) >= frames
    layer.frame_count = moves and (source_sequence and layer.frame_count or frames) or 1
    if not moves then layer.line_length = nil end
    if moves and source_sequence then
      layer.frame_sequence = {}
      for i, frame in ipairs(there_and_back) do layer.frame_sequence[i] = source_sequence[frame] end
    else
      layer.frame_sequence = moves and there_and_back or still
    end
    layer.animation_speed = 0.4
  end
end

local function base_file(path)
  return path:match("[^/]+$") or path
end

-- Lights and smoke aren't part of its body. By the file's own name, as plain text: a pattern "-light" matched "light"
-- anywhere in the path, which dropped every layer of a mod with "light" in its name.
local function is_light(layer)
  if layer.draw_as_light then return true end
  for _, file in pairs{layer.filename, type(layer.filenames) == "table" and layer.filenames[1] or nil, type(layer.stripes) == "table" and type(layer.stripes[1]) == "table" and layer.stripes[1].filename or nil} do
    if type(file) == "string" and (base_file(file):find("smoke", 1, true) or base_file(file):find("-light", 1, true)) then return true end
  end
  return false
end

-- Every layer of a sprite that isn't itself made of layers, in drawing order.
local function leaves(sprite, result)
  result = result or {}
  if type(sprite) ~= "table" then return result end
  if type(sprite.layers) == "table" then
    for _, layer in ipairs(sprite.layers) do leaves(layer, result) end
  else
    result[#result + 1] = sprite
  end
  return result
end

-- Splits a sprite's layers into its body and its shadow, dropping lights. make: still_layer, rotated_animation_layer or
-- rotated_sprite_layer. Nil if nothing of its body is left.
local function body_animation(sprite, make, mask_color)
  local body, shadow = {}, {}
  for _, layer in pairs(leaves(sprite)) do
    if not is_light(layer) then
      local made = make(layer, mask_color)
      if made then
        if made.draw_as_shadow then shadow[#shadow + 1] = made else body[#body + 1] = made end
      end
    end
  end
  if #body == 0 then return nil end
  if make == still_layer then
    breathe(body)
    breathe(shadow)
  end
  return {layers = body}, #shadow > 0 and {layers = shadow} or nil
end

local function base_name(path)
  return type(path) == "string" and path:match("([^/]+)%.png$") or nil
end

-- The Beast's purple versions of the vanilla fires, by the file they were made from. See tools/make_sprites.py. Only
-- those exact files are swapped, as another mod's fire of the same name needn't be the same size; any other is tinted.
local purple_files = {}
for _, path in pairs
{
  "stone-furnace/stone-furnace-fire", "steel-furnace/steel-furnace-fire", "steel-furnace/steel-furnace-glow",
  "steel-furnace/steel-furnace-working", "electric-furnace/electric-furnace-heater"
} do
  purple_files["__base__/graphics/entity/" .. path .. ".png"] = "__Paranoidal-Protomolecule-Beast__/graphics/fire/" .. base_name(path .. ".png") .. ".png"
end

-- A copy, fires turned purple. Only glows and blended layers are fires.
local function purple_fire(sprite)
  local copy = table.deepcopy(sprite)
  for _, layer in pairs(leaves(copy)) do
    if layer.draw_as_glow or layer.blend_mode then
      if layer.filename and purple_files[layer.filename] then
        layer.filename = purple_files[layer.filename]
      else
        layer.tint = {r = 0.7, g = 0.2, b = 1}
      end
    end
  end
  return copy
end

-- One sprite out of whatever's given: the north one of a 4- or 8-way set (some mods give a building four where the base
-- game has one), the north frames of a sheet of them, the first of a list of variations. A 4-way sheet has the north one
-- first, which is where a plain sprite of it starts anyway.
local function north(sprite)
  if type(sprite) ~= "table" then return nil end
  if sprite.layers or sprite.filename or sprite.filenames or sprite.stripes then return sprite end
  if sprite.north then return north(sprite.north) end
  if type(sprite.sheets) == "table" then return {layers = sprite.sheets} end
  if sprite.sheet then return north(sprite.sheet) end
  if sprite[1] then return north(sprite[1]) end
  return nil
end

-- A copy without dice, which only a sprite cut up for a building has.
local function undiced(sprite)
  local copy = table.deepcopy(sprite)
  for _, layer in pairs(leaves(copy)) do layer.dice, layer.dice_x, layer.dice_y = nil, nil, nil end
  return copy
end

-- The building's own picture, or nil if it has none this knows how to read, and then it doesn't get a creature. Every
-- part is taken through north(), which reads a single sprite, a 4-way set or variations alike.
local function body_sprite(entity)
  local graphics = entity.graphics_set or {}
  local function working_parts(layers, take)
    for _, visualisation in pairs(graphics.working_visualisations or {}) do
      local animation = north(visualisation.north_animation or visualisation.animation)
      if animation and not visualisation.light then
        local part = take(visualisation, animation)
        if part then layers[#layers + 1] = part end
      end
    end
    return layers
  end
  if entity.type == "mining-drill" then
    local animation = north(graphics.animation)
    if not animation then return nil end
    -- A pumpjack's frame, under its moving head. 2.1: MiningDrillPrototype has no base_picture; the frame is a
    -- working visualisation drawn always and below the animation (secondary_draw_order < 0), so those go first.
    local function plain(below)
      return function(visualisation, part)
        if visualisation.apply_tint or ((visualisation.secondary_draw_order or 0) < 0) ~= below then return nil end
        return part
      end
    end
    local layers = working_parts({}, plain(true))
    layers[#layers + 1] = animation
    return {layers = working_parts(layers, plain(false))}
  end
  if entity.type == "furnace" then
    local animation = north(graphics.animation)
    if not animation then return nil end
    -- With its fire always roaring, in the Beast's colours.
    return {layers = working_parts({animation}, function(_, part) return purple_fire(part) end)}
  end
  if entity.type == "assembling-machine" then
    local animation = north(graphics.animation) or north(graphics.idle_animation)
    if animation then return animation end
    -- Some mods' machines are drawn only by what they show while working.
    return working_parts({}, function(_, part) return part end)[1]
  end
  -- Its head, which turns: a RotatedAnimation.
  if entity.type == "ammo-turret" or entity.type == "electric-turret" then return entity.prepared_animation end
  -- 2.1: picture is a Sprite4Way for both; a logistic container has neither picture nor animation, its look is its robot
  -- door's animation (shut in the first frame), which the base game also copies as a chest's picture. north() reads either.
  if entity.type == "container" or entity.type == "logistic-container" then
    return north(entity.picture) or north(entity.animation) or north(entity.robot_door and entity.robot_door.animation)
  end
  if entity.type == "radar" then return north(entity.pictures) end
  if entity.type == "lamp" then
    local off, on = north(entity.picture_off), north(entity.picture_on)
    if not (off and on) then return nil end
    -- Lit, in the Beast's colours. See tools/make_sprites.py. Another mod's light is only tinted.
    local lit = table.deepcopy(on)
    for _, layer in pairs(leaves(lit)) do
      if layer.filename == "__base__/graphics/entity/small-lamp/lamp-light.png" then layer.filename = "__Paranoidal-Protomolecule-Beast__/graphics/fire/lamp-glow.png" end
      layer.draw_as_glow = true
      layer.draw_as_light = nil
      layer.tint = {r = 0.7, g = 0.2, b = 1}
    end
    return {layers = {off, lit}}
  end
  if entity.type == "electric-pole" then return north(entity.pictures) end
  -- 2.1: GeneratorPrototype has pictures (GeneratorPictureSet: north/east/south/west, each GeneratorPictures with an
  -- animation and a frozen patch) instead of the two animations; the north one first, as the vertical one was in 2.0.
  if entity.type == "generator" then
    local set = type(entity.pictures) == "table" and entity.pictures or {}
    local view = set.north or set.east or set.south or set.west
    return view and north(view.animation)
  end
  if entity.type == "boiler" then
    local pictures = entity.pictures and entity.pictures.north
    local structure = pictures and north(pictures.structure)
    if not structure then return nil end
    local layers = {structure}
    local fire = north(pictures.fire)
    if fire then layers[#layers + 1] = purple_fire(fire) end
    return {layers = layers}
  end
  if entity.type == "burner-generator" then return north(entity.animation) or north(entity.idle_animation) end
  if entity.type == "reactor" then
    local picture = north(entity.picture)
    if not picture then return nil end
    local layers = {}
    local lower = north(entity.lower_layer_picture)
    if lower then layers[1] = lower end
    layers[#layers + 1] = picture
    return {layers = layers}
  end
  if entity.type == "accumulator" then return entity.chargable_graphics and north(entity.chargable_graphics.picture) end
  -- Its base and the cannon pointing the first way, without the cannon's dice, as a torso is drawn whole.
  if entity.type == "artillery-turret" then
    local layers = {}
    for _, key in pairs{"base_picture", "cannon_base_pictures", "cannon_barrel_pictures"} do
      local sprite = north(entity[key])
      if sprite then layers[#layers + 1] = undiced(sprite) end
    end
    return #layers > 0 and {layers = layers} or nil
  end
  -- Every direction of it, as it turns (shared.compounds, vehicle): a RotatedAnimation.
  if entity.type == "car" then return entity.animation end
  if entity.type == "solar-panel" then return north(entity.picture) end
  if entity.type == "electric-energy-interface" then
    return north(entity.picture) or north(entity.animation) or north(entity.pictures) or north(entity.animations)
  end
  -- Rolling stock, every direction of it: a RotatedSprite.
  if entity.pictures and entity.pictures.rotated then return entity.pictures.rotated end
  return nil
end

-- A building's shadow sprite only has what sticks out from behind it, which looks wrong with it up in the air, so it casts
-- the shape of the whole thing instead. Not of its glows and fires, which are solid rectangles under their additive blending.
local function silhouette(body)
  local layers = {}
  for _, layer in pairs(body.layers) do
    if not (layer.draw_as_glow or layer.blend_mode) then
      local copy = table.deepcopy(layer)
      copy.tint = nil
      copy.tint_as_overlay = nil
      copy.draw_as_shadow = true
      layers[#layers + 1] = copy
    end
  end
  return #layers > 0 and {layers = layers} or nil
end

-- Among every type a creature can be made of (shared.source_types), so that a new group's base game buildings are found.
local function find_prototype(name)
  for _, type in pairs(shared.source_types) do
    if data.raw[type] and data.raw[type][name] then return data.raw[type][name] end
  end
end

local function arm_sprite(picture, shadow)
  local sprite = table.deepcopy(picture)
  sprite.direction_count = 1
  if shadow then
    sprite.filename = "__Paranoidal-Protomolecule-Beast__/graphics/hand-shadow/" .. base_name(picture.filename) .. ".png"
    sprite.draw_as_shadow = true
  end
  return sprite
end

-- The hand on the end of a limb, turned round to walk on its claw. See tools/make_sprites.py.
local function hand_down_sprite(picture, shadow)
  local sprite = arm_sprite(picture, shadow)
  sprite.filename = "__Paranoidal-Protomolecule-Beast__/graphics/hand-down/" .. base_name(picture.filename) .. ".png"
  return sprite
end

-- The base, and its shadow separately so that it can drop away from a lifted foot. See tools/make_sprites.py.
local function platform_sprite(inserter, shadow)
  local sheet = inserter.platform_picture.sheet
  local name = base_name(sheet.filename)
  return
  {
    filename = "__Paranoidal-Protomolecule-Beast__/graphics/platform/" .. name .. (shadow and "-shadow.png" or ".png"),
    width = sheet.width,
    height = sheet.height,
    shift = sheet.shift,
    scale = sheet.scale,
    priority = "extra-high",
    direction_count = 4,
    line_length = 4,
    draw_as_shadow = shadow or nil
  }
end

-- How far up the wall its top is, where the base or hand clamps on, and so how much taller it all stands.
local wall_height = 0.8
-- Where the base sits, low enough to look like it's got a real grip on the wall.
local wall_clamp_height = 0.5

-- The base game's single piece of stone wall and its shadow (2.0.77), whatever other mods have done to the wall since:
-- the same picture for all four directions of a foot, each in a file of its own, its first variation at the corner.
local vanilla_wall =
{
  {filename = "__base__/graphics/entity/wall/wall-single.png", width = 64, height = 86, shift = {0, -5 / 32}, scale = 0.5},
  {filename = "__base__/graphics/entity/wall/wall-single-shadow.png", width = 98, height = 60, shift = {10 / 32, 17 / 32}, scale = 0.5}
}

local function wall_layer(shadow)
  local wall = vanilla_wall[shadow and 2 or 1]
  local file = wall.filename
  return
  {
    filenames = {file, file, file, file},
    lines_per_file = 1,
    line_length = 1,
    width = wall.width,
    height = wall.height,
    shift = wall.shift,
    scale = wall.scale,
    priority = "extra-high",
    direction_count = 4,
    draw_as_shadow = shadow or nil
  }
end

-- A foot that's a piece of wall, with the inserter's base clamped to the top of it if it has one there.
local function walled_foot(inserter, shadow)
  local layers = {wall_layer(shadow)}
  if inserter then
    -- Always the frame with two of its legs at the bottom and one at the top, straddling the wall whichever way it steps.
    local platform = platform_sprite(inserter, shadow)
    platform.shift = {platform.shift[1], platform.shift[2] - wall_clamp_height}
    platform.filenames = {platform.filename, platform.filename, platform.filename, platform.filename}
    platform.filename = nil
    platform.lines_per_file = 1
    platform.line_length = 1
    layers[2] = platform
  end
  return {layers = layers}
end

local function on_walls(leg, inserter)
  leg.name = leg.name .. "-walled"
  leg.ankle_height = wall_clamp_height
  leg.knee_height = leg.knee_height + wall_height
  leg.graphics_set.foot = walled_foot(inserter)
  leg.graphics_set.foot_shadow = walled_foot(inserter, true)
end

local legs_made = {}

-- Feet are quick and only lift for a real step, so they stay planted and then stride rather than shuffling along.
local leg_speed = 1.2
local default_stride = 2.5
local long_handed_stride = 4

local function leg_prototype(name, icon, stride, graphics_set)
  return
  {
    type = "spider-leg",
    name = name,
    hidden = true,
    collision_box = {{-0.05, -0.05}, {0.05, 0.05}},
    selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
    collision_mask = {layers = {player = true, is_object = true, rail = true}},
    icon = icon,
    flags = {"not-repairable"},
    target_position_randomisation_distance = 0.15,
    minimal_step_size = stride * 0.8,
    stretch_force_scalar = 0.5,
    knee_height = 1,
    knee_distance_factor = 0.5,
    hip_flexibility = 1,
    initial_movement_speed = 0.06 * leg_speed,
    movement_acceleration = 0.03 * leg_speed,
    max_health = 100,
    base_position_selection_distance = stride,
    movement_based_position_selection_distance = stride,
    selectable_in_game = false,
    alert_when_damaged = false,
    graphics_set = graphics_set
  }
end

local function inserter_leg(inserter_name, stride, walled, knee_height)
  stride = stride or (inserter_name == "long-handed-inserter" and long_handed_stride or default_stride)
  local name = "beast-leg-" .. inserter_name .. "-" .. math.floor(stride * 100) .. (knee_height and ("-knee-" .. math.floor(knee_height * 100)) or "")
  if legs_made[name .. (walled and "-walled" or "")] then return name .. (walled and "-walled" or "") end
  legs_made[name .. (walled and "-walled" or "")] = true
  local inserter = vanilla_inserters[inserter_name]
  local leg = leg_prototype(name, inserter.icon, stride,
  {
    upper_part = {middle = arm_sprite(inserter.hand_closed_picture)},
    upper_part_shadow = {middle = arm_sprite(inserter.hand_closed_shadow, true)},
    lower_part = {middle = arm_sprite(inserter.hand_base_picture)},
    lower_part_shadow = {middle = arm_sprite(inserter.hand_base_shadow, true)},
    foot = platform_sprite(inserter),
    foot_shadow = platform_sprite(inserter, true)
  })
  leg.localised_name = {"entity-name." .. inserter_name}
  leg.knee_height = knee_height or leg.knee_height
  if walled then on_walls(leg, inserter) end
  data:extend{leg}
  return leg.name
end

-- One half of a lone inserter, which is all elbow: the arm walks on its base, and the forearm on its hand.
local function limb(inserter_name, stride, kind, height, walled)
  local name = "beast-limb-" .. kind .. "-" .. inserter_name .. (walled and "-walled" or "")
  if legs_made[name] then return name end
  legs_made[name] = true
  local inserter = vanilla_inserters[inserter_name]
  local graphics_set
  if kind == "arm" then
    graphics_set =
    {
      lower_part = {middle = arm_sprite(inserter.hand_base_picture)},
      lower_part_shadow = {middle = arm_sprite(inserter.hand_base_shadow, true)},
      foot = platform_sprite(inserter),
      foot_shadow = platform_sprite(inserter, true)
    }
  else
    graphics_set =
    {
      lower_part = {middle = hand_down_sprite(inserter.hand_open_picture)},
      lower_part_shadow = {middle = hand_down_sprite(inserter.hand_open_shadow, true)}
    }
  end
  local leg = leg_prototype(name, inserter.icon, stride, graphics_set)
  leg.localised_name = {"entity-name." .. inserter_name}
  -- The knee's height is from the ground, so this puts it at the elbow and makes the whole limb the one visible part.
  leg.knee_height = height
  leg.knee_distance_factor = 0.05
  if walled then
    leg.name = name:sub(1, -8)
    leg.knee_height = height - wall_height
    on_walls(leg, kind == "arm" and inserter or nil)
    -- Low enough that the claw grips the top of the wall rather than hovering over it.
    if kind == "hand" then leg.ankle_height = wall_clamp_height - 0.1 end
  end
  data:extend{leg}
  return name
end

local leg_hit_the_ground =
{
  {
    type = "create-trivial-smoke",
    smoke_name = "smoke-building",
    repeat_count = 2,
    starting_frame_deviation = 5,
    offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
    speed_from_center = 0.02
  }
}

-- The same every time for a given leg, so it looks organic but doesn't differ between saves.
local function jitter(index, amount)
  local value = math.sin(index * 12.9898) * 43758.5453
  return (value - math.floor(value) - 0.5) * 2 * amount
end

local grip_inset = 0.1

-- Where the hands clamp on, from the collision box since that's where the entity's base really is.
local function leg_layout(count, box, along_sides)
  local x, y = math.max(box[2][1] - grip_inset, 0.1), math.max(box[2][2] - grip_inset, 0.1)
  if count == 1 then return {{0, 0}} end
  if count == 2 then return {{-x, 0}, {x, 0}} end
  if count == 4 then return {{-x, -y}, {x, -y}, {x, y}, {-x, y}} end
  if along_sides then
    local layout = {}
    local per_side = count / 2
    for i = 1, per_side do
      local along = y * (2 * (i - 1) / (per_side - 1) - 1)
      layout[#layout + 1] = {-x, along}
      layout[#layout + 1] = {x, along}
    end
    return layout
  end
  local layout = {}
  for i = 1, count do
    local angle = 2 * math.pi * (i - 0.5) / count
    layout[i] = {math.cos(angle) * x * 1.4, math.sin(angle) * y * 1.4}
  end
  return layout
end

-- A wave down each side with the two sides out of step, rather than one whole side lifting at once.
local function side_walking_group(i, count)
  local per_side = count / 2
  local groups = per_side > 3 and 4 or 3
  local along = math.floor((i - 1) / 2)
  local right_side = (i - 1) % 2
  return (along + right_side * math.floor(groups / 2)) % groups + 1
end

-- The end legs of a long body grip further in and their feet land beyond its ends, like splayed legs.
local end_leg_inset = 0.35
local end_leg_splay = 2

local function legs_for(leg, count, box, stance, along_sides)
  local legs = {}
  local layout = leg_layout(count, box, along_sides)
  local furthest = 0
  if along_sides then
    for _, mount in pairs(layout) do furthest = math.max(furthest, math.abs(mount[2])) end
  end
  for i, mount in pairs(layout) do
    local at_end = along_sides and math.abs(mount[2]) >= furthest - 0.01
    local length = math.sqrt(mount[1] * mount[1] + mount[2] * mount[2])
    local scale = length > 0 and (length + stance) / length or 1
    local ground = {mount[1] * scale, mount[2] * scale}
    if along_sides then
      ground = {mount[1] + (mount[1] > 0 and 1 or -1) * (stance + jitter(i, 0.5)), mount[2] + jitter(i + 100, 0.7)}
      if at_end then
        mount = {mount[1] - (mount[1] > 0 and 1 or -1) * end_leg_inset, mount[2]}
        ground[2] = ground[2] + (mount[2] > 0 and 1 or -1) * end_leg_splay
      end
    end
    legs[i] =
    {
      leg = leg,
      mount_position = mount,
      ground_position = ground,
      walking_group = along_sides and side_walking_group(i, count) or ((i - 1) % (count == 3 and 3 or 2)) + 1,
      leg_hit_the_ground_trigger = leg_hit_the_ground
    }
  end
  return legs
end

local rock_attack =
{
  type = "projectile",
  ammo_category = "biological",
  cooldown = 90,
  range = 15,
  ammo_type =
  {
    action =
    {
      type = "direct",
      action_delivery = {type = "projectile", projectile = "beast-rock", starting_speed = 0.35, max_range = 30}
    }
  }
}

local attack_for_unscaled

local function attack_for(kind)
  return scale_damage(attack_for_unscaled(kind))
end

attack_for_unscaled = function(kind)
  if kind == "strike" then
    return
    {
      type = "projectile",
      ammo_category = "melee",
      cooldown = 45,
      range = 1.5,
      ammo_type =
      {
        action =
        {
          type = "direct",
          action_delivery = {type = "instant", target_effects = {type = "damage", damage = {amount = 10, type = "physical"}}}
        }
      }
    }
  end
  if kind == "corruption" then
    -- The laser turret's beam, as long as it is still a beam (other mods change that turret); otherwise one of its own.
    local laser = data.raw["electric-turret"]["laser-turret"]
    local attack = laser and table.deepcopy(laser.attack_parameters)
    local action = attack and attack.type == "beam" and attack.ammo_type and attack.ammo_type.action
    local delivery = type(action) == "table" and action.action_delivery
    if not (type(delivery) == "table" and delivery.type == "beam") then
      attack =
      {
        type = "beam",
        ammo_category = "laser",
        cooldown = 40,
        damage_modifier = 2,
        ammo_type = {action = {type = "direct", action_delivery = {type = "beam", max_length = 24, duration = 40, source_offset = {0, -1.3}}}}
      }
      delivery = attack.ammo_type.action.action_delivery
    end
    attack.range = 20
    delivery.beam = "beast-corruption-beam"
    attack.ammo_type.energy_consumption = nil
    return attack
  end
  if kind == "fire" then
    return
    {
      type = "stream",
      ammo_category = "flamethrower",
      cooldown = 150,
      range = 16,
      min_range = 5,
      -- Out of the top, like from a chimney.
      gun_center_shift = {0, -1.6},
      gun_barrel_length = 0.5,
      ammo_type =
      {
        action =
        {
          type = "direct",
          action_delivery = {type = "stream", stream = "beast-furnace-shot", source_offset = {0, -1.6}}
        }
      }
    }
  end
  if kind == "gun" then
    local attack = table.deepcopy(data.raw["ammo-turret"]["gun-turret"].attack_parameters)
    attack.range = 18
    attack.cooldown = 8
    attack.ammo_type =
    {
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects = {type = "create-explosion", entity_name = "explosion-gunshot"},
          target_effects =
          {
            {type = "create-entity", entity_name = "explosion-hit", offsets = {{0, 1}}, offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}}},
            {type = "damage", damage = {amount = 6, type = "physical"}}
          }
        }
      }
    }
    return attack
  end
  if kind == "drill" then
    return
    {
      type = "projectile",
      ammo_category = "melee",
      cooldown = 30,
      range = 2.5,
      ammo_type =
      {
        action =
        {
          type = "direct",
          action_delivery = {type = "instant", target_effects = {type = "damage", damage = {amount = 20, type = "physical"}}}
        }
      }
    }
  end
  if kind == "acid" then return table.deepcopy(data.raw.turret["small-worm-turret"].attack_parameters) end
  if kind == "electric" then
    return
    {
      type = "beam",
      ammo_category = "biological",
      cooldown = 40,
      range = 12,
      ammo_type =
      {
        action =
        {
          type = "direct",
          action_delivery = {type = "beam", beam = "beast-electric-beam", duration = 20, source_offset = {0, -1.5}}
        }
      }
    }
  end
  return table.deepcopy(rock_attack)
end

local function make_beast(params)
  data:extend
  {
    {
      type = "spider-unit",
      name = params.name,
      map_color = map_color,
      friendly_map_color = map_color,
      enemy_map_color = map_color,
      localised_name = params.localised_name,
      icon = (params.icon or params.icons) and params.icon or "__base__/graphics/icons/signal/signal-skull.png",
      icon_size = params.icon and params.icon_size or nil,
      icons = params.icons,
      hidden = true,
      flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "breaths-air", "not-repairable"},
      collision_box = params.collision_box,
      selection_box = params.selection_box,
      sticker_box = params.selection_box,
      drawing_box_vertical_extension = 3,
      max_health = params.health * health_multiplier,
      resistances = params.resistances,
      subgroup = "enemies",
      order = "z-beast",
      impact_category = "metal",
      healing_per_tick = 0,
      distraction_cooldown = 30,
      min_pursue_time = 10 * 60,
      max_pursue_distance = 50,
      attack_parameters = attack_for(params.attack),
      vision_distance = 30,
      ai_settings = {destroy_when_commands_fail = false, allow_try_return_to_spawner = false, strafe_settings = params.strafe_settings},
      corpse = params.corpse,
      dying_explosion = params.dying_explosion,
      is_military_target = true,
      working_sound = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"].working_sound),
      height = params.height,
      -- Hands turn with the torso, which only a train's sprite can do, so the others keep facing the same way and crab walk.
      torso_rotation_speed = params.rotates and (params.rotation_speed or 0.02) or 0,
      torso_bob_speed = params.bob_speed,
      graphics_set = params.graphics_set or {},
      spider_engine = {legs = params.legs, walking_group_overlap = 0}
    }
  }
end

-- One for every tenth of a tile a second, as the outbreak's research speeds every creature up from a quarter of its pace.
local function make_pace_sticker(tenths)
  data:extend
  {
    {
      type = "sticker",
      name = "beast-pace-" .. tenths,
      hidden = true,
      flags = {"not-on-map"},
      duration_in_ticks = 2 ^ 31,
      target_movement_max = tenths / 10 / 60
    }
  }
end

-- Everything in a sprite's table turned the green of the corruption.
local function turn_green(graphics)
  if type(graphics) ~= "table" then return end
  if graphics.filename or graphics.filenames or graphics.stripes then graphics.tint = {r = 0.15, g = 1, b = 0.2} end
  for _, value in pairs(graphics) do turn_green(value) end
end

local electric_beam = table.deepcopy(data.raw.beam["electric-beam"])
electric_beam.name = "beast-electric-beam"
scale_damage(electric_beam.action)
data:extend{electric_beam}

local corruption_beam = table.deepcopy(data.raw.beam["laser-beam"])
corruption_beam.name = "beast-corruption-beam"
turn_green(corruption_beam.graphics_set)
corruption_beam.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {type = "script", effect_id = "beast-corruption-beam"}
    }
  }
}
data:extend{corruption_beam}

-- The worms' spit, but what the Beast wants is what it lands on, not to destroy it: so no burning puddle, and it does
-- nothing but spread the corruption, in script so that it can leave what's already infected alone.
local furnace_shot = table.deepcopy(data.raw.stream["acid-stream-worm-medium"])
furnace_shot.name = "beast-furnace-shot"
furnace_shot.special_neutral_target_damage = nil
furnace_shot.particle.tint = {r = 0.6, g = 0.1, b = 0.9}
furnace_shot.spine_animation.tint = {r = 0.6, g = 0.1, b = 0.9}
local landing = furnace_shot.initial_action[1].action_delivery.target_effects
for i = #landing, 1, -1 do
  if landing[i].type == "create-fire" then table.remove(landing, i) end
end
landing[#landing + 1] = {type = "create-trivial-smoke", smoke_name = "beast-spores", repeat_count = 12, offset_deviation = {{-1.5, -1.5}, {1.5, 1.5}}, speed_from_center = 0.03}
furnace_shot.initial_action[2] =
{
  type = "area",
  radius = 3,
  force = "enemy",
  ignore_collision_condition = true,
  action_delivery = {type = "instant", target_effects = {type = "script", effect_id = "beast-corruption"}}
}
data:extend{furnace_shot}

-- What a train spews as it goes: a thin purple stream that lands close beside the rails.
local train_spew = table.deepcopy(data.raw.stream["acid-stream-worm-small"])
train_spew.name = "beast-train-spew"
train_spew.special_neutral_target_damage = nil
train_spew.particle.tint = {r = 0.6, g = 0.1, b = 0.9}
train_spew.spine_animation.tint = {r = 0.6, g = 0.1, b = 0.9}
train_spew.initial_action =
{
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {type = "create-entity", entity_name = "blood-explosion-small"},
        {type = "create-trivial-smoke", smoke_name = "beast-spores", repeat_count = 3, offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}}, speed_from_center = 0.03}
      }
    }
  },
  {
    type = "area",
    radius = 1.5,
    force = "enemy",
    ignore_collision_condition = true,
    action_delivery = {type = "instant", target_effects = {type = "script", effect_id = "beast-corruption"}}
  }
}
data:extend{train_spew}

for tenths = 1, shared.max_pace_sticker do
  make_pace_sticker(tenths)
end

data:extend
{
  {
    type = "projectile",
    name = "beast-rock",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {type = "script", effect_id = "beast-rock-hit"}
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/icons/stone.png",
      priority = "high",
      size = 64,
      scale = 0.3
    },
    shadow =
    {
      filename = "__base__/graphics/icons/stone.png",
      priority = "high",
      size = 64,
      scale = 0.3,
      draw_as_shadow = true
    }
  }
}

-- A foot always lands a stride ahead of where it rests and has to step again before it's a stride back, so if it rested
-- right under the body the feet would always be out in front with the pelvis trailing. Resting further back has them swing
-- from behind it to in front, like a walk. This only works for what turns to face where it's going.
local rest_behind = 0.45

-- A wall coming down hard. The damage is done in script, which leaves the Beast's own and the railway alone.
local function stomp(effect_id)
  return
  {
    {
      type = "create-trivial-smoke",
      smoke_name = "smoke-building",
      repeat_count = 8,
      starting_frame_deviation = 5,
      offset_deviation = {{-0.4, -0.4}, {0.4, 0.4}},
      speed_from_center = 0.05
    },
    {
      type = "play-sound",
      sound = {filename = "__base__/sound/fight/robot-die-impact-1.ogg", volume = 0.5, speed = 0.6}
    },
    {type = "script", effect_id = effect_id}
  }
end

-- Makes it, and the same thing up on walls.
local function make_beast_and_walled(params, legs_of, leg_count)
  params.legs = legs_of(false)
  make_beast(params)
  params.name = shared.walled_name(params.name)
  params.localised_name = {"entity-name.beast-walled", params.localised_name}
  params.height = params.height + wall_height
  params.health = params.health * 1.5 + leg_count * 100
  params.resistances = table.deepcopy(data.raw.wall["stone-wall"].resistances)
  params.bob_speed = 0.8
  params.legs = legs_of(true)
  for _, leg in pairs(params.legs) do
    leg.leg_hit_the_ground_trigger = stomp(leg_count > 2 and "beast-stomp-big" or "beast-stomp")
  end
  make_beast(params)
end

local function pair_legs(inserter_name, walled)
  local stride = inserter_name == "long-handed-inserter" and 6 or 3.8
  local leg = inserter_leg(inserter_name, stride, walled)
  return
  {
    {leg = leg, mount_position = {-0.2, 0}, ground_position = {-0.6, stride * rest_behind}, walking_group = 1, leg_hit_the_ground_trigger = leg_hit_the_ground},
    {leg = leg, mount_position = {0.2, 0}, ground_position = {0.6, stride * rest_behind}, walking_group = 2, leg_hit_the_ground_trigger = leg_hit_the_ground}
  }
end

local function lone_height(inserter_name)
  return inserter_name == "long-handed-inserter" and 1.7 or 1.1
end

local function lone_legs(inserter_name, walled)
  local stride = inserter_name == "long-handed-inserter" and 2.6 or 1.7
  local height = lone_height(inserter_name) + (walled and wall_height or 0)
  return
  {
    {leg = limb(inserter_name, stride, "arm", height, walled), mount_position = {0, 0}, ground_position = {-0.45, stride * rest_behind}, walking_group = 1, leg_hit_the_ground_trigger = leg_hit_the_ground},
    {leg = limb(inserter_name, stride, "hand", height, walled), mount_position = {0, 0}, ground_position = {0.45, stride * rest_behind}, walking_group = 2, leg_hit_the_ground_trigger = leg_hit_the_ground}
  }
end

for _, inserter_name in pairs(shared.inserters) do
  local inserter = data.raw.inserter[inserter_name]
  if inserter then
    local icon = vanilla_inserters[inserter_name].icon
    make_beast_and_walled(
    {
      name = shared.lone_name(inserter_name),
      localised_name = {"entity-name.beast-lone", {"entity-name." .. inserter_name}},
      icon = icon,
      collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
      selection_box = {{-0.5, -0.8}, {0.5, 0.5}},
      health = 200,
      attack = "strike",
      corpse = inserter.corpse,
      dying_explosion = inserter.dying_explosion,
      height = lone_height(inserter_name),
      bob_speed = 2.5,
      rotates = true,
      rotation_speed = 0.08
    }, function(walled) return lone_legs(inserter_name, walled) end, 2)
    make_beast_and_walled(
    {
      name = shared.pair_name(inserter_name),
      localised_name = {"entity-name.beast-pair", {"entity-name." .. inserter_name}},
      icon = icon,
      collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
      selection_box = {{-0.6, -1.2}, {0.6, 0.5}},
      health = 400,
      attack = "strike",
      corpse = inserter.corpse,
      dying_explosion = inserter.dying_explosion,
      height = inserter_name == "long-handed-inserter" and 2.6 or 1.7,
      bob_speed = 2,
      rotates = true,
      rotation_speed = 0.08
    }, function(walled) return pair_legs(inserter_name, walled) end, 2)
  end
end

local function make_robot(robot_name)
  local robot = data.raw["construction-robot"][robot_name] or data.raw["logistic-robot"][robot_name]
  local layers = {}
  -- A robot's own flying animation is a RotatedAnimation, as a unit's run animation is: kept as it is, lifted up.
  local function add(sprite, shadow)
    for _, layer in pairs(leaves(sprite)) do
      local copy = rotated_animation_layer(layer)
      if shadow then
        copy.draw_as_shadow = true
      else
        local shift = copy.shift or {0, 0}
        copy.shift = {shift[1] or shift.x or 0, (shift[2] or shift.y or 0) - 2}
      end
      layers[#layers + 1] = copy
    end
  end
  add(robot.in_motion or robot.idle)
  add(robot.shadow_in_motion or robot.shadow_idle, true)
  local run_animation = {layers = layers}
  data:extend
  {
    {
      type = "unit",
      name = shared.robot_name(robot_name),
      map_color = map_color,
      friendly_map_color = map_color,
      enemy_map_color = map_color,
      localised_name = {"entity-name." .. shared.robot_name(robot_name)},
      icon = robot.icon,
      icon_size = robot.icon_size,
      icons = robot.icons,
      hidden = true,
      flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "not-repairable"},
      -- They fly, and the engine picks what they go for, so their attack is what spreads the infection.
      collision_mask = {layers = {}},
      collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
      selection_box = {{-0.5, -2.5}, {0.5, -1.5}},
      sticker_box = {{-0.3, -2.3}, {0.3, -1.7}},
      max_health = 60,
      subgroup = "enemies",
      order = "z-beast",
      impact_category = "metal",
      healing_per_tick = 0,
      movement_speed = 0.15,
      distance_per_frame = 0.1,
      rotation_speed = 0.05,
      distraction_cooldown = 60,
      min_pursue_time = 5 * 60,
      max_pursue_distance = 20,
      has_belt_immunity = true,
      affected_by_tiles = false,
      render_layer = "air-object",
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "melee",
        cooldown = 45,
        range = 1,
        animation = run_animation,
        ammo_type =
        {
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {type = "script", effect_id = "beast-corruption"}
              }
            }
          }
        }
      },
      vision_distance = 15,
      ai_settings = {destroy_when_commands_fail = false, allow_try_return_to_spawner = false, do_separation = false},
      dying_explosion = robot.dying_explosion,
      is_military_target = true,
      run_animation = run_animation
    }
  }
end

for _, robot_name in pairs(shared.robots) do
  make_robot(robot_name)
end

-- The torso of a creature made of this building, or nil if there's no picture of it to be had (it is left without a
-- creature, which units.lua checks). Only what's left once its lights are dropped counts, which for some mods' lamps is
-- nothing. A turret's head turns on a base that doesn't; rolling stock and vehicles keep every direction of their own
-- sprite, shadow included; anything else is still, breathing, and casts the shape of its whole body.
local turret_color = {r = 0.9, g = 0.1, b = 0.1}
local function body_of(group, source)
  local sprite = body_sprite(source)
  if not sprite then return nil end
  if group.swivels then
    local visualisation = source.graphics_set and source.graphics_set.base_visualisation
    local base, base_shadow = body_animation(north(visualisation and visualisation.animation), still_layer, turret_color)
    local head, head_shadow = body_animation(sprite, rotated_animation_layer, turret_color)
    if not (base and head) then return nil end
    return {base_animation = base, shadow_base_animation = base_shadow, animation = head, shadow_animation = head_shadow}
  end
  if group.vehicle then
    local animation, shadow = body_animation(sprite, rotated_animation_layer, source.color)
    return animation and {animation = animation, shadow_animation = shadow} or nil
  end
  if group.train then
    local animation, shadow = body_animation(sprite, rotated_sprite_layer, source.color)
    return animation and {animation = animation, shadow_animation = shadow} or nil
  end
  local animation = body_animation(sprite, still_layer, source.color)
  return animation and {animation = animation, shadow_animation = silhouette(animation)} or nil
end

-- A collision box as {{left, top}, {right, bottom}}, which a prototype may also give as named fields.
local function plain_box(box)
  if not box then return {{-0.4, -0.4}, {0.4, 0.4}} end
  local left_top, right_bottom = box.left_top or box[1], box.right_bottom or box[2]
  return {{left_top.x or left_top[1], left_top.y or left_top[2]}, {right_bottom.x or right_bottom[1], right_bottom.y or right_bottom[2]}}
end

-- How many tiles across its longer side is.
local function size_of(source)
  local box = plain_box(source.collision_box)
  local width, height = box[2][1] - box[1][1], box[2][2] - box[1][2]
  return math.max(1, math.ceil(math.max(width, height) - 0.01))
end

-- For the control stage, by mod-data: what each building becomes, and what each creature is made of.
local made = {sources = {}, creatures = {}}

local function make_compound(group, source, inserter_name, legs, graphics_set)
  local box = plain_box(source.collision_box)
  local name = shared.compound_name(group, source.name, inserter_name)
  made.creatures[name] = {group = group.name, source = source.name, legs = legs}
  local params =
  {
    name = name,
    localised_name = {"entity-name.beast-" .. group.name},
    icon = source.icon,
    icon_size = source.icon_size,
    icons = source.icons,
    collision_box = box,
    selection_box = source.selection_box,
    health = group.health * legs / group.legs,
    attack = group.attack,
    corpse = source.corpse,
    dying_explosion = source.dying_explosion,
    height = group.height or 1.5,
    graphics_set = graphics_set,
    rotates = group.train or group.vehicle or group.swivels or group.turns,
    rotation_speed = group.turns and 0.05 or nil,
    bob_speed = 1.5
  }
  if group.swivels then
    -- The base stays still, and with it the hands, as a leg's mount only goes round as far as its base has directions for.
    params.height = 1
    params.rotation_speed = 0.03
    params.strafe_settings =
    {
      max_distance = 18,
      ideal_distance = 12,
      ideal_distance_tolerance = 2.5,
      ideal_distance_variance = 1,
      ideal_distance_importance = 0.25,
      ideal_distance_importance_variance = 0.1,
      face_target = true
    }
  end
  local function legs_of(walled)
    return legs_for(inserter_leg(inserter_name, group.stride, walled, group.knee_height), legs, box, group.stance or (group.train and 1.8) or 1.6, group.along_sides)
  end
  if group.train or group.vehicle then
    params.legs = legs_of(false)
    make_beast(params)
  else
    make_beast_and_walled(params, legs_of, legs)
  end
end

-- Only what an item places and can be picked out in the game, as the control stage infects nothing else.
local placeable = {}
for _, prototypes_of_type in pairs(data.raw) do
  for _, prototype in pairs(prototypes_of_type) do
    if type(prototype) == "table" and type(prototype.place_result) == "string" then placeable[prototype.place_result] = true end
  end
end

local function liftable(source)
  if not placeable[source.name] or source.selectable_in_game == false or shared.is_excluded(source.name) then return false end
  for _, flag in pairs(source.flags or {}) do
    if flag == "not-selectable-in-game" then return false end
  end
  return true
end

local undrawable = {}

-- One creature for each type of inserter that can carry it, or just the usual one for a building from another mod, as
-- there are hundreds of those.
local function add_source(group, source, legs, every_inserter)
  local graphics_set = body_of(group, source)
  if not graphics_set then
    undrawable[#undrawable + 1] = source.name
    return
  end
  local inserters = every_inserter and shared.leg_inserters(group) or {group.leg_inserter or "inserter"}
  for _, inserter_name in pairs(inserters) do
    if data.raw.inserter[inserter_name] then make_compound(group, source, inserter_name, legs, graphics_set) end
  end
  made.sources[source.name] = {group = group.name, legs = legs, as = source.name}
end

local vanilla = {}
for _, group in pairs(shared.compounds) do
  for _, source_name in pairs(group.sources) do
    vanilla[source_name] = true
    local source = find_prototype(source_name)
    if source then add_source(group, source, group.legs, true) end
  end
end

local function group_for(source)
  local name = shared.group_for_type[source.type]
  if name == "pylon" and size_of(source) > 1 then name = "big-pylon" end
  return shared.group_by_name(name)
end

local aliases = {}
for _, type in pairs(shared.source_types) do
  for name, source in pairs(data.raw[type] or {}) do
    if not vanilla[name] and liftable(source) then
      local base = shared.alias_of(name)
      if base and data.raw[type][base] then
        aliases[name] = base
      else
        local group = group_for(source)
        local size = size_of(source)
        if group and (group.train or size <= shared.max_lifted_size) then
          local legs = group.legs + ((not group.train and size >= shared.big_size) and shared.big_extra_legs or 0)
          add_source(group, source, legs, false)
        end
      end
    end
  end
end
-- A lit pole breaks when it's lifted, and it's the lamp that's carried off, though the pole counts as a sample too.
for name, base in pairs(aliases) do
  local lamp = name:find("^lighted%-") and data.raw.lamp["small-lamp"] and made.sources["small-lamp"]
  local info = lamp or made.sources[base]
  if info then made.sources[name] = {group = info.group, legs = info.legs, as = info.as, samples = lamp and {info.as, name} or nil} end
end

if #undrawable > 0 then
  table.sort(undrawable)
  log("Paranoidal-Protomolecule-Beast: no picture to make a creature from, so these can't be lifted: " .. table.concat(undrawable, ", "))
end

data:extend{{type = "mod-data", name = shared.mod_data_name, data = made}}
