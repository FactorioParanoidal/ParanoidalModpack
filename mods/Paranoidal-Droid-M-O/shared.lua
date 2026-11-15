-- Names and numbers both stages use. Д-ОК (M-O in English): the Microbe Obliterator of the BnL starliners.
local shared = {}

shared.mod = "__Paranoidal-Droid-M-O__"
shared.bot = "droid-m-o"
shared.dock = "droid-m-o-dock"
-- What the bot scrubs at: units only attack entities, and most contaminants aren't units (or aren't entities at all).
shared.proxy = "droid-m-o-contaminant"
shared.siren = "droid-m-o-siren"
shared.charging = "droid-m-o-charging"
shared.technology = "droid-m-o"
shared.scrub_effect = "droid-m-o-scrub"
shared.ammo_category = "droid-m-o-scrub"
shared.dust = "droid-m-o-dust"
shared.dust_smoke = "droid-m-o-dust-smoke"
shared.death_cry = "droid-m-o-death-cry"
-- Followed by a decorative's name: what flies off it when scrubbed (data-final-fixes.lua).
shared.scrubbed = "droid-m-o-scrubbed-"
-- The dirt a character (or a vehicle) brings onto the paving from the ground.
shared.footprints = "droid-m-o-footprints"
shared.mud = "droid-m-o-mud"

shared.settings =
{
  graphics = "droid-m-o-graphics",
  tracks = "droid-m-o-tracks",
  chase = "droid-m-o-chase-players",
  texts = "droid-m-o-scanner-texts",
  voice = "droid-m-o-voice"
}

-- Sounds the script plays (prototypes/sounds.lua): his voice, after Ben Burtt's "universal language of intonation"
-- ("Oh", "Hm?", "Huh!"), synthesised for the mod, and the machine noises around it.
shared.sounds =
{
  connect = "droid-m-o-connect",
  disconnect = "droid-m-o-disconnect",
  charge = "droid-m-o-charge",
  scan = "droid-m-o-scan",
  gasp = "droid-m-o-gasp",
  siren = "droid-m-o-siren-wail",
  huh = "droid-m-o-huh",
  hm = "droid-m-o-hm",
  grumble = "droid-m-o-grumble",
  scream = "droid-m-o-scream",
  all_clean = "droid-m-o-all-clean",
  name = "droid-m-o-name",
  warble = "droid-m-o-warble",
  whoa = "droid-m-o-whoa",
  low_battery = "droid-m-o-low-battery",
  yelp = "droid-m-o-yelp",
  gotcha = "droid-m-o-gotcha",
  pickup = "droid-m-o-pickup",
  clank = "droid-m-o-clank",
  unload = "droid-m-o-unload"
}

shared.movement_speed = 0.045
-- Half the width of its square collision box.
shared.bot_size = 0.3
-- Before any research: joules, and watts while it is docked.
shared.battery_capacity = 1200000
shared.charging_power = 40000

-- Every tile that isn't paved (can't be mined back up) is on this layer, which the bot collides with.
shared.unpaved = "droid-m-o-unpaved"

-- Upgrades, a technology per level: each researched level adds its bonus to the base battery capacity or charging rate.
shared.battery_technology = "droid-m-o-battery"
shared.battery_levels = 4
shared.battery_bonus = 1
shared.charging_technology = "droid-m-o-charging"
shared.charging_levels = 3
shared.charging_bonus = 1

-- His translucent dirt bin: what he picks up and breaks off rides home in it.
shared.backpack_slots = 4

-- Where the graphics put things, per graphics option: the brush's reach ahead of his centre (where he parks from what
-- he scrubs), and the top of his head (where the siren rises), in tiles up from the floor.
shared.graphics =
{
  own = {brush_reach = 0.42, head_top = 0.61},
  overlay = {brush_reach = 0.65, head_top = 0.86}
}

return shared
