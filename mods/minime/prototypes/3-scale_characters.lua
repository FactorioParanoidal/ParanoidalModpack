minime.entered_file()

local chars = data.raw.character
local corpses = data.raw["character-corpse"]

minime.ignore_chars = minime.ignore_chars or minime.get_ignore_characters()
minime.show("Won't scale these characters", minime.ignore_chars)

minime.show("Default character", chars.character)
minime.show("Default character-corpse", corpses["character-corpse"])

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                                Scale characters                                --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


-- Get scale factor and convert from percent to fraction
local scale_factor = minime.minime_character_scale

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
minime.show("Scaled image", img.filename)
    if img.hr_version then
      img.hr_version.scale = (img.hr_version.scale or 1) * scale_factor
minime.show("Scaled HR image", img.hr_version.filename)
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


local function recurse(tab)
  for p, picture in pairs(tab) do
minime.show("p", p)
    if type(picture) == "table" then
      if picture.filename or picture.filenames or picture.stripes then
        scale_image(picture)
      else
        recurse(picture)
      end
    else
      minime.writeDebug("Deadend! No picture: %s", {picture}, "line")
    end
  end
end


--------------------------------------------------------------------------------
-- Change corpses
--------------------------------------------------------------------------------
minime.show("scale_factor", scale_factor)

if scale_factor == 1 then
  minime.writeDebug("Scale factor is 1, skip scaling the corpses!")
else

  for c, corpse in pairs(corpses) do

    minime.writeDebug("Scaling corpse %s (factor: %s)",  {corpse.name, scale_factor})
    -- Adjust size of different boxes
    local box = corpse.selection_box
    if box then
      corpse.selection_box = { scale_position(box[1]), scale_position(box[2]) }
    end

    if corpse.picture then
      minime.writeDebug("Found \"picture\"!")
      recurse(corpse.picture)
    end

    if corpse.pictures then
      minime.writeDebug("Found \"pictures\"!")
      recurse(corpse.pictures)
    end

  end
end


--------------------------------------------------------------------------------
-- Change characters
--------------------------------------------------------------------------------
if scale_factor == 1 then
  minime.writeDebug("Scale factor is 1, skip scaling the characters!")
else


  -- animation_list contains the names of mandatory+optional animations.
  -- There's another property (armors), and other mods may add their own private properties,
  -- so using a list instead of iterating through all values we find will be safer.
  local animation_list = {
    "idle",
    "idle_with_gun",
    "running",
    "running_with_gun",
    "mining_with_tool",
    "flipped_shadow_running_with_gun",
    -- New in Factorio 2.0:
    "take_off",
    "landing",
    "idle_with_gun_in_air",
  }

  -- Scale characters' mining reach along with their graphics?
  local mining_distance = minime.get_startup_setting("minime_scale-reach_resource_distance")

  -- Scale characters' tool-attack distance along with their graphics?
  local tool_attack_distance = minime.get_startup_setting("minime_scale-tool-attack-distance")

  local corpse
  for c, character in pairs(chars) do
    -- Scale character unless we are supposed to ignore it.
    if not (minime.ignore_chars[c] or character.minime_ignore_me) then
      minime.writeDebug("Scaling character \"%s\" (factor: %s)",
                        {character.name, scale_factor})

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
      if minime.get_startup_setting("minime_small-character-collision-box") then
        character.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
        minime.writeDebug("Minimized collision_box of %s", {character.name}, "line")
      end

      -- Scale mining reach
      if mining_distance then
        character.reach_resource_distance = character.reach_resource_distance * scale_factor
        minime.writeDebug("Scaled reach_resource_distance of \"%s\" to %s.",
                      {character.name, character.reach_resource_distance})
      end

      -- Scale tool-attack distance
      if tool_attack_distance then
        character.tool_attack_distance = (character.tool_attack_distance or 1.5) * scale_factor
        minime.writeDebug("Scaled tool_attack_distance of \"%s\" to %s (Default: %s)",
                      {character.name, character.tool_attack_distance or "nil",
                       character.tool_attack_distance/scale_factor})
      end

      -- Apply scale_factor to character graphics
      for _, armor_level in pairs(character.animations) do
        for a, animation in pairs(animation_list) do
          animation = armor_level[animation] or {}
          for p, picture in pairs(animation.layers or {}) do
            scale_image(picture)
          end
        end
      end

      -- Apply scale factor to character.corpse, if it exists
      if character.corpse then
        corpse = corpses[character.corpse]
        if corpse and not corpse.minime_ignore_me then
          recurse(corpse)
        end
      end
    else
      minime.writeDebug("Ignored character %s!", {character.name})
    end
  end
end



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                           Localize default character                           --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

-- If alternative characters are available, it wouldn't be nice if the default
-- character's localized name would be just "Character", so we need to change it to
-- something more meaningful.

local found = false

for name, char in pairs(chars) do
  name = string.upper(name or "")
minime.show("Found character", name)

  -- We'll need at least one alternative character!
  if string.find(name, minime.pattern) then
    minime.writeDebug("%s matches pattern %s!", {name, minime.pattern})
    found = true
    break
  end
end

if found then
  chars["character"].localised_name = {"minime-misc.base-character"}
  minime.writeDebug("Changed name of base character to %s!",
                    {chars["character"].localised_name}, "line")
end

minime.show("Default character (scaled)", chars.character)
minime.show("Default character-corpse (scaled)", corpses["character-corpse"])

------------------------------------------------------------------------------------
minime.entered_file("leave")
