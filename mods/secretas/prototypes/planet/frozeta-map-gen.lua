local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")

planet_map_gen.frozeta = function() --TODO add all my decorations.
    return
    {
        property_expression_names =
        {
          elevation = "elevation_lakes",-- "frozeta_elevation",
          temperature = "frozeta_temperature",
          moisture = "frozeta_moisture",
          aux = "aux_basic",
          cliffiness = "cliffiness_basic",
          cliff_elevation = "cliff_elevation_from_elevation",
          ["entity:spaceship-scrap:probability"] = "frozeta_spaceship_scrap_probability",
          ["entity:spaceship-scrap:richness"] = "frozeta_spaceship_scrap_richness",

        },
        cliff_settings =
        {
          name = "cliff-fulgora",
          control = "fulgora_cliff",
          cliff_elevation_interval = 40,
          cliff_elevation_0 = 80,
          cliff_smoothing = 0
        },
  
        autoplace_controls =
        {
          --Controls now show up except we have several problems. 1 no chalcopyrite or sulfur. 2. Platium needs big mining drills.
          ["spaceship_scrap"] = {},
          ["frozeta_noise_scale"] = {},
        },
        autoplace_settings =
        {
          ["tile"] =
          {
            settings =
            {
              ["snow-flat"] = {}, --going to have to update probability expressions
              ["snow-crests"] = {},
              ["snow-lumpy"] = {},
              ["snow-patchy"] = {},
              ["ice-rough"] = {},
              ["ice-smooth"] = {},
              --["brash-ice"] = {},
            }
          },
          ["decorative"] =
          {
            settings =
            {



              ["crater-small"] = {},
              ["crater-large"] = {}, --TODO adjust colors

              
            }
          },
          ["entity"] =
          {
            settings =
            {
             
              ["spaceship-scrap"] = {},
              --["crater-cliff"] = {},

            }
          }
        }
    }
end

return planet_map_gen