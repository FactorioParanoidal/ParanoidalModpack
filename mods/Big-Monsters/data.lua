
mf_hp_multiplier  = settings.startup["bm-big-enemy-hp-multiplier"].value
mf_hp_variant     = settings.startup["bm-big-enemy-hp-variant"].value
mf_dmg_multiplier = settings.startup["bm-enemy-damage-multiplier"].value

--optional mods
require "__mferrari_lib__/prototypes/loot"
require "__mferrari_lib__/prototypes/bosses_projectiles"
require "__mferrari_lib__/prototypes/bosses"
require "__mferrari_lib__/prototypes/bosses_armoured"
require "__mferrari_lib__/prototypes/bosses_worms"
require "__mferrari_lib__/prototypes/flying_saucer"
require "__mferrari_lib__/prototypes/sounds"
if mods["space-age"] then 
  require "__mferrari_lib__/prototypes/vulcanus_enemy_variant"
  require "__mferrari_lib__/prototypes/gleba_enemy_variants"
  require "__mferrari_lib__/prototypes/cyborg_strafer"
  make_cyborg_strafer_bosses()
  end

colors = require("__mferrari_lib__/colors")

mf_fh_base_name       = "bm_fake_human"
mf_fh_add_spawner     = false
mf_fh_add_turrets     = true
mf_fh_add_nuker       = true
mf_fh_add_explosive   = true
mf_fh_mechanicus_skin = false
require "__mferrari_lib__/prototypes/fake_humans"


path = '__Big-Monsters__/'
require ("util")
require "prototypes.explosion" --electric blast
require "prototypes.turrets"
require "prototypes.entities"
