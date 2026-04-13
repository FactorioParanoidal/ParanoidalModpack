local BioInd = require('common')('Bio_Industries_2')

local ICONPATH_W = BioInd.modRoot .. "/graphics/icons/weapons/"

if BI.Settings.Bio_Cannon then

  data:extend({

      -- Prototype Artillery Proto Ammo
    {
      type = "ammo",
      name = "bi-bio-cannon-proto-ammo",
      icon = ICONPATH_W .. "bio_cannon_proto_ammo_icon.png",
      icon_size = 64,
      ammo_category = "Bio_Cannon_Ammo",
      ammo_type = {
        category = "Bio_Cannon_Ammo",
        target_type = "direction",
        action = {
          {
            type = "direct",
            action_delivery = {
              type = "projectile",
              projectile = "bi-bio-cannon-proto-ammo",
              starting_speed = 1,
              direction_deviation = 0.8,
              range_deviation = 0.8,
              max_range = 90
            }
          }
        }
      },
      subgroup = "ammo",
      order = "z[Bio_Cannon_Ammo]-a[Proto]",
      stack_size = 50,
    },


    -- Prototype Artillery Basic Ammo
    {
      type = "ammo",
      name = "bi-bio-cannon-basic-ammo",
      icon = ICONPATH_W .. "bio_cannon_basic_ammo_icon.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH_W .. "bio_cannon_basic_ammo_icon.png",
          icon_size = 64,
        }
      },
      ammo_category = "Bio_Cannon_Ammo",
      ammo_type = {
        category = "Bio_Cannon_Ammo",
        target_type = "direction",
        action = {
          {
            type = "direct",
            action_delivery = {
              type = "projectile",
              projectile = "bi-bio-cannon-basic-ammo",
              starting_speed = 1,
              direction_deviation = 0.8,
              range_deviation = 0.8,
              max_range = 90
            }
          }
        }
      },
      subgroup = "ammo",
      order = "z[Bio_Cannon_Ammo]-b[Basic]",
      stack_size = 50,
    },

      -- Prototype Artillery Poison Ammo
    {
      type = "ammo",
      name = "bi-bio-cannon-poison-ammo",
      icon = ICONPATH_W .. "bio_cannon_poison_ammo_icon.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH_W .. "bio_cannon_poison_ammo_icon.png",
          icon_size = 64,
        }
      },
      ammo_category = "Bio_Cannon_Ammo",
      ammo_type = {
        category = "Bio_Cannon_Ammo",
        target_type = "direction",
        action = {
          {
            type = "direct",
            action_delivery = {
              type = "projectile",
              projectile = "bi-bio-cannon-poison-ammo",
              starting_speed = 1,
              direction_deviation = 0.8,
              range_deviation = 0.8,
              max_range = 90
            }
          }
        }
      },
      subgroup = "ammo",
      order = "z[Bio_Cannon_Ammo]-c[Poison]",
      stack_size = 50,
    },


  })

end
