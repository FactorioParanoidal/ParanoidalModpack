if mods["Big_Brother"] then
    for ra = 1, 9 do
        for re = 1, 9 do
            for mk = 1, 5 do
                local radar = data.raw["radar"]["big_brother-radar_ra-"..ra.."_re-"..re.."_mk-"..mk]
                if radar then radar.pictures["filename"] = "__ShinyBobGFX__/graphics/entity/radars/radar-"..mk..".png" end
            end
        end
    end
end
