---
--- Created by xyzzycgn.
--- DateTime: 01.03.25 14:39
---

log("migration to 2. 0.2")

local cnt = 0

local function removeAndLog(entity, from)
    log("remove " .. serpent.block(entity) .. " from " .. from)
    entity.destroy()
    cnt = cnt + 1
end


for k, surface in pairs(game.surfaces) do
    -- K.I.S.S. remove units not fitting
    local isPlatform = (surface.platform ~= nil)
    local isAquilo = (k == "aquilo")
    local isVulcanus = (k == "vulcanus")
    local checkneeded = isPlatform or isAquilo or isVulcanus
    if checkneeded then
        local entities = surface.find_entities_filtered({ name = { "texugo-wind-turbine", "texugo-wind-turbine2", "texugo-wind-turbine3", "texugo-wind-turbine4", } })
        for _, entity in pairs(entities) do
            if (isPlatform) then
                removeAndLog(entity, surface.platform.name)
            elseif isAquilo then
                removeAndLog(entity, k)
            elseif entity.name == "texugo-wind-turbine" then
                removeAndLog(entity, k)
            end
        end
    end
end

log("migration to 2.0.2 finished - " .. cnt .. " not fitting turbine(s) removed")
