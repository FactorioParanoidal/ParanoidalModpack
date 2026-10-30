local season = require("season")

-- Every 5 game seconds look for the midnight on Nauvis. Seasons, light and solar output change at
-- midnight, when the night is at its deepest in every season (daytime 0.5 lies between evening
-- and morning for any tilt), so the step is not visible. The calendar day also starts at midnight,
-- as on the EvoUI clock.
local INTERVAL = 300
local own_settings = {
  max_night_brightness_percent = true,
  min_night_brightness_percent = true,
  night_brightness_period_days = true,
  nb_winter_tint = true,
  nb_debug = true,
  nb_reset = true,
  nb_disabled = true,
}

-- Weights of brightness per colour channel (LuaSurface.brightness_visual_weights): with a smaller
-- blue weight the dark keeps more blue, so winter dusk and nights are a little colder. Daylight
-- (brightness 1) is not affected by the weights.
local WEIGHTS = {1, 1, 1}
local WINTER_WEIGHTS = {1, 1, 0.96}

local SEASON_COLORS = {
  summer = {1, 0.82, 0.3},
  fall = {1, 0.58, 0.25},
  winter = {0.62, 0.82, 1},
  spring = {0.55, 0.92, 0.45},
}
local YEAR_COLOR = {1, 0.75, 0.35}

local function nauvis()
  local surface = game.surfaces.nauvis
  return surface and surface.valid and surface or nil
end

local function solar_factor(surface_index)
  local surface = game.surfaces[surface_index]
  if not surface or surface.name ~= "nauvis" or storage.mod_disabled then return 1 end
  return storage.active_solar or 1
end

local function apply_solar(surface)
  local provider = remote.interfaces["visible-pollutants"]
  if provider and provider.refresh_solar_multiplier then
    -- The pollution mod owns its factor; it composes it with ours, never overwrites it.
    remote.call("visible-pollutants", "refresh_solar_multiplier", surface.index)
  else
    surface.solar_power_multiplier = solar_factor(surface.index)
  end
end

local function read_settings()
  storage.minimum = settings.global.min_night_brightness_percent.value / 100
  storage.maximum = settings.global.max_night_brightness_percent.value / 100
  storage.period = settings.global.night_brightness_period_days.value
  storage.winter_tint = settings.global.nb_winter_tint.value
  storage.debug = settings.global.nb_debug.value
  storage.mod_disabled = settings.global.nb_disabled.value
end

local function cycle_day()
  return storage.calendar_day - storage.cycle_offset
end

local function current_parameters()
  return season.parameters(cycle_day(), storage.period, storage.minimum, storage.maximum)
end

local function current_season()
  if storage.mod_disabled then return nil end
  return storage.season
end

---------------------------------------------------------------------------------------------------
-- Text

local function style_of(player)
  local setting = player.mod_settings["nb_season_names"]
  return setting and setting.value or "plain"
end

local function season_name(key, player)
  return {"night-brightness.name-" .. style_of(player) .. "-" .. key}
end

-- Only the season itself: what it changes (solar, wind, wires) is shown by EvoUI on request.
local function announce_season(key)
  for _, player in pairs(game.players) do
    player.print({"night-brightness.season-" .. style_of(player) .. "-" .. key},
      {color = SEASON_COLORS[key], skip = defines.print_skip.never})
  end
end

local function announce_year()
  local year = storage.year
  for _, player in pairs(game.players) do
    player.print({"night-brightness.year-" .. style_of(player), tostring(year), tostring(year - 1)},
      {color = YEAR_COLOR, skip = defines.print_skip.never})
  end
end

---------------------------------------------------------------------------------------------------
-- Light, solar output and the season of the current calendar day

local function weights(key)
  if key == "winter" and storage.winter_tint then return WINTER_WEIGHTS end
  return WEIGHTS
end

local function apply_day(surface, announce)
  if storage.mod_disabled then
    -- Beta 8's non-seasonal baseline; the LUT stays a startup setting.
    surface.daytime_parameters = {dusk = 0.2, evening = 0.3, morning = 0.7, dawn = 0.8}
    surface.min_brightness = 0.15
    -- Brightness must still darken the picture: the night LUT only covers the short summer night.
    surface.brightness_visual_weights = WEIGHTS
    storage.active_solar = 1
    apply_solar(surface)
    return
  end
  local p = current_parameters()
  surface.daytime_parameters = {dusk = p.dusk, evening = p.evening, morning = p.morning, dawn = p.dawn}
  surface.min_brightness = p.min_brightness
  -- In 2.0 the default weights are zero: min_brightness alone no longer dims the picture.
  surface.brightness_visual_weights = weights(p.season)
  storage.active_solar = p.solar
  apply_solar(surface)
  if p.season ~= storage.season then
    storage.season = p.season
    if announce then announce_season(p.season) end
  end
  if storage.debug then
    game.print({"night-brightness.debug", tostring(storage.calendar_day + 1), tostring(cycle_day()), p.season,
      string.format("%.3f", p.min_brightness), string.format("%.3f", p.solar)})
  end
end

