require "prototypes.spiderling"
require "prototypes.spidertron-dock"
require "prototypes.equipment-grid"
require "prototypes.custom-input"
require "prototypes.spidertron-remote"
require "prototypes.technology"
require "prototypes.style"
require "prototypes.sprite"
require "prototypes.tips-and-tricks"
sp_data_stage = "data"
require "prototypes.nullius"
require "prototypes.industrial-revolution"
require "prototypes.space-exploration"
require "prototypes.signal"

data:extend{{
  type = "custom-event",
  name = "on_spidertron_given_new_destination",
}}

data:extend{{
  type = "custom-event",
  name = "on_spidertron_patrol_waypoint_reached",
}}

-- Remove all military science, rocket launchers, etc from spidertrons if the setting is enabled
if settings.startup["sp-remove-military-requirement"].value then
  if settings.startup["sp-enable-spiderling"].value then
    data.raw["spider-vehicle"]["sp-spiderling"].guns = nil
    for i, ingredient in pairs(data.raw.recipe["sp-spiderling"].ingredients) do
      if ingredient.name == "rocket-launcher" then
        table.remove(data.raw.recipe["sp-spiderling"].ingredients, i)
        break
      end
    end

    for i, ingredient in pairs(data.raw.technology["sp-spiderling"].unit.ingredients) do
      if ingredient[1] == "military-science-pack" then
        table.remove(data.raw.technology["sp-spiderling"].unit.ingredients, i)
        break
      end
    end
    table.remove(data.raw.technology["sp-spiderling"].prerequisites, 6)  -- Remove rocketry from spiderling prereqs
    table.remove(data.raw.technology["sp-spiderling"].prerequisites, 5)  -- Remove military-3 from spiderling prereqs
    table.insert(data.raw.technology["spidertron"], "rocketry")
  end

  if settings.startup["sp-enable-dock"].value then
    for i, ingredient in pairs(data.raw.technology["sp-spidertron-automation"].unit.ingredients) do
      if ingredient[1] == "military-science-pack" then
        table.remove(data.raw.technology["sp-spidertron-automation"].unit.ingredients, i)
        break
      end
    end
  end
end
