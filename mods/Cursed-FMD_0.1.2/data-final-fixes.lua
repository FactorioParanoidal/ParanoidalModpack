
local oldRes = {}
local needFluid = {}
local oldMinCat = {}
local placeable = {}
local localeRes = {}

for resourceName, resource in pairs(data.raw["resource"]) do
    oldRes[resourceName] = resource.category or "basic-solid"
    localeRes[resourceName] = resource.localised_name or {"entity-name." .. resourceName}
    if resource.minable and resource.minable.required_fluid then needFluid[resourceName] = true end
    resource.category = resourceName
    
    local obj = util.table.deepcopy(data.raw["resource-category"]["basic-solid"])
    obj.name = resourceName
    data.raw["resource-category"][resourceName] = obj
end

for characterName, character in pairs(data.raw["character"]) do
    if character.mining_categories then
        if type(character.mining_categories) == "string" then
            oldMinCat[characterName] = { drill.mining_categories }
        else
            oldMinCat[characterName] = util.table.deepcopy(character.mining_categories)
        end
        local tmpCats = {}
        for _, entCat in ipairs(oldMinCat[characterName]) do
            for resCatName, resCat in pairs(oldRes) do
                if (not needFluid[resCatName]) and resCat == entCat then
                    table.insert(tmpCats, resCatName)
                end
            end
        end
        if #tmpCats > 0 then character.mining_categories = tmpCats end
    end
end

for drillName, drill in pairs(data.raw["mining-drill"]) do
    if drill.resource_categories then
        if type(drill.resource_categories) == "string" then
            oldMinCat[drillName] = { drill.resource_categories }
        else
            oldMinCat[drillName] = util.table.deepcopy(drill.resource_categories)
        end
        if not drill.fast_replaceable_group then
            drill.fast_replaceable_group = drillName
        end
        local tmpCats = {}
        local handleFluids = (drill.input_fluid_box ~= nil)
        for _, entCat in ipairs(oldMinCat[drillName]) do
            for resCatName, resCat in pairs(oldRes) do
                if (not needFluid[resCatName] or handleFluids) and resCat == entCat then
                    table.insert(tmpCats, resCatName)
                end
            end
        end
        if #tmpCats > 0 then drill.resource_categories = tmpCats end
    end
end



for n, item in pairs(data.raw["item"]) do
    if item.place_result and oldMinCat[item.place_result] then
        placeable[item.place_result] = { item=item.name, count=1 }
    end
end


local newRes = {}
for resName, oldCat in pairs(oldRes) do table.insert(newRes, resName) end


-- local tbl = {}
for i, arrResource in ipairs(newRes) do
    for drillName, drill in pairs(data.raw["mining-drill"]) do
        if oldMinCat[drillName] then
            local newName = drillName .. ";" .. arrResource
            if not data.raw["mining-drill"][newName] and drill.resource_categories then
                local newDrill = util.table.deepcopy(drill)
                newDrill.name = newName
                newDrill.resource_categories = {}
                newDrill.localised_name = drill.localised_name or {"entity-name." .. drillName}
                newDrill.localised_description = drill.localised_description or {"entity-description.drillName"}
                newDrill.flags = {"placeable-neutral", "player-creation", "hidden"}
                newDrill.order = newName
                newDrill.placeable_by = util.table.deepcopy(placeable[drill.name])
                if newDrill.localised_name then
                    newDrill.localised_name = {"",newDrill.localised_name," {",localeRes[arrResource],"}"}
                else
                    newDrill.localised_name = {"",{"entity-name." .. drillName}," {",localeRes[arrResource],"}"}
                end
                -- tbl[newName] = newDrill.localised_name
                local checkDrill = ""
                local handleFluids = (newDrill.input_fluid_box ~= nil)
                for _, entCat in ipairs(oldMinCat[drillName]) do
                    if (not needFluid[arrResource] or handleFluids) and oldRes[arrResource] == entCat then
                        table.insert(newDrill.resource_categories, arrResource)
                        checkDrill = arrResource
                    end
                end
                if newName == drillName .. ";" .. checkDrill then
                    data.raw["mining-drill"][newName] = newDrill
                end
            end
        end
    end
end

-- error(serpent.block(tbl))


local obj = util.table.deepcopy(data.raw["selection-tool"]["selection-tool"])
obj.name = "filter-drills"
obj.icon = "__Cursed-FMD__/icon_64.png"
obj.icon_size = 64
obj.selection_color = {r=0.66, g=0.93, b=0.30}
obj.alt_selection_color = obj.selection_color
obj.selection_mode = {"any-entity"}
obj.alt_selection_mode = obj.selection_mode
obj.entity_filters = nil
obj.alt_entity_filters = obj.entity_filters
obj.entity_type_filters = {"mining-drill"}
obj.entity_type_filters = obj.entity_type_filters
obj.show_in_library = true
obj.localised_name = {"gui-control-behavior-modes.set-filters"}
data.raw[obj.type][obj.name] = obj

data.raw["sprite"]["Cursed-FMD"] =
{
    type = "sprite",
    name = "Cursed-FMD",
    filename = "__Cursed-FMD__/icon_64.png",
    width = 64,
    height = 64
}

data.raw["shortcut"]["Cursed-FMD"] = {
    type = "shortcut",
    name = "Cursed-FMD",
    action = "create-blueprint-item",
    item_to_create = "filter-drills",
    order = "zy",
    localised_name = {"gui-control-behavior-modes.set-filters"},
    icon = {
      filename = "__Cursed-FMD__/icon_64.png",
      size = 64,
      scale = 0.25,
      flags = {"gui-icon"}
    }
  }


-- description.logistic-chest-filters=Filtros
-- gui.select-filter=Seleccionar filtro
-- gui.set-filter=Configurar el filtro
-- gui-blueprint-library.shelf-choice=Filtro:
-- gui-browse-games.filters=filtros
-- gui-control-behavior-modes.set-filters=Definir filtros
-- gui-inserter.filter=Filtro
-- gui-logistic.title-filter-short=Filtro
-- entity-name.can-filter-items=Puede filtrar objetos.