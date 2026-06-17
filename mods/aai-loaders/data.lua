is_debug_mode = false

if not logged_mods_once then
  logged_mods_once = true
  log("Log mods once: " .. serpent.block(mods))
end
is_debug_log = is_debug_mode
debug_log = is_debug_log and log or function () end

require ("prototypes/phase-1/combined/sprite")
require ("prototypes/phase-1/combined/pipe")
require ("prototypes/phase-1/combined/loaders")
require ("prototypes/phase-1/combined/assembling-machine")

--[[
Hello, and welcome to AAI loaders. This mod allows any mod to request creation of their own tier of
loaders. The function to call is AAILoaders.make_tier(). Described below is the required data:

input = {
  name = <string>, will get auto prefixed and suffixed with 'aai-' .. name .. '-loader'
  transport_belt 	= <string>, name of a valid transport belt entity
  speed = <number(?)>, if not provided, uses belt speed
  color	= <rgb table(?)>, if not provided, uses white
  fast_replaceable_group = <string(?)>, fast replace group, if not provided uses the FRG of the transport belt
  fluid = <string>, the fluid name to use in lubricated mode
  fluid_per_minute = <number>, the fluid usage per minute.
  fluid_technology_prerequisites = <table(?)>, list of additional required technologies in lurbricated mode
  technology	= {
    name = <string>, if tech of that name already exists, discard the rest
    unit = {
      count = <number>,
      ingredients = <table> of packs,
      time = <number>
    },
    prerequisites = <table(?)>, list of required technologies; if missing, accesible from the start
  },
  recipe = {
    name = <string(?)>, name of recipe; if not provided, use loader name
    crafting_category = <string(?)>, name of crafting category, defaults to 'crafting'
    ingredients	= <table>, of ingredients,
    energy_required	= <uint>, time to craft,
  },
  unlubricated_recipe = ..., -- As recipe. Used when in the unlubricated "expensive" mode.

  -- If not specified the normal recipe will be used x10. This recipe should be roughly 10x, but specific items (like the previous loader tier) can be set to 1.
  collision_mask = <table(?)>, CollisionMask table as specified in the Factorio API docs
  order = <string>, order string,
  upgrade	= <string(?)>, loader name to upgrade to, if any
  localise = <bool(?)>, if set to true, try to auto localise the item, tech, recipe, and entity. will be based on the transport belt name (Space Transport belt Loader)
  }
]]

if mods["IndustrialRevolution3"] or mods["IndustrialRevolution"] then
  require("prototypes/loader-sets/industrial-revolution")
elseif mods["aai-industry"] then
  require("prototypes/loader-sets/aai-industry")
  if mods["space-age"] then
    require("prototypes/loader-sets/space-age")
  end
else -- Vanilla
  require("prototypes/loader-sets/base")
  if mods["space-age"] then
    require("prototypes/loader-sets/space-age")
  end
end
