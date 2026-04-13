minime.entered_file()

------------------------------------------------------------------------------------
--                                 Local functions                                --
------------------------------------------------------------------------------------
local scale_factor = minime.minime_character_scale
minime.show("scale_factor", scale_factor)

local scale_types = {}

-- Multiply numbers or vectors with a factor
local function scale(property)
  local ret

  if type(property) == "number" then
    ret = property * scale_factor
  elseif type(property) == "table" and table_size(property) == 2 and
          type(property[1]) == "number" and type(property[2]) == "number" then
    ret = {property[1] * scale_factor, property[2] * scale_factor}
  end

  return ret
end

-- Scale projectiles
scale_types.projectile = function(data)
  if data then
    for p, property in pairs({
      "projectile_center",
      "projectile_creation_distance",
      "projectile_orientation_offset"
    }) do

      data[property] = data[property] and scale(data[property])
    end

    if data.shell_particle then
      for p, property in pairs({
        "height",
        "height_deviation",
        "center",
        "creation_distance"
      }) do

        data.shell_particle[property] = data.shell_particle[property] and scale(data.shell_particle[property])
      end
    end

    for p, parameter in pairs(data.projectile_creation_parameters or {}) do
      if type(parameter) == "table" and parameter[2] then
       data.projectile_creation_parameters[p][2] = scale(parameter[2])
      end
    end
  end
end


-- Scale beams
scale_types.beam = function(data)
  if data then
    data.projectile_creation_distance = scale(data.projectile_creation_distance)
    data.source_offset = scale(data.source_offset)
  end
end


-- Scale streams
scale_types.stream = function(data)
  if data then
    for p, property in pairs({
      "gun_barrel_length",
    }) do

      data[property] = data[property] and scale(data[property])
    end

    -- May be vector or table of vectors
    if data.gun_center_shift then
      if data.gun_center_shift["north"] then
        for d, direction in pairs(data.gun_center_shift) do
          data.gun_center_shift[d] = scale(direction)
        end
      else
        data.gun_center_shift = scale(data.gun_center_shift)
      end
    end

    for p, parameter in pairs(data.projectile_creation_parameters or {}) do
      if type(parameter) == "table" and parameter[2] then
       data.projectile_creation_parameters[p][2] = scale(parameter[2])
      end
    end
  end
end



------------------------------------------------------------------------------------
--                         Find guns that should be scaled                        --
------------------------------------------------------------------------------------
local guns = data.raw.gun
local gun_type, personal_gun

ignore_patterns = {
  "car",
  "spidertron",
  "tank",
  "turret",
  "vehicle",
  "wagon",
  "^heli%-" ,    -- HelicopterRevival
}

for g, gun in pairs(guns) do
  -- Always ignore guns that have the ignore flag set
  if gun.minime_ignore_me then
    personal_gun = false
    minime.writeDebug("%s: Found flag \"minime_ignore_me\"!", {g})
  -- Also ignore guns with a name matching a pattern from the ignore list
  else
    personal_gun = true
    for p, pattern in pairs(ignore_patterns) do
      -- Look for literal strings first, then for regular expressions
      if g:find(pattern, 1, true) or g:find(pattern) then
        personal_gun = false
        minime.writeDebug("%s: Matching pattern \"%s\" from ignore list!", {g, pattern})
        break
      end
    end
  end

  if personal_gun then
    gun_type = gun.attack_parameters and gun.attack_parameters.type

    if gun_type then
      scale_types[gun_type](gun.attack_parameters)
      minime.writeDebug("name: %s\t%s", {g, gun})
    end
  else
    minime.writeDebug("%s seems to be a gun for turrets or vehicles -- ignored it!", {g})
  end
end


------------------------------------------------------------------------------------
minime.entered_file("leave")
