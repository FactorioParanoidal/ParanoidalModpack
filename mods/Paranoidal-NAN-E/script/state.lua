-- storage.nan_e: everything the mod keeps. state.s is set in on_init/on_load (control.lua).
local state = {}

state.s = nil

state.new_storage = function()
  return
  {
    players = {},   -- [player_index] = her data for that player (script/nanny.lua)
    forces = {},    -- [force_index] = memory and case of a team (script/memory.lua)
    husks = {},     -- [unit_number] = {entity, kind = "found"|"knocked"|"new", owner, boot_tick, repairer}
    gui = {},       -- [player_index] = {page, fragment}
    axiom6 = {state = "searching"},   -- her place at the Axiom-6: searching | placed | none
    ruins = {list = {}, seeded = 0},  -- ruins spawned by paranoidal-ruins: for rewards, and cards seeded in them
    rain = {}       -- [surface_index] = {raining = bool, checked = tick}
  }
end

-- Missing keys of an older storage are added (a newer version of the mod), nothing is reset.
state.fill = function(s)
  for key, value in pairs(state.new_storage()) do
    if s[key] == nil then
      s[key] = value
    end
  end
end

return state
