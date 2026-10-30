-- Недостающие основные пакеты: технология стоит после технологии, требующей/открывающей пакет, но сама его не требует.
-- Пакет добавляется в том же количестве, что красный (или первый пакет цены). Применяется после research-beta8.
local add = {
    logistic = {"angels-bio-desert-farming-1", "angels-bio-swamp-farming-1", "angels-bio-temperate-farming-1", "phosphorus-processing-1"},
    chemical = {"bob-pumpjacks-2", "bob-solar-panel-equipment-2", "bob-vehicle-solar-panel-equipment-2", "worker-robots-speed-1",
        "bob-pumpjacks-3", "Schall-tank-F-0", "automation-7", "automation-8", "plastic-pmma", "personal-roboport-equipment",
        "texugo-wind-turbine2", "bob-personal-roboport-modular-equipment-1", "bob-vehicle-roboport-modular-equipment-1",
        "k-angels-advanced-chemistry-5"},
    production = {"automation-4", "battery-mk3-equipment", "bob-area-drills-3", "bob-drills-4", "bob-fluid-handling-3",
        "bob-railway-3", "bob-repair-pack-4", "bob-vehicle-big-turret-equipment-2", "mixed-oxide-fuel", "bob-pumpjacks-3",
        "k-angels-advanced-chemistry-5"},
    utility = {"automation-5", "bob-area-drills-4", "bob-drills-5", "bob-fluid-handling-4", "bob-pumpjacks-4", "bob-repair-pack-5",
        "bob-solar-panel-equipment-4", "bob-vehicle-solar-panel-equipment-4", "angels-ironworks-5",
        "angels-bio-farm-advanced-upgrade-2", "follower-robot-count-4"},
}

for pack, names in pairs(add) do
    local item = pack .. "-science-pack"
    for _, name in ipairs(names) do
        local tech = data.raw.technology[name]
        local ing = tech and tech.unit and tech.unit.ingredients
        if not ing then
            log("missing-science-packs: нет технологии " .. name)
        else
            local amount, has
            for _, i in ipairs(ing) do
                local n, a = i[1] or i.name, i[2] or i.amount
                if n == item then has = true end
                if n == "automation-science-pack" then amount = a end
                amount = amount or a
            end
            if not has then table.insert(ing, {item, amount or 1}) end
        end
    end
end
