-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
require("prototypes.entity.base.nuclear-reactor")



-- Reskin the vanilla pipes
data.raw["pipe"]["pipe"].pictures = reskins.lib.pipe_pictures({material = "iron", mod = "lib", group = "common"})
data.raw["pipe-to-ground"]["pipe-to-ground"].pictures = reskins.lib.underground_pipe_pictures({material = "iron", mod = "lib", group = "common"})
data.raw["pipe-to-ground"]["pipe-to-ground"].fluid_box.pipe_covers = reskins.lib.pipe_covers({material = "iron", mod = "lib", group = "common"})

-- Assign deferred icons
reskins.lib.assign_deferred_icons("lib", "data-updates")