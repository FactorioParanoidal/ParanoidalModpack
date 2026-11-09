local function make_subgroup(subgroup_name, subgroup_order, group, members)
    data:extend {{
        type = "item-subgroup",
        name = subgroup_name,
        group = group,
        order = subgroup_order,
    }}

    for i, prototype in pairs(members) do
        local order_letter = tostring(i)
        while #order_letter <= 5 do
            order_letter = "0" .. order_letter
        end
        local order = order_letter .. "-[" .. prototype.name .. "]"
        prototype.order = order
        prototype.subgroup = subgroup_name
    end
end

make_subgroup("maraxsis-intermediants", "ge", "intermediate-products", {
    data.raw.item["maraxsis-coral"],
    data.raw.item["limestone"],
    data.raw.item[maraxsis_constants.SAND_ITEM_NAME],
    data.raw.item["maraxsis-glass-panes"],
    data.raw.item["maraxsis-fish-food"],
    data.raw.capsule["maraxsis-tropical-fish"],
    data.raw.item["maraxsis-microplastics"],
    data.raw.recipe["maraxsis-carbon"],
    data.raw.item["maraxsis-wyrm-specimen"],
    data.raw.item["maraxsis-wyrm-confinement-cell"],
    data.raw.item["maraxsis-super-sealant-substance"],
    data.raw.recipe["maraxsis-geothermal-sulfur"],
})

make_subgroup("salt", "gf", "intermediate-products", {
    data.raw.item["salt"],
    data.raw.recipe["salt"],
    data.raw.recipe["maraxsis-brackish-water"],
    data.raw.recipe["maraxsis-water"],
    data.raw.item["maraxsis-salt-filter"],
    data.raw.recipe["maraxsis-salt-filter"],
    data.raw.item["maraxsis-saturated-salt-filter"],
    data.raw.recipe["maraxsis-saturated-salt-filter"],
    data.raw.recipe["maraxsis-hydrolox-rocket-fuel"],
})

make_subgroup("advanced-fluids", "gg", "intermediate-products", {
    data.raw.recipe["maraxsis-atmosphere"],
    data.raw.recipe["maraxsis-liquid-atmosphere-decompression"],
    data.raw.recipe["maraxsis-liquid-atmosphere"],
    data.raw.recipe["maraxsis-supercritical-steam"],
    data.raw.recipe["maraxsis-supercritical-steam-cooling"],
})

do
    local omega_3 = {
        data.raw.item["maraxsis-fish-oil"],
        data.raw.recipe["maraxsis-bio-oil"],
        data.raw.recipe["maraxsis-omega-3"],
        data.raw.recipe["maraxsis-vitamin-infused-agricultural-science"],
        data.raw.recipe["maraxsis-vitamin-infused-hydraulic-science"],
    }

    local i = 1
    while true do
        local promethium = data.raw.recipe["maraxsis-vitamin-infused-promethium-science-" .. i]
        if promethium then table.insert(omega_3, promethium) else break end
        i = i + 1
    end

    make_subgroup("omega-3", "gh", "intermediate-products", omega_3)
end

local function order_subgroup(prototype_type, name, order, subgroup)
    local prototype = data.raw[prototype_type][name]
    if prototype then
        prototype.order = order
        prototype.subgroup = subgroup
    else
        error("no such prototype: " .. prototype_type .. "." .. name)
    end
end

order_subgroup("item-with-entity-data", "maraxsis-diesel-submarine", "b[personal-transport]-c[spidertron]-b[diesel-submarine]", "transport")
order_subgroup("item-with-entity-data", "maraxsis-nuclear-submarine", "b[personal-transport]-c[spidertron]-c[nuclear-submarine]", "transport")
order_subgroup("item", "sp-spidertron-dock", "b[personal-transport]-c[spidertron]-d[spidertron-dock]", "transport")
order_subgroup("item", "maraxsis-hydro-plant", "hi[hydro-plant]", "production-machine")
order_subgroup("item", "maraxsis-fishing-tower", data.raw.item["agricultural-tower"].order .. "-ag[fishing-tower]", data.raw.item["agricultural-tower"].subgroup)
order_subgroup("item", "maraxsis-sonar", "d[radar]-b[sonar]-a[sonar]", data.raw.item.radar.subgroup)
order_subgroup("lamp", "maraxsis-sonar-light-1", "d[radar]-b[sonar]-b[sonar-light-1]", data.raw.item.radar.subgroup)
order_subgroup("lamp", "maraxsis-sonar-light-2", "d[radar]-b[sonar]-c[sonar-light-2]", data.raw.item.radar.subgroup)
order_subgroup("item", "maraxsis-geothermal-generator", "h[geothermal-generator]-a[geothermal-generator]", "energy")
order_subgroup("item", "maraxsis-oversized-steam-turbine", "h[geothermal-generator]-b[oversized-steam-turbine]", "energy")
order_subgroup("item", "maraxsis-pressure-dome", "z-d-a[pressure-dome]", "environmental-protection")
--order_subgroup("item", "maraxsis-pressure-dome-large", "z-d-b[pressure-dome-big]", "environmental-protection")
order_subgroup("lamp", "maraxsis-pressure-dome-lamp", "z-d-c[pressure-dome-lamp]", "environmental-protection")
order_subgroup("constant-combinator", "maraxsis-pressure-dome-combinator", "z-d-d[pressure-dome-lamp]", "environmental-protection")
order_subgroup("simple-entity", "maraxsis-water-shader", "z", "grass")

order_subgroup("fluid", "maraxsis-saline-water", "f[maraxsis-fluids]-a[saline-water]", "fluid")
order_subgroup("fluid", "maraxsis-brackish-water", "f[maraxsis-fluids]-b[brackish-water]", "fluid")
order_subgroup("fluid", "oxygen", "f[maraxsis-fluids]-c[oxygen]", "fluid")
order_subgroup("fluid", "hydrogen", "f[maraxsis-fluids]-d[hydrogen]", "fluid")
order_subgroup("fluid", "maraxsis-atmosphere", "f[maraxsis-fluids]-f[atmosphere]", "fluid")
order_subgroup("fluid", "maraxsis-liquid-atmosphere", "f[maraxsis-fluids]-f[liquid-atmosphere]", "fluid")
order_subgroup("fluid", "maraxsis-supercritical-steam", "f[maraxsis-fluids]-h[maraxsis-supercritical-steam]", "fluid")
order_subgroup("fluid", "maraxsis-omega-3", "f[maraxsis-fluids]-i[maraxsis-omega-3]", "fluid")

order_subgroup("capsule", "maraxsis-big-cliff-explosives", "e[big-cliff-explosives]", data.raw.capsule["cliff-explosives"].subgroup)
order_subgroup("ammo", "maraxsis-fat-man", "e[maraxsis-fat-man]", data.raw.ammo["artillery-shell"].subgroup)
order_subgroup("resource", "maraxsis-coral", "x[maraxsis-coral]", "mineable-fluids")
order_subgroup("item", "maraxsis-conduit", data.raw.item.beacon.order .. "a[maraxsis-conduit]", data.raw.item.beacon.subgroup)

require "compat.schall-transport-group"
