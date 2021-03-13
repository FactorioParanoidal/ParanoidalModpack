-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Override circuit style settings in reskins-bobs when Circuit Processing is present
if mods["CircuitProcessing"] then
    reskins.lib.setting_override("string-setting", "reskins-bobs-do-bobelectronics-circuit-style", "off")
end