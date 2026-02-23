minime.entered_file()
------------------------------------------------------------------------------------

minime.ignore_chars = minime.ignore_chars or minime.get_ignore_characters()
minime.show("Won't check guns_inventory_size of  these characters",
            minime.ignore_chars)

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--        Set guns_inventory_size of dummy to maximum size among characters       --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local chars = data.raw.character
local dummy = chars[minime.dummy_character_name]

local guns = dummy.guns_inventory_size or 3
minime.show("guns of dummy", guns)

minime.writeDebugNewBlock("Checking guns_inventory_size of characters!")
for name, char in pairs(chars) do
  if name ~= dummy.name and not minime.ignore_chars[name] then
    minime.writeDebug("Dummy vs. %s: %s vs. %s",
                      {minime.argprint(char), guns, char.guns_inventory_size or 3})
    guns = math.max(guns, char.guns_inventory_size or 3)
  end
end

minime.writeDebugNewBlock("Dummy must have %s gun slots!", {guns})
dummy.guns_inventory_size = guns


------------------------------------------------------------------------------------
minime.entered_file("leave")
