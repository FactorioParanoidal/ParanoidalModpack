-- Two startup switches of the Paranoidal build (data and control stage):
--   quality: off - the mod adds nothing (no new qualities, no defects), as if it were disabled;
--   defects: the defect system (defect qualities, quality-control research, workshop, post, modes);
--            needs quality.
-- Other mods read the same two settings (zzzparanoidal quality modules, Bio_Industries_2 gardens).
local M = {}

function M.quality()
    local setting = settings.startup["ic-more-qualities-quality"]
    return setting == nil or setting.value ~= false
end

function M.defects()
    local setting = settings.startup["ic-more-qualities-defects-preview"]
    return M.quality() and setting ~= nil and setting.value == true
end

return M
