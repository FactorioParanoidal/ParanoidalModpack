-- Generates ground digger assembling machines for every planet that enabled them via
-- PlanetsLib.enable_ground_diggers(). This runs during data-final-fixes so that all
-- modded mining drills and recipes defined in every earlier stage are available.
require("lib.ground-diggers").generate_ground_diggers()
