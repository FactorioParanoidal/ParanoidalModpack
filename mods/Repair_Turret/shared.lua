-- Constants shared by the data stage and control.lua.
local C = {
  turret = "repair-turret",          -- container: what the player builds, sees and fills with repair packs
  energy = "repair-turret-energy",   -- hidden electric-energy-interface: power input + head animation
  beam = "repair-turret-beam",

  range = 7,                -- base tiles from the turret centre (square 14x14 tiles)
  interval = 31,            -- ticks between shots of one turret
  heal_per_second = 20,     -- base HP/s per beam at full power

  idle_power = 500000,      -- W, constant drain
  energy_per_hp = 50000,    -- J per healed HP (1 MW per 20 HP/s)
  min_buffer = 1000000,     -- J

  eei_offset = 0.0625,      -- the energy entity sits slightly lower so its head animation is drawn over the base

  -- Damage detection without on_entity_damaged: buildings in turret areas are kept in one list
  -- and their health is polled in small portions every tick.
  scan_period = 60,         -- ticks for a full pass over the list (if the per-tick cap allows)
  scan_min = 8,             -- entities checked per tick, at least
  scan_max = 150,           -- entities checked per tick, at most (bigger lists take longer per pass)
  moving_period = 120,      -- ticks between searches for damaged vehicles/characters in one turret's area
  rescan_interval = 300,    -- every N ticks one turret re-reads its area (entities created without events)
}

-- Research branches, all after the repair-turret technology.
-- tier: 1 red, 2 +green, 3 +blue, 4 +purple, 5 +yellow.
C.speed_tech = "repair-turret-speed-"
C.speed_bonus = 0.2         -- +20% HP/s per level
C.speed_levels =
{
  {200, 30, 1}, {250, 30, 1}, {300, 30, 2}, {350, 30, 2}, {400, 45, 3},
  {450, 45, 3}, {500, 60, 4}, {550, 60, 4}, {600, 60, 5}, {700, 60, 5},
}

C.beams_tech = "repair-turret-beams-"   -- +1 simultaneous target per level
C.beams_levels =
{
  {400, 45, 2}, {500, 45, 3}, {600, 60, 4}, {800, 60, 5},
}

C.range_tech = "repair-turret-range-"   -- +1 tile per level
C.range_levels =
{
  {250, 30, 1}, {300, 30, 1}, {350, 30, 2}, {400, 45, 2}, {450, 45, 3},
  {500, 45, 3}, {600, 60, 4}, {700, 60, 4}, {800, 60, 5}, {1000, 60, 5},
}

-- Highest possible draw of one turret (all levels), for the energy prototype.
C.max_power = C.idle_power
  + C.heal_per_second * (1 + C.speed_bonus * #C.speed_levels) * (1 + #C.beams_levels) * C.energy_per_hp

return C
