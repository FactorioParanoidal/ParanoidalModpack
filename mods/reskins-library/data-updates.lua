-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Assign icons deferred to data-updates at the beginning of the stage.
reskins.internal.assign_icons_deferred_to_stage(reskins.lib.defines.stage.data_updates)

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
require("prototypes.entity.base.nuclear-reactor")

-- Reskin the vanilla pipes
data.raw["pipe"]["pipe"].pictures = reskins.lib.sprites.pipes.get_pipe("iron")
data.raw["pipe-to-ground"]["pipe-to-ground"].pictures = reskins.lib.sprites.pipes.get_pipe_to_ground("iron")
data.raw["pipe-to-ground"]["pipe-to-ground"].fluid_box.pipe_covers = reskins.lib.sprites.pipes.get_pipe_covers("iron")
