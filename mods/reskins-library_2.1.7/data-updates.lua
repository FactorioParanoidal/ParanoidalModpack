-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
require("prototypes.entity.base.nuclear-reactor")


-- Reskin the vanilla pipes
data.raw["pipe"]["pipe"].pictures = reskins.lib.get_pipe_pictures("iron")
data.raw["pipe-to-ground"]["pipe-to-ground"].pictures = reskins.lib.get_pipe_to_ground_pictures("iron")
data.raw["pipe-to-ground"]["pipe-to-ground"].fluid_box.pipe_covers = reskins.lib.get_pipe_covers("iron")

-- Assign deferred icons
reskins.lib.assign_deferred_icons("lib", "data-updates")
