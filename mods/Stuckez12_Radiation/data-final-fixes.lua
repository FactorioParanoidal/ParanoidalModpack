local mod_addons = require("scripts.mod_integrations")


function add_label_to_item(list)
    for name, proto_data in pairs(list) do
        local proto = data.raw[proto_data.type][name]

        log("Item to add: " .. name .. " | Data type: "..proto_data.type)

        if not proto.custom_tooltip_fields then
            proto.custom_tooltip_fields = {}
        else
            for _, entry in pairs(proto.custom_tooltip_fields) do
                if entry.name[1] == "item-tag.Stuckez12-radiation-item-tag" then
                    log("Skipped item: " .. name)
                    goto continue
                end
            end
        end

        table.insert(proto.custom_tooltip_fields,
        {
            name = {"item-tag.Stuckez12-radiation-item-tag"},
            value = {"item-tag.Stuckez12-radiation-item-value", tostring(proto_data.value)},
            order = 255
        })

        ::continue::
    end
end


-- Data compatibility
for name, _ in pairs(mods) do
    if mod_addons.data_compatible_mod_funcs[name] then
        mod_addons.data_compatible_mod_funcs[name]()
    end
end


-- Item Label Compatibility
for name, _ in pairs(mods) do
    if mod_addons.compatible_mod_funcs[name] then
        local mod_data = mod_addons.compatible_mod_funcs[name]()

        add_label_to_item(mod_data.item)
        add_label_to_item(mod_data.fluid)
        add_label_to_item(mod_data.unit)
    end
end
