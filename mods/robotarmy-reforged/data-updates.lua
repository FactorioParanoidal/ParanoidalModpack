local shared = require("lib.shared")

-- Recipes and technologies use items and technologies of other mods (Bob's, Angels,
-- Paranoidal), which all exist once every data.lua has run.
require("prototypes.recipes")
require("prototypes.technologies")

-- Optional (startup setting, off by default): ground acid puddles of worms/spitters deal no damage.
-- This is a global change that affects every entity, not only droids.
if settings.startup[shared.setting.acid_splash].value then
  for name, fire in pairs(data.raw.fire) do
    if name:find("acid-splash-fire", 1, true) then
      fire.on_damage_tick_effect = nil
    end
  end
end
