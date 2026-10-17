local PlannerIcons = {}

---@param prototype data.ResourceEntityPrototype | data.TilePrototype
function PlannerIcons.CreateLayeredIcon(prototype)
    local backgroundIconSize = 56
    local overallLayeredIconScale = 0.5
    local prototypeIconSize = prototype.icon_size or 64

    local layeredIcons = {
        {
            icon = BPSB.path .. "/graphics/wrapper-x56.png",
            icon_size = backgroundIconSize,
            tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
        },
    }

    local foundIcon = false
    if prototype.icons then
        foundIcon = true
        -- Complex Icons approach (layer but re-scale each)
        for _, icon in pairs(prototype.icons) do
            local thisIconScale = 1.0
            if icon.scale then
                thisIconScale = icon.scale
            end
            table.insert(layeredIcons, {
                icon = icon.icon,
                icon_size = icon.icon_size or prototypeIconSize,
                tint = icon.tint,
                shift = icon.shift,
                scale = thisIconScale * overallLayeredIconScale * (backgroundIconSize / (icon.icon_size or prototype.icon_size)),
            })
        end
    elseif prototype.icon then
        foundIcon = true
        -- The simplest Icon approach
        table.insert(layeredIcons, {
            icon = prototype.icon,
            icon_size = prototypeIconSize,
            scale = overallLayeredIconScale * (backgroundIconSize / prototypeIconSize),
        })
    elseif prototype.variants and prototype.variants.main then
        foundIcon = true
        -- Slightly complex Tile approach
        local image = prototype.variants.main[1]
        local thisImageScale = 1.0
        if image.scale then
            thisImageScale = image.scale
        end
        local thisImageSize = (image.size or 1.0) * 32 / thisImageScale
        table.insert(layeredIcons, {
            icon = image.picture,
            icon_size = thisImageSize,
            tint = prototype.tint,
            scale = thisImageScale * overallLayeredIconScale * (backgroundIconSize / thisImageSize),
        })
    elseif prototype.variants and prototype.variants.material_background then
        foundIcon = true
        -- Slightly complex Tile approach
        local image = prototype.variants.material_background
        local thisImageScale = 1.0
        if image.scale then
            thisImageScale = image.scale
        end
        local thisImageSize = (image.size or 1.0) * 32 / thisImageScale
        table.insert(layeredIcons, {
            icon = image.picture,
            icon_size = thisImageSize,
            tint = prototype.tint,
            scale = thisImageScale * overallLayeredIconScale * (backgroundIconSize / thisImageSize),
        })
    end

    if not foundIcon then
        log("No icon found for prototype: " .. serpent.block(prototype))
    end

    return layeredIcons
end

return PlannerIcons
