local minime = require("__minime__/common")("minime")

-- Get scale factor and convert from percent to fraction
local scale_factor = settings.startup["minime_character-size"].value/100

-- Apply scale_factor to both parts of a vector or position. We don't want
-- to mess with other mods, so we return the scaled position in the original
-- format (dictionary: {x = 1, y = 1}, or array: {1, 1}).
local function scale_position(position, hr)
  -- Make sure position is in correct format

  position = position or { x = 0, y = 0}
  if type(position) ~= "table" or table_size(position) ~= 2 then
    error(serpent.line(position) .. " is not a valid position!")
  end

  -- Is this for the HR version?
  hr = hr and 1/scale_factor or 1

  local x = (position.x or position[1]) * scale_factor * hr
  local y = (position.y or position[2]) * scale_factor * hr

  return (position.x and position.y) and { x = x, y = y} or {x, y}
end


local function scale_image(img)
  if not img.scaled then
    -- Set scale (defaults to 1 if not explicitly set)
    img.scale = (img.scale or 1) * scale_factor
    minime.dprint("Scaled image " .. tostring(img.filename))
    if img.hr_version then
      img.hr_version.scale = (img.hr_version.scale or 1) * scale_factor
      minime.dprint("Scaled HR image " .. tostring(img.hr_version.filename))
    end

    -- Set shift
    img.shift = scale_position(img.shift)
    if img.hr_version then
      img.hr_version.shift = scale_position(img.shift, "HR")
    end

    -- Mark picture as scaled -- otherwise it will be scaled each time it's used!
    img.scaled = true
  end
end


local function recurse(table)
  for p, picture in pairs(table) do
    minime.dprint("p: " .. tostring(p))
    if type(picture) == "table" then
      if picture.filename then
        scale_image(picture)
      else
        recurse(picture)
      end
    else
      minime.dprint("Deadend! No picture: " .. serpent.line(picture))
    end
  end
end


--------------------------------------------------------------------------------
-- Change corpses
--------------------------------------------------------------------------------
for c, corpse in pairs(data.raw["character-corpse"]) do

minime.dprint("Scaling corpse " .. tostring(corpse.name) .. " (factor: " .. scale_factor .. ")")
  -- Adjust size of different boxes
  local box = corpse.selection_box
  if box then
    corpse.selection_box = { scale_position(box[1]), scale_position(box[2]) }
  end

  if corpse.picture then
    minime.dprint("Found \"picture\"!")
    recurse(corpse.picture)
  end

  if corpse.pictures then
    minime.dprint("Found \"pictures\"!")
    recurse(corpse.pictures)
  end


end

-- animation_list contains the names of mandatory+optional animations.
-- There's another property (armors), and other mods may add their own private properties,
-- so using a list instead of iterating through all values we find will be safer.
local animation_list = {
    "idle",
    "idle_with_gun",
    "running",
    "running_with_gun",
    "mining_with_tool",
    "flipped_shadow_running_with_gun"
}

--------------------------------------------------------------------------------
-- Change characters
--------------------------------------------------------------------------------

-- Scale characters' mining reach along with their graphics?
local mining_distance = settings.startup["minime_scale-reach_resource_distance"].value

-- Scale characters' tool-attack distance along with their graphics?
local tool_attack_distance = settings.startup["minime_scale-tool-attack-distance"].value

for c, character in pairs(data.raw["character"]) do

  minime.dprint("Scaling character " .. tostring(character.name) .. " (factor: " .. scale_factor .. ")")

  -- Adjust size of different boxes
  local box = character.selection_box
  if box then
    character.selection_box = { scale_position(box[1]), scale_position(box[2]) }
  end

  box = character.sticker_box
  if box then
    character.sticker_box = { scale_position(box[1]), scale_position(box[2]) }
  end

  -- Collision box of character should always be minimal so we can move it everywhere!
  character.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}

  -- Scale mining reach
  if mining_distance then
    character.reach_resource_distance = character.reach_resource_distance * scale_factor
    minime.dprint("Scaled reach_resource_distance of " .. character.name .. " to " ..
                  character.reach_resource_distance)
  end

  -- Scale tool-attack distance
  if tool_attack_distance then
    character.tool_attack_distance = (character.tool_attack_distance or 1.5) * scale_factor
    minime.dprint("Scaled tool_attack_distance of " .. character.name .. " to " ..
                  character.tool_attack_distance .. " (Default: " ..
                  character.tool_attack_distance/scale_factor .. ")")
  end

  -- Apply scale_factor to character graphics
  for _, armor_level in ipairs(character.animations) do
    for a, animation in pairs(animation_list) do
      animation = armor_level[animation] or {}
      for p, picture in ipairs(animation.layers or {}) do
        scale_image(picture)
      end
    end
  end

  -- Apply scale factor to character.corpse, if it exists
  if character.corpse then
    recurse(data.raw["corpse"][character.corpse])
  end
end
