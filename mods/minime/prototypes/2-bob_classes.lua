minime.entered_file()

------------------------------------------------------------------------------------
-- If "Bob's Character classes" is active, make a copy of each character for each --
-- class.                                                                         --
------------------------------------------------------------------------------------
if mods["bobclasses"] then

  -- Character properties that are changed by "Bob's Character classes"
  local class_properties = {
    "build_distance",
    "crafting_categories",
    "healing_per_tick",
    "inventory_size",
    "max_health",
    "mining_categories",
    "mining_speed",
    "reach_distance",
    "reach_resource_distance",
    "running_speed",
  }

  -- Characters from character mods
  local skin_chars = {}

  -- Character versions from "Bob's Character classes"
  local bobclass_chars = {}

  local bob_pattern = string.upper("^bob%-character%-")
  local name, new_char
  local chars = data.raw.character

  -- Populate tables
  for char, c_data in pairs(chars) do
    name = char:upper()
    -- Alternative character skins
    if name:find(minime.pattern, 1, true) then
      skin_chars[#skin_chars + 1] = char
      minime.writeDebug("Added %s to skin_chars.", minime.argprint(c_data))
    -- Class character
    elseif name:match(bob_pattern) then
      bobclass_chars[#bobclass_chars + 1] = char
      minime.writeDebug("Added %s to bobclass_chars.", minime.argprint(c_data))
    -- Ignore character
    else
      minime.writeDebug("Ignored %s.", minime.argprint(c_data))
    end
  end
minime.show("skin_chars", skin_chars)
minime.show("bobclass_chars", bobclass_chars)

  -- Create new characters
  local cnt = 0
  for c, char in pairs(skin_chars) do
minime.show("char "..c, chars[char].name)

    chars[char].fast_replaceable_group = "character"
    minime.modified_msg("fast_replaceable_group", chars[char])

    for v, version in pairs(bobclass_chars) do
minime.show("version "..v, chars[version].name)
      new_char = table.deepcopy(chars[char])
      new_char.name = char .. "-" .. version

      new_char.localised_name = chars[char].localised_name and {
        "minime-misc.bobclass-name",
        {"entity-name." .. chars[version].name},
        chars[char].localised_name,
      } or {"entity-name." .. chars[version].name}
minime.show("char.localised_name", chars[char].localised_name or "nil")
minime.show("version.localised_name", chars[version].localised_name or "nil")
minime.show("new_char.localised_name", new_char.localised_name or "nil")

      -- Copy properties from Bob's classes to new character
      for p, property in pairs(class_properties) do
        new_char[property] = table.deepcopy(data.raw.character[version][property])
      end

      data:extend({new_char})
      minime.created_msg(new_char)
      cnt = cnt + 1
    end
  end
minime.show("Number of created characters", cnt)
end



------------------------------------------------------------------------------------
minime.entered_file("leave")
