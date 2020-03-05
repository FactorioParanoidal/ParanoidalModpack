

table.insert(data.raw.projectile["atomic-bomb-wave"].action,
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "destroy-cliffs",
          radius = 3,
          explosion = "explosion"
        }
      }
    }
  })

if (data.raw.projectile["atomic-artillery-wave"]) then
  table.insert(data.raw.projectile["atomic-artillery-wave"].action,
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "destroy-cliffs",
          radius = 3,
          explosion = "explosion"
        }
      }
    }
  })
end


if settings.startup["nukes-require-cliff-explosives"].value and data.raw.technology["atomic-bomb"] and data.raw.technology["cliff-explosives"] then
  table.insert(data.raw.technology["atomic-bomb"].prerequisites,"cliff-explosives")
end