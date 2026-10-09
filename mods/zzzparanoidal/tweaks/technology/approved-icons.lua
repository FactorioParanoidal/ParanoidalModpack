-- Согласованные иконки исследований (фильтры, погрузчики, дронстанции и др.). Только иконки технологий.
-- PNG без номеров: уровни добавляет icon-markers.lua по icon-markers-rules.lua; шестерни I–V — ironworks-icons.lua.
-- Прежние дополнительные значки (батарея, ракетная плата) переносятся как есть.
local root = "__zzzparanoidal__/graphics/technology/approved-icons/"

local function single(name, file, size)
    return { name = name, layers = {{ icon = root .. file .. ".png", icon_size = size or 256 }} }
end

local list = {
    single("zcs-trash-landfill-tech", "zcs-trash-landfill-tech"),
    single("Fuel-Additive", "Fuel-Additive"),
    single("JunkTrain_tech", "JunkTrain_tech"),
    single("angels-fluid-control", "angels-fluid-control"),
    single("bob-alien-artifact", "bob-alien-artifact"),
    single("bob-fluid-barrel-processing", "bob-fluid-barrel-processing"),
    single("rocket-control-unit", "rocket-control-unit"),
    {
        name = "battery-mk3-equipment", keep_extra = true,
        layers = {
            { icon = root .. "battery-technology-base.png", icon_size = 256 },
            { icon = root .. "battery-technology-mask.png", icon_size = 256, tint = { 0.2, 0.706, 1 } },
        },
    },
}
list[7].keep_extra = true -- rocket-control-unit: значок ракетной части

-- Исходные иконки исследований ShinyBob_Techs из Beta 8, без изменения предметов.
list[#list + 1] = single("engine", "engine-beta8", 128)
list[#list + 1] = single("electric-engine", "electric-engine-beta8", 128)

for i = 1, 6 do list[#list + 1] = single("CW-air-filtering-" .. i, "CW-air-filtering") end
for i = 1, 4 do list[#list + 1] = single("CW-air-filter-cleaning-" .. i, "CW-air-filter-cleaning-" .. i) end
for _, name in ipairs({"aai-basic-loader", "aai-loader", "aai-fast-loader", "aai-express-loader",
    "aai-turbo-loader", "aai-ultimate-loader"}) do list[#list + 1] = single(name, name) end
for i = 1, 3 do list[#list + 1] = single("angels-slag-processing-" .. i, "angels-slag-processing") end
for i = 1, 4 do list[#list + 1] = single("bob-robo-modular-" .. i, "bob-robo-modular-" .. i) end

for _, entry in ipairs(list) do
    local technology = data.raw.technology[entry.name]
    if technology then
        local layers = table.deepcopy(entry.layers)
        if entry.keep_extra and technology.icons then
            -- Всё, кроме прежней основы, остаётся: дополнительные значки (не номера).
            for i = 2, #technology.icons do layers[#layers + 1] = table.deepcopy(technology.icons[i]) end
            for i = #layers, 1, -1 do
                if (layers[i].icon or ""):find("/icon-markers/", 1, true) then table.remove(layers, i) end
            end
        end
        for i = 2, #layers do if layers[i].icon_size ~= 256 then layers[i].floating = true end end
        technology.icon = nil
        technology.icon_size = nil
        technology.icon_mipmaps = nil
        technology.icons = layers
    end
end
