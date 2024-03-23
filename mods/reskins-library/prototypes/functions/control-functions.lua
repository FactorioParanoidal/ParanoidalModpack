-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

local functions = {}

function functions.on_init() -- Called by migration/reskins-library_1.1.3.lua
    -- Check for each of the reskin mods, and set the notification status to true if they are detected otherwise, set to false
    global.notify = {
        bobs = {
            status = game.active_mods["reskins-bobs"] and true or false,
        },
        angels = {
            status = game.active_mods["reskins-angels"] and true or false,
        },
        compatibility = {
            status = game.active_mods["reskins-compatibility"] and true or false,
        },
    }
end

return functions