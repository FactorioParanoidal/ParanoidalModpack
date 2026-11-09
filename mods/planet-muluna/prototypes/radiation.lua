local rro=Muluna.rro

local radiation={
    type="airborne-pollutant",
    name="radiation",
    chart_color={0,150,0},
    icon=data.raw["airborne-pollutant"]["pollution"].icon,
    affects_evolution=false,
    affects_water_tint=false,
}

-- Paranoidal fork: home mining drills keep their emissions (upstream: every drill emits radiation, shown in its
-- tooltip at home too).

Muluna:extend{radiation}