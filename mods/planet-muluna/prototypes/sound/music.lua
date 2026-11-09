if Muluna.rro.safe_get(settings.startup["disable-muluna-music"],{"value"}) == false then
    -- Muluna:extend{
    --     {
    --     name = "muluna-sandy-boys-beth-cohens",
    --     type = "ambient-sound",
    --     track_type = "main-track",
    --     planets = {"muluna"},
    --     sound = {
    --         filename = "__muluna-graphics__/sound/music/1 - Sandy Boys Beth Cohen's [aiqbWEikr4w].ogg",
    --         volume = 0.7,
    --     }
    -- }
    -- } 

    local tracks = {
        {
            track_type = "hero-track",
            sound = {
                filename = "Anthem",
                volume = 0.7
            }
        },
        {
            track_type = "interlude",
            sound = {
                filename = "Storm",
                volume = 0.7
            }
        },
        {
            track_type = "interlude",
            sound = {
                filename = "Muluna-33",
                volume = 0.7
            }
        },
        {
            track_type = "interlude",
            sound = {
                filename = "Handcrafted",
                volume = 0.7
            }
        },
         {
            track_type = "interlude",
            sound = {
                filename = "Ode-to-the-Pilots",
                volume = 0.7
            }
        },
        {
            
            sound = {
                filename = "Cryo-Lab",
                volume = 1
            }
        },
        {
            
            sound = {
                filename = "Eclipse",
                volume = 0.7
            }
        },
        {
            sound = {
                filename = "Factory-FourFour",
                volume = 0.7
            }
        },
        {
            sound = {
                filename = "01010213",
                volume = 1
            }
        },
    }
    for _,track in pairs(tracks) do
        track = Muluna.rro.merge({
            name = "muluna-music-" .. track.sound.filename,
            type = "ambient-sound",
            planets = {"muluna"},
            
        },track)
        if not track.track_type then track.track_type = "main-track" end
        if track.track_type ~= "hero-track" then track.weight = 10 end
        track.sound.filename = "__muluna-graphics__/sound/music-fluidnatalie/" .. track.sound.filename
        if track.track_type == "interlude" then track.sound.filename = track.sound.filename .. "-interlude" end
        --track.min_speed=0.95
        --track.max_speed=1.05
        track.sound.filename = track.sound.filename .. ".ogg"
        Muluna:extend{track}
    end

    if settings.startup["aps-planet"] and settings.startup["aps-planet"].value == "muluna" then --Title track when Muluna start is loaded.
        local title_track = table.deepcopy(data.raw["ambient-sound"]["muluna-music-Factory-FourFour"])
        title_track.track_type = "menu-track"
        title_track.planet = nil

        for _,track in pairs(data.raw["ambient-sound"]) do
            if track.track_type == "menu-track" then
                data.raw["ambient-sound"][track.name] = nil
            end
        end
        Muluna:extend{title_track}
    end
end

PlanetsLib.borrow_music("space-platform", data.raw["planet"]["muluna"],
    {track_types = {"main-track"},
    modifier_function = function(track) track.weight = (track.weight or 1) / 32 end})



