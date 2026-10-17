local season = require("season")
local INTERVAL = 1200 -- Beta 8 cadence: once per 20 game seconds, Nauvis only.
local own_settings = {
  max_night_brightness_percent = true,
  min_night_brightness_percent = true,
  night_brightness_period_days = true,
  nb_debug = true,
  nb_reset = true,
  nb_disabled = true,
}

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
  storage.debug = settings.global.nb_debug.value
  storage.mod_disabled = settings.global.nb_disabled.value
end

local function current_parameters()
  return season.parameters(storage.applied_day, storage.period, storage.minimum, storage.maximum)
end

local function apply_lighting(surface)
  if storage.mod_disabled or storage.applied_day == nil then
    -- Beta 8's non-seasonal baseline; LUT selection remains a startup setting.
    season.set_day_parameters(surface, {dusk = 0.2, evening = 0.3, morning = 0.7, dawn = 0.8})
    surface.min_brightness = storage.mod_disabled and 0.15 or storage.maximum
  else
    local p = current_parameters()
    season.set_day_parameters(surface, p)
    surface.min_brightness = p.min_brightness
  end
  -- In 2.0 the default weights are zero: min_brightness alone no longer dims the LUT.
  surface.brightness_visual_weights = storage.mod_disabled and {0, 0, 0} or {1, 1, 1}
end

local function configure(reset)
  read_settings()
  storage.day = storage.day or 1
  storage.active_solar = storage.active_solar or 1
  if reset then
    storage.day = 0
    storage.applied_day = nil
    storage.season = nil
    storage.pending_solar = nil
    storage.active_solar = 1
  end
  local surface = game.surfaces.nauvis
  if not surface then return end
  apply_lighting(surface)
  apply_solar(surface)
  storage.last_daytime = surface.daytime
end

local function update()
  if storage.mod_disabled then return end
  local surface = game.surfaces.nauvis
  if not surface then return end
  local daytime = surface.daytime
  local last = storage.last_daytime or daytime
  if daytime < last then
    local day = storage.day
    local p = season.parameters(day, storage.period, storage.minimum, storage.maximum)
    -- Preserve Beta 8: short years have no season announcements.
    if p.season ~= storage.season and storage.period > 31 then
      game.print({"night-brightness.season-" .. p.season})
    end
    storage.season = p.season
    storage.applied_day = day
    apply_lighting(surface)
    storage.pending_solar = p.solar
    storage.day = day + 1
    if storage.debug then
      game.print({"night-brightness.debug", day, p.season, p.min_brightness, p.solar})
    end
  elseif daytime > 0.5 and last < 0.5 then
    -- Beta 8 changes solar output at midnight, not in the middle of generation.
    storage.active_solar = storage.pending_solar or 1
    apply_solar(surface)
  end
  storage.last_daytime = daytime
end

script.on_init(function()
  configure(settings.global.nb_reset.value)
end)

script.on_configuration_changed(function(event)
  local removed = event.mod_changes and event.mod_changes["Clockwork-2"]
  local surface = game.surfaces.nauvis
  if surface and removed and removed.old_version and not removed.new_version then
    -- Remove persistent Clockwork timing/freeze settings from an existing 2.0 map.
    surface.ticks_per_day = 25000
    surface.freeze_daytime = false
  end
  configure(false)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if not own_settings[event.setting] then return end
  local was_disabled = storage.mod_disabled
  configure(settings.global.nb_reset.value)
  if was_disabled ~= storage.mod_disabled then
    game.print({storage.mod_disabled and "night-brightness.disabled" or "night-brightness.enabled"})
  end
end)

script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.surfaces[event.surface_index]
  if surface and surface.name == "nauvis" then configure(false) end
end)

script.on_nth_tick(INTERVAL, update)

-- Read-only API for solar-factor composition and technical diagnostics.
remote.add_interface("NightBrightness", {
  get_solar_multiplier = solar_factor,
  get_state = function()
    return {
      day = storage.day,
      applied_day = storage.applied_day,
      season = storage.season,
      period = storage.period,
      active_solar = storage.active_solar,
      pending_solar = storage.pending_solar,
      disabled = storage.mod_disabled,
    }
  end,
})
