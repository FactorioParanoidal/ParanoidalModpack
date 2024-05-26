require("__automated-utility-protocol__.util.main")


local function find_all_resources_in_or_at_ground(area_for_looking_up)
    local result = {}
    -- все клетки с ресурсами, которые закопаны в земле(руды, жидкости, газы, что угодно)
    local found_resouces_entities = _table.map(
        radar_surface.find_entities_filtered { type = "resource", area = area_for_looking_up },
        function(resource)
            return {
                type = resource.type,
                name = resource.name
            }
        end)
    --клетки, содержащие воду(ресурсом формально не является)
    local tile_entities = _table.map(
        radar_surface.find_tiles_filtered { area = area_for_looking_up, name = "water" },
        function(tile)
            return {
                type = "tile",
                name = tile.name
            }
        end)
    _table.insert_all_if_not_exists(result, found_resouces_entities)
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
    local distinct_found_resouces = find_all_resources_in_or_at_ground(radar_area)
    research_technologies_for_resources_if_exists_not_researched(distinct_found_resouces, radar_force,
        "На планете на поверхности " ..
        radar_surface.name .. " найден новый ресурс '", "' в области с координатами " ..
        Utils.dump_to_console(area) .. " игроком ")
end
