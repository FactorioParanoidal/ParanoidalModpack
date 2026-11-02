-- Custom events for other mods (remote get_events).
return {
  on_phase_changed = script.generate_event_name(),
  on_rain_pollution_cleaned = script.generate_event_name(),
}
