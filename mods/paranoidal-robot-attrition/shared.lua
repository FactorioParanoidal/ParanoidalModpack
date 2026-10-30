-- Names and numbers shared by the data and control stages.
local M = {
  setting = "pra-crash-factor",               -- runtime-global: crash rate multiplier
  setting_cargo = "pra-dangerous-cargo",      -- runtime-global: dangerous cargo on/off
  setting_alerts = "pra-crash-alerts",        -- runtime-per-user: crash alerts
  setting_panel = "pra-roboport-panel",       -- runtime-per-user: panel next to the roboport window

  technology = "pra-swarm-safety",
  dispatch_prefix = "pra-swarm-dispatch-",
  wreck_entity = "pra-drone-wreck",
  wreck_item_prefix = "pra-wreck-",
  repair_recipe_prefix = "pra-repair-",
  explosion_entity = "pra-crash-explosion",
  cargo_explosion_entity = "pra-cargo-explosion",
  fire_entity = "fire-flame",
  cargo_data = "pra-cargo",
  tips_category = "pra-robot-attrition",
  panel_name = "pra-panel",

  -- Ticks between two checks. The expected crash rate does not depend on it.
  interval = 60,
  -- Networks with this many busy logistic robots or fewer never crash.
  min_busy = 50,
  -- Expected crashes per tick of a network =
  --   (busy × busy_weight + waiting to charge × queue_weight) × risk × factor × multipliers × rate_scale.
  -- With 10% of the busy robots waiting the rate equals the plain busy × risk of version 9.0.0.
  busy_weight = 0.5,
  queue_weight = 5,
  rate_scale = 1e-6,
  -- Risk = moving average of speed (tiles/tick) × (carried items + carried_self) of the robots picked so far.
  risk_start = 0.1,
  risk_weight = 0.1,
  carried_self = 0.5,
  -- Prototype speeds above this (cheat robots) count as this.
  max_speed = 1,
  -- At most this share of the busy robots of a network crash in one check.
  max_share = 0.5,

  -- Swarm safety: each level removes the explosion and the fire in networks with up to this many busy robots.
  safety_per_level = 500,
  -- Swarm dispatch: each researched level multiplies the crash rate.
  dispatch_levels = 5,
  dispatch_multiplier = 0.85,
  -- Reliability of a picked robot: crash chance = (reference health / robot health) × quality_k / (quality_k + level).
  quality_k = 10,
  -- Storm (Wind-Turbines-Reforged): above storm_start of full wind output the rate rises by 1 per storm_span,
  -- output counted up to storm_cap (winter wind exceeds full power).
  storm_start = 0.8,
  storm_span = 0.2,
  storm_cap = 1.2,

  -- Repair of a wreck: repair packs used and the chance to get the robot back.
  repair_packs = 2,
  repair_success = 0.75,
  repair_time = 10,
  -- Share of an explosive cargo destroyed by its detonation; fuel from this energy per item burns.
  explosive_loss = 0.5,
  flammable_fuel_value = 10e6,

  -- At most one crash alert per force and surface in this many ticks.
  alert_interval = 5 * 3600,
}

return M
