-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Reskin the vanilla pipes
data.raw["pipe"]["pipe"].pictures = reskins.lib.pipe_pictures({material = "iron", mod = "angels", group = "common"})
data.raw["pipe-to-ground"]["pipe-to-ground"].pictures = reskins.lib.underground_pipe_pictures({material = "iron", mod = "angels", group = "common"})