--(( Hide Planners ))--

if settings.startup["picker-add-planners-library"] and settings.startup["picker-add-planners-library"].value then
    for _, item in pairs(data.raw["selection-tool"]) do
        if item.name ~= "dummy-selection-tool" then
            item.show_in_library = true
        end
    end
    -- local rm = data.raw["item"]["resource-monitor"]
    -- if rm then
    --     rm.flags = {"hidden"}
    --     data.raw.recipe[rm.name].hidden = true
    -- end
end