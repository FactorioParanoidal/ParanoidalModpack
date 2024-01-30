data:extend({
  {
    type = "bool-setting",
    name = "enable-magazine",
    setting_type = "startup",
    default_value = true,
    order = "g00"
  },
  {
    type = "bool-setting",
    name = "enable-shotgun-bird",
    setting_type = "startup",
    default_value = true,
    order = "g01"
  },
  {
    type = "bool-setting",
    name = "enable-shotgun-buck",
    setting_type = "startup",
    default_value = true,
    order = "g02"
  },
  {
    type = "bool-setting",
    name = "enable-shotgun-slug",
    setting_type = "startup",
    default_value = true,
    order = "g03"
  },
  {
    type = "bool-setting",
    name = "enable-cannon-shell",
    setting_type = "startup",
    default_value = true,
    order = "g04"
  },
  {
    type = "bool-setting",
    name = "enable-small-rocket",
    setting_type = "startup",
    default_value = true,
    order = "g05"
  },
  {
    type = "bool-setting",
    name = "enable-big-rocket",
    setting_type = "startup",
    default_value = true,
    order = "g06"
  },
  {
    type = "bool-setting",
    name = "enable-artillery-shell",
    setting_type = "startup",
    default_value = true,
    order = "g07"
  },
  {
    type = "bool-setting",
    name = "enable-land-mine",
    setting_type = "startup",
    default_value = true,
    order = "g08"
  },
  {
    type = "bool-setting",
    name = "enable-capsule",
    setting_type = "startup",
    default_value = true,
    order = "g09"
  }
})


if mods["SchallTankPlatoon"] then
  data:extend({
    {
      type = "bool-setting",
      name = "enable-sniper-magazine",
      setting_type = "startup",
      default_value = true,
      order = "g-STP-00"
    },
    {
      type = "bool-setting",
      name = "enable-autocannon",
      setting_type = "startup",
      default_value = true,
      order = "g-STP-01"
    },
    {
      type = "bool-setting",
      name = "enable-cannon-shell-88",
      setting_type = "startup",
      default_value = true,
      order = "g-STP-02"
    },
    {
      type = "bool-setting",
      name = "enable-cannon-shell-128",
      setting_type = "startup",
      default_value = true,
      order = "g-STP-03"
    }
  })
end
if mods["space-exploration"] then
  data:extend({
    {
      type = "bool-setting",
      name = "enable-delivery-cannon-weapon",
      setting_type = "startup",
      default_value = true,
      order = "g-SE-00"
    }
  })
end
if mods["lightArtillery"] or mods["lightArtillery-Balanced"]then
  data:extend({
    {
      type = "bool-setting",
      name = "enable-derpy-artillery",
      setting_type = "startup",
      default_value = true,
      order = "g-LA-00"
    }
  })
end



if mods["Krastorio2"] then
  data:extend({
    {
      type = "bool-setting",
      name = "enable-pistol-magazine",
      setting_type = "startup",
      default_value = true,
      order = "g-K2-00"
    },
    {
      type = "bool-setting",
      name = "enable-rifle-magazine",
      setting_type = "startup",
      default_value = true,
      order = "g-K2-01"
    },
    {
      type = "bool-setting",
      name = "enable-anti-material-rifle-magazine",
      setting_type = "startup",
      default_value = true,
      order = "g-K2-02"
    },
    {
      type = "bool-setting",
      name = "enable-railgun-shell",
      setting_type = "startup",
      default_value = true,
      order = "g-K2-03"
    },
    {
      type = "bool-setting",
      name = "enable-turret-rocket",
      setting_type = "startup",
      default_value = true,
      order = "g-K2-04"
    }
  })
end

if mods["aai-vehicles-ironclad"] then
  data:extend({
    {
      type = "bool-setting",
      name = "enable-ironclad-mortar",
      setting_type = "startup",
      default_value = true,
      order = "g-ironclad-00"
    }
  })
end
if mods["RampantArsenal"] then
  data:extend({
    {
      type = "bool-setting",
      name = "enable-rampant-mortar",
      setting_type = "startup",
      default_value = true,
      order = "g-ramp-00"
    }
  })
end




