events =
{
  -- Called when charging of an entity begins.
  -- entity: the entity that is now charging
  -- grid: The equipment grid being supplied with energy. Can be different from entity.grid, so use this value instead.
  -- charging_entityes: array of player-placed entities associated with charging process.
  on_charging_started = script.generate_event_name(),
  -- Called when an entity is no longer being charged because it moved out of range, something was destroyed, etc.
  -- entity: the affected entity
  -- grid: The equipment grid no longer being supplied with energy. Can be different from entity.grid, so use this value instead.
  -- charging_entityes: array of player-placed entities that were associated with the charging process.
  on_charging_stopped = script.generate_event_name(),
}

remote.add_interface("wireless-charging-lib", {
  --- Register a new equipment type to be recognized by inductors. It should be a "battery-equipment" type and have its "usage_priority" set to "primary-output".
  -- @param data A table containing these values:
  --   name: The name of the equipment prototype
  --   efficiency (optional): determines how much received energy is converted to electricity (default 1)
  ["register-inductor-equipment"] = register_inductor_equipment,
  --- Register a new entity that should act as an inductive charging spot.
  -- @param data A table containing these values:
  --   name: the name of the entity prototype
  --   interface_name: the name of the invisible electric-energy-interface to be placed at the given position
  --   offset_x (optional): where to position the recharging spot relative to the entity's center on the X axis
  --   offset_y (optional): where to position the recharging spot relative to the entity's center on the Y axis
  --   efficiency (optional): determines how much stored electricity is converted to energy (default 1)
  -- The entity specified with "interface_name" is used as energy source for the power transmission. It is up to you how it looks and how much power it supports. It is created automatically when the entity specified by "name" is built and removed when it is destroyed. The charging hot spot is always in the middle. The collision box should be chosen so that the visual representation overlaps with the power grid.
  -- IMPORTANT: Make sure the "interface_name" prototype has the flags "not-blueprintable" and "not-deconstructable"! Recommended are also "not-on-map" and "placeable-off-grid".
  ["register-inductor-entity"] = register_inductor_entity,
  --- Get a table containing all custom event names
  ["events"] = function() return events end,
  --- Manually trigger the placement of an inductor at a given position. This does not register the entity prototype to be automatically placed contrary to register-inductor-entity.
  -- @param entity The owning entity to consider as owner. When this entity is destroyed the inductor is removed as well. It must have a valid unit_number property.
  -- @param data The same table as provided to "register-inductor-entity".
  ["place-inductor"] = on_external_inductor_placed,
  --- Manually trigger the removal of an inductor. Makes sure all data and auxiliary entities are properly removed. You still have to destroy the entity afterwards yourself.
  -- @param entity The owning entity to consider as owner. When this entity is destroyed the inductor is removed as well. It must have a valid unit_number property.
  -- @param data The same table as provided to "register-inductor-entity".
  ["remove-inductor"] = on_external_inductor_removed,
})
