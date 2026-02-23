minime.entered_file()
------------------------------------------------------------------------------------

local corpses   = data.raw["character-corpse"]
--~ local default   = corpses["character-corpse"]
local generic   = corpses[minime.modName.."_generic_corpse"]


-- Set corpse.armor_picture_mapping (all armors use the same picture)!
generic.armor_picture_mapping = {}
for a_name, armor in pairs(data.raw.armor) do
  minime.writeDebug("Adding armor_picture_mapping for %s to %s!",
                    {a_name, generic.name})
  generic.armor_picture_mapping[a_name] = 1
end

------------------------------------------------------------------------------------
minime.entered_file("leave")
