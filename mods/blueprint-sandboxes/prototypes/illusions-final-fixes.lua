Illusion = require("scripts.illusion")

for _, mapping in pairs(Illusion.mappings) do
    local type = mapping[1]
    local name = mapping[2]
    local item = mapping[3]
    if data.raw[type] ~= nil and data.raw[type][name] ~= nil then
        local entity = data.raw[type][name]

        local group = entity.name
        if entity.fast_replaceable_group ~= nil then
            group = entity.fast_replaceable_group
        end
        entity.fast_replaceable_group = group

        local illusion = table.deepcopy(entity)
        illusion.name = Illusion.realToIllusionMap[name]
        illusion.placeable_by = { item = item, count = 1 }
        if illusion.flags ~= nil then
            table.insert(illusion.flags, "not-in-made-in")
        else
            illusion.flags = { "not-in-made-in" }
        end

        illusion.localised_description = { "entity-description." .. name }
        if entity.localised_name ~= nil then
            illusion.localised_name = {
                'ils.bpsb-ils-prefix',
                { entity.localised_name },
            }
        else
            illusion.localised_name = {
                'ils.bpsb-ils-prefix',
                { 'entity-name.' .. name },
            }
        end

        if illusion.type == "container" then
            illusion.type = "infinity-container"
            illusion.erase_contents_when_mined = true
        end

        data:extend({ illusion })
    else
        log("data[" .. type .. "][" .. name .. "] not found; cannot create Illusion")
    end
end
