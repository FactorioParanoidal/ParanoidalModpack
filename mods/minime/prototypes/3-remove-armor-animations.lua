minime.entered_file()
------------------------------------------------------------------------------------

if not minime.get_startup_setting("minime_remove-armor-animations") then
  minime.entered_file("leave", "keeping character armor animations")
  return
end

minime.ignore_chars = minime.ignore_chars or minime.get_ignore_characters()
minime.show("Won't remove animations of these characters", minime.ignore_chars)

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                             Remove armor animations                            --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

for name, char in pairs(data.raw["character"]) do
  if not minime.ignore_chars[name] then
    minime.writeDebug("Trying to remove armor animations from %s!",
                      {minime.enquote(name)})

    for a, anim in pairs(char.animations) do
      if anim.armors then
        minime.writeDebug("Removing animation %s (armors: %s)",
                          {a, anim.armors}, "line")
        char.animations[a] = nil
      end
    end
  end
end


------------------------------------------------------------------------------------
minime.entered_file("leave")
