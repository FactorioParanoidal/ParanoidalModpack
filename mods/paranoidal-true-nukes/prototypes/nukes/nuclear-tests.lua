-- Nuclear tests (Paranoidal 9.0.0, user decision "A", 2026-11-15): these technologies have a "scripted"
-- research trigger and are researched when every listed detonation has been set off in a test site of the
-- force while their prerequisites are researched. Plain data, read by the data stage and by control.lua.
-- The 1.1 mod used test packs as lab ingredients; the 2.x port turned them into craft-item triggers of a
-- recipe with two results, which the one-slot furnace test site refused, so the triggers never fired.
return {
  ["full-fission-atomics"] = {"detonation-atomic-500t-1"},
  ["compact-full-fission-weapons"] = {"detonation-atomic-15kt-1", "detonation-atomic-20t-3"},
  ["compact-fusion-weapons"] = {"detonation-atomic-2-stage-100kt-1"},
}
