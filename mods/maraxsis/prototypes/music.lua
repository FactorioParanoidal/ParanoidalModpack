data:extend {{
    type = "ambient-sound",
    name = "maraxsis-hero-track",
    planets = {"maraxsis"},
    track_type = "hero-track",
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Hero Track [SB].ogg"
    }
}}

data:extend {{
    type = "ambient-sound",
    name = "maraxsis-1-bubbles",
    planets = {"maraxsis"},
    track_type = "main-track",
    weight = 10,
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Bubbles [SB].ogg"
    }
}}

data:extend {{
    type = "ambient-sound",
    name = "maraxsis-2-current",
    planets = {"maraxsis"},
    track_type = "main-track",
    weight = 10,
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Current [SB].ogg"
    }
}}

data:extend {{
    type = "ambient-sound",
    name = "maraxsis-3-heartbeat",
    planets = {"maraxsis"},
    track_type = "main-track",
    weight = 10,
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Heartbeat [SB].ogg"
    }
}}

data:extend {{
    type = "ambient-sound",
    name = "maraxsis-4-mermaids",
    planets = {"maraxsis"},
    track_type = "main-track",
    weight = 10,
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Mermaids [SB].ogg"
    }
}}

data:extend {{
    type = "ambient-sound",
    name = "maraxsis-5-seabed",
    planets = {"maraxsis"},
    track_type = "main-track",
    weight = 10,
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Seabed [SB].ogg"
    }
}}

data:extend {{
    type = "ambient-sound",
    name = "maraxsis-trench-1-deepdark",
    planets = {"maraxsis-trench"},
    track_type = "main-track",
    weight = 12,
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Deepdark EX [T].ogg"
    }
}}

data:extend {{
    type = "ambient-sound",
    name = "maraxsis-trench-2-submarine",
    planets = {"maraxsis-trench"},
    track_type = "main-track",
    weight = 20,
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Submarine [T].ogg"
    }
}}

data:extend {{
    type = "ambient-sound",
    name = "maraxsis-trench-3-trench",
    planets = {"maraxsis-trench"},
    track_type = "main-track",
    weight = 20,
    sound = {
        volume = 0.7,
        filename = "__maraxsis__/sounds/music/Trench [T].ogg"
    }
}}

data.raw.planet["maraxsis-trench"].persistent_ambient_sounds.wind = {
    sound = {
        filename = "__maraxsis__/sounds/trench-ambiance.ogg",
        volume = 0.2
    },
}

data.raw.planet["maraxsis"].persistent_ambient_sounds.wind = {
    sound = {
        filename = "__maraxsis__/sounds/maraxsis-ambiance.ogg",
        volume = 0.8,
        speed = 0.5
    },
}
