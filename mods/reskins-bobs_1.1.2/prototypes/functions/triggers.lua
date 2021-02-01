-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local triggers = {}

-- Angel's Industries
triggers.assembly = {
    burner_assembling_machine_is_small = true
}

if mods["aai-industry"] and mods["angelsrefining"] then
    triggers.assembly.burner_assembling_machine_is_small = false
end

return triggers