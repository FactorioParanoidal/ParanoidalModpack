---
--- Migration script: remove the storage.pressures cache.
--- Pressure is now read per surface via LuaSurface.get_property, so the cache
--- (which only covered planets and crashed on other surfaces) is obsolete.

log("start migration to 2.2.4")
storage.pressures = nil
log("migration to 2.2.4 finished")
