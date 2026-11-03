-- Look of defective buildings (user request 2026-11-03, variant chosen 2026-11-04): the worse the defect, the
-- darker the building, with a rust cast, soot on the building and on the ground and dark smoke while working.
-- Shared by data-final-fixes (prototypes/defect-look.lua) and control (scripts/defects/look.lua).
local M = {}

M.mod_data = "ic-defect-look"
-- Silhouettes: prefix .. entity [.. "-" .. direction 1-4 | "-m" .. direction 1-4 for a flipped machine].
M.prefix = "ic-defect-look-"
M.soot_prefix = "ic-defect-look-soot-"
M.soot_variants = 4
M.smoke_prefix = "ic-defect-look-smoke-"

-- Brightness per defect grade (user decision 2026-11-04): -1 = 75%, -2 = 65%, -3 = 55%, -4 = 45%, -5 = 35%.
M.brightness_by_grade = {0.75, 0.65, 0.55, 0.45, 0.35}

-- Entity types whose main graphics give a silhouette. Radars (rotating dish), walls and gates (pictures by
-- neighbours), rocket silos, vehicles and units are left out.
M.types = {
    "assembling-machine", "furnace", "mining-drill", "offshore-pump", "pump", "boiler", "generator",
    "burner-generator", "lab", "lamp", "container", "logistic-container", "linked-container", "proxy-container",
    "electric-pole", "electric-energy-interface", "accumulator", "storage-tank", "inserter", "solar-panel",
    "simple-entity-with-owner", "simple-entity-with-force",
}
-- Machines without their own smoke that puff from the top of their box while working.
M.working_types = {
    ["assembling-machine"] = true, furnace = true, ["mining-drill"] = true, lab = true, boiler = true,
    generator = true, ["burner-generator"] = true,
}

-- Map setting kept for the visual check (2026-11-04): where the darkening is drawn ("object" or "above").
M.layer_setting = "ic-more-qualities-defects-look-layer"

function M.brightness(grade) return M.brightness_by_grade[grade] or 1 end

-- Tint of the silhouette drawn over the building with normal blending. Colors are premultiplied, so
-- result = tint.rgb * frame + background * (1 - tint.a); over the parts of the building that do not move
-- (frame = what is already drawn) every channel becomes background * (tint.rgb + 1 - tint.a).
-- Channel multipliers: red f * (1 + 0.15 s), green f * (1 - 0.02 s), blue f * (1 - 0.30 s), s = grade / 5:
-- the brightness f with a warm brown cast growing with the grade (luminance stays within 1% of f).
function M.tint(grade)
    local f = M.brightness(grade)
    local s = grade / 5
    local r, g, b = f * (1 + 0.15 * s), f * (1 - 0.02 * s), f * (1 - 0.30 * s)
    return {r = r - b, g = g - b, b = 0, a = 1 - b}
end

-- Opacity of the black soot sprites: 0.18 per grade (the texture itself is mostly half transparent).
function M.soot_alpha(grade) return 0.18 * grade end

-- Dark smoke (user decision 2026-11-04: blacker; -5 exactly the train smoke). Share of the train smoke in the
-- smoke of each grade: color and timing are blended from the base "smoke" (0) to "train-smoke" (1); -5 is a
-- copy of train-smoke. Straight shade of the color: -1 0.57, -2 0.36, -3 0.19, -4 0.08, -5 0 (black).
M.smoke_mix = {0.5, 0.7, 0.85, 0.94, 1}
-- Smokes per look (every 20 ticks) of a working defective building.
M.smoke_count = {1, 2, 2, 3, 3}

return M
