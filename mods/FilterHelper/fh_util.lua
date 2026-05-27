require("util")

local fh_util = {}

function fh_util.make_item_id(name, quality)
    return name .. "|" .. quality
end

function fh_util.canonize_item(item, quality)
    if not item then
        return
    end
    local item_name = item
    if type(item) ~= "string" then
        item_name = item.name
        if not item_name then
            return
        end
        if type(item_name) ~= "string" then
            item_name = item_name.name
        end
        if not (item.object_name and string.match(item.object_name, "Prototype$")) and item.quality and not quality then
            quality = item.quality
        end
    end
    local quality_name = type(quality) == "string" and quality or (quality or prototypes.quality.normal).name
    ---@class ItemWithQuality
    return { name = item_name, quality = quality_name }
end

function fh_util.add_item_to_table(table, item, quality)
    local canonic_item = fh_util.canonize_item(item, quality)
    if canonic_item then
        table[fh_util.make_item_id(canonic_item.name, canonic_item.quality)] = canonic_item
    end
end

function fh_util.is_same_item(item1, item2)
    item1 = fh_util.canonize_item(item1)
    item2 = fh_util.canonize_item(item2)
    return item1 and item2 and item1.name == item2.name and item1.quality == item2.quality
end

function fh_util.get_effective_type(entity)
    return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end

function fh_util.get_effective_name(entity)
    return entity.type == "entity-ghost" and entity.ghost_name or entity.name
end

function fh_util.get_effective_prototype(entity)
    return entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype
end

return fh_util
