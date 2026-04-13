minime.entered_file()

------------------------------------------------------------------------------------
--                 SCALE CHARACTERS, CORPSES, AND PERSONAL WEAPONS                --
------------------------------------------------------------------------------------
require("prototypes.3-corpse")
require("prototypes.3-dummy")
require("prototypes.3-remove-armor-animations") -- This should run before scaling!
require("prototypes.3-scale_characters")
require("prototypes.3-scale_guns")


------------------------------------------------------------------------------------
--                                  TESTING AREA                                  --
------------------------------------------------------------------------------------
--~ local names = {}
--~ for char, c in pairs(data.raw.character) do
  --~ names[#names + 1] = char
--~ end
--~ minime.show("Found characters", names)
--~ error("Break!")


------------------------------------------------------------------------------------
minime.entered_file("leave")