-- The year counts from the landing; a changed year length applies from the current year on.
local function advance_years(announce)
  while storage.calendar_day - storage.year_start >= storage.period do
    storage.year_start = storage.year_start + storage.period
    storage.year = storage.year + 1
    if announce then announce_year() end
  end
end

---------------------------------------------------------------------------------------------------
-- State

-- Calendar of a map that had no calendar yet: midnights since the start of the map, the season
-- that was already applied (NightBrightness 2.0.0 kept it in storage.applied_day) is kept.
local function migrate(surface)
  if storage.calendar_day then return end
  local day = surface and season.midnights_since_start(game.tick, surface.ticks_per_day, surface.daytime) or 0
  storage.calendar_day = day
  storage.cycle_offset = day - (storage.applied_day or 0)
  storage.year = math.floor(day / storage.period) + 1
  storage.year_start = (storage.year - 1) * storage.period
  storage.day, storage.applied_day, storage.pending_solar = nil, nil, nil
end

local function configure(reset, announce)
  read_settings()
  local surface = nauvis()
  migrate(surface)
  if reset then
    -- Restart the seasons from summer; the calendar and the years go on.
    storage.cycle_offset = storage.calendar_day
    storage.season = nil
  end
  advance_years(false)
  if not surface then return end
  apply_day(surface, announce)
  storage.last_daytime, storage.last_tick = surface.daytime, game.tick
end

local function update()
  local surface = nauvis()
  if not surface then return end
  -- A save made with NightBrightness 2.0.0 gets its calendar here, even without a version change.
  if not storage.calendar_day then return configure(false, false) end
  local now = surface.daytime
  local last = storage.last_daytime or now
  local ticks = game.tick - (storage.last_tick or game.tick)
  storage.last_daytime, storage.last_tick = now, game.tick
  if not season.passed_midnight(last, now) then return end
  -- A script that moves the time over midnight (freeplay intro, console) does not add a day.
  if not season.moved_by_itself(last, now, ticks, surface.ticks_per_day, surface.freeze_daytime) then return end
  storage.calendar_day = storage.calendar_day + 1
  advance_years(true)
  apply_day(surface, true)
end

script.on_init(function()
  configure(settings.global.nb_reset.value, false)
end)

script.on_configuration_changed(function(event)
  local removed = event.mod_changes and event.mod_changes["Clockwork-2"]
  local surface = nauvis()
  if surface and removed and removed.old_version and not removed.new_version then
    -- Remove persistent Clockwork timing/freeze settings from an existing 2.0 map.
    surface.ticks_per_day = 25000
    surface.freeze_daytime = false
  end
  configure(false, false)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if not own_settings[event.setting] then return end
  local was_disabled = storage.mod_disabled
  configure(settings.global.nb_reset.value, true)
  if was_disabled ~= storage.mod_disabled then
    game.print({storage.mod_disabled and "night-brightness.disabled" or "night-brightness.enabled"})
  end
end)

script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.surfaces[event.surface_index]
  if surface and surface.name == "nauvis" then configure(false, false) end
end)

script.on_nth_tick(INTERVAL, update)

---------------------------------------------------------------------------------------------------
-- Read-only API: solar factor for visible-pollutants, the calendar and the season for EvoUI,
-- CodexRPG, MxlChievements, Wind-Turbines-Reforged and ElectricResistance2.

local function get_state()
  if not storage.calendar_day then return nil end
  local state = {
    days_passed = storage.calendar_day,          -- midnights since the landing
    day = storage.calendar_day + 1,              -- calendar day, the landing day is day 1
    year = storage.year,                         -- the landing year is year 1
    years_passed = storage.year - 1,
    day_of_year = storage.calendar_day - storage.year_start + 1,
    period = storage.period,
    disabled = storage.mod_disabled,
    active_solar = storage.mod_disabled and 1 or storage.active_solar or 1, -- seasonal factor, before pollution
  }
  local surface = nauvis()
  if surface then
    local parameters = surface.daytime_parameters
    state.dusk, state.evening, state.morning, state.dawn =
      parameters.dusk, parameters.evening, parameters.morning, parameters.dawn
    state.min_brightness = surface.min_brightness
  end
  if not storage.mod_disabled then
    local day = cycle_day()
    state.cycle_day = day
    state.season = storage.season
    state.season_day, state.season_length = season.season_span(day, storage.period)
    -- Days until the next season starts (1 = tomorrow).
    state.days_to_next_season = state.season_length - state.season_day + 1
    local next_index = 1
    for index, key in ipairs(season.NAMES) do
      if key == storage.season then next_index = index % #season.NAMES + 1 end
    end
    state.next_season = season.NAMES[next_index]
  end
  return state
end

remote.add_interface("NightBrightness", {
  get_solar_multiplier = solar_factor,
  get_state = get_state,
  -- "summer", "fall", "winter", "spring"; nil while the cycle is disabled or before the first update.
  get_season = current_season,
  -- Season name in the style the player chose (mod setting "Season names").
  get_season_name = function(key, player_index)
    local player = player_index and game.get_player(player_index)
    if not player or not SEASON_COLORS[key] then return nil end
    return season_name(key, player)
  end,
  get_season_color = function(key) return SEASON_COLORS[key] end,
  -- Clock text (as EvoUI) for a daytime value.
  clock = season.clock,
})
