
-- This file runs in the control stage

if not script.active_mods["call-plumber"] then return end

maraxsis.on_event(maraxsis.events.on_init(), function()
    -- Most fluids are compatible with normal pipes
    for _, fluid_name in ipairs({
          "maraxsis-atmosphere",
          "maraxsis-saline-water", "maraxsis-brackish-water",
          "oxygen", "hydrogen"}) do
        remote.call("call-plumber", "register_fluid", {fluid=fluid_name, category="inert"})
    end

    -- Treat cryogenic fluid like lava
    remote.call(
       "call-plumber", "register_fluid",
       {fluid="maraxsis-liquid-atmosphere", category="superheated"}
    )
end)

