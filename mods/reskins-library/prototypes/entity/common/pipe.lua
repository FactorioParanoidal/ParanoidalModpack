-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE in the project directory for license information.

-- Overwrite the vanilla pipe cover function
pipecoverspictures = function()
    return reskins.lib.pipe_covers({material = "iron", mod = "lib", group = "common"})
end