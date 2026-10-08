require("prototypes.utils")
require("prototypes.remove-tech-final")

local conf_early_quality = settings.startup["ic-more-qualities-early-quality"].value

if conf_early_quality then
    require("prototypes.early-quality-final")
end

if settings.startup["ic-more-qualities-defects-preview"].value then
    data:extend(require("prototypes.defects-preview").prepare(data.raw))
    if mods["zzzparanoidal"] then
        require("prototypes.defects-quality-modules")(data.raw)
    end
    local startup = settings.startup
    local prototypes, report = require("prototypes.defects-final").apply(data.raw, {
        mode = startup["ic-more-qualities-defects-ingredient-mode"].value,
        supply_reduction = startup["ic-more-qualities-defects-pole-supply-reduction"].value,
        wire_reduction = startup["ic-more-qualities-defects-pole-wire-reduction"].value,
    })
    data:extend(prototypes)
    for _, line in ipairs(report) do log(line) end
end