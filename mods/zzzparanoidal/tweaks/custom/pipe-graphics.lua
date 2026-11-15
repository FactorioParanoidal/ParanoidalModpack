-- Shared pipe icon assets live in Reskins; keep descriptors and tier marks at their consumers.
local M = {}

-- Iron and wooden entities/items start with their owners' icons. Redirect their copies
-- in the final graphics visitor, after the wooden entity rebuild and recipe presentation.
M.icon_remap = {
    ["__base__/graphics/icons/pipe.png"] = { "__reskins-library__/graphics/icons/common/pipe/iron-pipe-icon.png", "reskins-library" },
    ["__base__/graphics/icons/pipe-to-ground.png"] = { "__reskins-library__/graphics/icons/common/pipe-to-ground/iron-pipe-to-ground-icon.png", "reskins-library" },
    ["__Bio_Industries_2__/graphics/icons/entity/wood_pipe.png"] = { "__reskins-library__/graphics/icons/common/pipe/wood-pipe-icon.png", "reskins-library" },
    ["__Bio_Industries_2__/graphics/icons/entity/pipe-to-ground-wood.png"] = { "__reskins-library__/graphics/icons/common/pipe-to-ground/wood-pipe-to-ground-icon.png", "reskins-library" },
    -- Bob 2.1 retains ceramic entities, but Reskins no longer assigns their icons.
    ["__boblogistics__/graphics/icons/pipe/ceramic-pipe.png"] = { "__reskins-bobs__/graphics/icons/logistics/pipe/ceramic-pipe-icon.png", "reskins-bobs" },
    ["__boblogistics__/graphics/icons/pipe/ceramic-pipe-to-ground.png"] = { "__reskins-bobs__/graphics/icons/logistics/pipe-to-ground/ceramic-pipe-to-ground-icon.png", "reskins-bobs" },
}

local function available(filename)
    local owner = filename and filename:match("^__([^/]+)__/")
    return not owner or owner == "base" or owner == "core" or not not mods[owner]
end

-- An optional asset owner may be absent: keep the existing icon, not a partial
-- layer stack. Menu placement/order is independent of this cosmetic guard.
function M.icon_available(icon)
    if not available(icon.icon) then return false end
    for _, layer in ipairs(icon.icons or {}) do
        if not available(layer.icon) then return false end
    end
    return true
end

return M
