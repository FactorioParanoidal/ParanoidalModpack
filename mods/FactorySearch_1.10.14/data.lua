require "prototypes.shortcuts"
require "prototypes.custom-input"
require "prototypes.sprite"
require "prototypes.style"

-- Add proper corpse icon to corpse entity instead of the same icon as a character
-- Icon from Space Exploration with permission from Earendel
local character_corpse = data.raw["character-corpse"]["character-corpse"]
if character_corpse and character_corpse.icon == "__core__/graphics/icons/entity/character.png" then
  character_corpse.icon = "__FactorySearch__/graphics/character-corpse.png"
  character_corpse.icon_size = 64
  character_corpse.icon_mipmaps = 1
end