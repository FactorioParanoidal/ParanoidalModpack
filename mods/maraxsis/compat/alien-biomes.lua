local function fix_decorative_autoplace(planet_name)
    local planet = data.raw.planet[planet_name]
    if not planet.map_gen_settings then return end

    local decoratives = planet.map_gen_settings.autoplace_settings.decorative.settings
    for name in pairs(decoratives) do
        local decorative = data.raw["optimized-decorative"][name]
        if not decorative then
            error("Decorative " .. name .. " not found")
        elseif not decorative.autoplace then
            decoratives[name] = nil
        end
    end
end

fix_decorative_autoplace("maraxsis")
fix_decorative_autoplace("maraxsis-trench")
