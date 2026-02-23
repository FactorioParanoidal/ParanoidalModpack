log("Entered file " .. debug.getinfo(1).source)
minime = require("__minime__/common")
log("minime:"..serpent.block(minime, {nocode = true}))

minime.IMG_PATH = minime.modRoot.."/graphics/"

------------------------------------------------------------------------------------
--                     SPRITE NAMES FOR SHORTCUTS AND BUTTONS                     --
------------------------------------------------------------------------------------
minime.sprite_names = {
  button = "toggle-char-selector-gui",
  button_light = nil,
  shortcut = "toggle-char-selector-shortcut",
  shortcut_disabled = "toggle-char-selector-shortcut-disabled",
  shortcut_small = "toggle-char-selector-shortcut-mini",
  shortcut_small_disabled = "toggle-char-selector-shortcut-disabled-mini",
}
------------------------------------------------------------------------------------
--                  CREATE CHARACTERS, CORPSES, AND GUI ELEMENTS                  --
------------------------------------------------------------------------------------
require("prototypes.1-dummy")
require("prototypes.1-corpse")
require("prototypes.1-sprites")
require("prototypes.1-gui")
require("prototypes.1-custom-event")
require("prototypes.1-custom-input")
require("prototypes.1-shortcut")



------------------------------------------------------------------------------------
--                             NOTE TO FELLOW MODDERS                             --
------------------------------------------------------------------------------------
-- This mod will apply a scale factor to character prototypes (graphics and other
-- properties, see prototypes/3-scale_characters.lua) and may create new versions of
-- them (see prototypes/2-bob_classes.lua). The mod will also scale the graphics of
-- character corpse prototypes (see prototypes/3-scale_characters.lua).
--
-- When we've changed the size of characters, we also must take care of the guns they
-- can use, or the muzzle fire from the gun may be totally off. Therefore, we also
-- scale the attack parameters of guns (see prototypes/3-scale_guns.lua).
--
-- You can prevent "minime" from scaling your prototypes by adding a flag:
--
--     my_character = table.deepcopy(data.raw["character"]["character"])
--     ...
--     my_character.minime_ignore_me = true
--
--     my_corpse = table.deepcopy(data.raw["character-corpse"]["character-corpse"])
--     ...
--     my_corpse.minime_ignore_me = true
--
--     my_gun = table.deepcopy(data.raw["gun"]["submachine-gun"])
--     ...
--     my_gun.minime_ignore_me = true
--
--     data:extend({my_character, my_corpse, my_gun})



------------------------------------------------------------------------------------
minime.entered_file("leave")
