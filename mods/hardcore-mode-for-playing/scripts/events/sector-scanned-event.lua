require("__automated-utility-protocol__.util.main")


local function find_all_resources_in_or_at_ground(area_for_looking_up, radar_surface)
    local result = {}
    -- все клетки с ресурсами, которые закопаны в земле(руды, жидкости, газы, что угодно)
    local found_resources_entities = _table.map(
        radar_surface.find_entities_filtered { type = "resource", area = area_for_looking_up },
        function(resource)
            return {
                type = resource.type,
                name = resource.name
            }
        end)
    -- если найдены деревья - значит есть дерево на планете!
    local tree_count = radar_surface.count_entities_filtered { type = "tree", area = area_for_looking_up }
    if tree_count > 0 then
        _table.insert_all_if_not_exists(result, { {
            type = "resource",
            name = "wood"
        } })
    end
    -- если найдены камни - значит есть камень на планете!
    local cliff_count = radar_surface.count_entities_filtered { type = "cliff", area = area_for_looking_up }
    if cliff_count > 0 then
        _table.insert_all_if_not_exists(result, { {
            type = "resource",
            name = "stone"
        } })
    end
    --клетки, содержащие воду(ресурсом формально не является)
    local tile_entities = _table.map(
        radar_surface.find_tiles_filtered { area = area_for_looking_up, name = "water" },
        function(tile)
            return {
                type = "tile",
                name = tile.name
            }
        end)
    _table.insert_all_if_not_exists(result, found_resources_entities)
    _table.insert_all_if_not_exists(result, tile_entities)
    return result
end
function on_sector_scanned(e)
    local radar = e.radar
    local radar_area = e.area
    log("radar type " .. radar.type .. ", radar name " .. radar.name)
    log('area ' .. Utils.dump_to_console(radar_area))
    log('chunk_position ' .. Utils.dump_to_console(e.chunk_position))
    local radar_force = radar.force
    local radar_surface = radar.surface
    local distinct_found_resources = find_all_resources_in_or_at_ground(radar_area, radar_surface)
    research_technologies_for_resources_if_exists_not_researched(distinct_found_resources, radar_force,
        "На планете на поверхности " ..
        radar_surface.name .. " найден новый ресурс '", "' в области с координатами " ..
        Utils.dump_to_console(radar_area) .. " игроком ")
end
