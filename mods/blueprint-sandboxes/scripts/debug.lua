local Debug = {}

function Debug.ItemStack(value)
    data = {}
    if (value == nil) then
        data["nil"] = true
        return data
    end

    data["nil"] = false
    data["valid"] = value.valid
    data["valid_for_read"] = value.valid_for_read
    if not value.valid_for_read then
        return data
    end

    data["is_blueprint"] = value.is_blueprint
    if value.is_blueprint then
        data["is_blueprint_setup"] = value.is_blueprint_setup()
    end

    if value.is_blueprint then
        local entities = value.get_blueprint_entities()
        if entities then
            data["entities"] = #entities
        else
            data["entities"] = "nil"
        end
    end

    return data
end

return Debug
