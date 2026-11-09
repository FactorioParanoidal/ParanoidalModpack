local Public = {}

function Public.get_stage() 
    --based on lib.lua in Maraxsis
    local stage
    if data and data.raw and not data.raw.item["iron-plate"] then
        stage = "settings"
    elseif data and data.raw then
        stage = "data"
    elseif script then
        stage = "control"
    else
        error("Could not determine load order stage.")
    end
    return stage
end

function Public.has_new_quality_features()
    return (helpers.compare_versions(helper.game_version, "2.0.56") >= 0) --Checks if version is >=2.0.56, when new quality options 
end

return Public