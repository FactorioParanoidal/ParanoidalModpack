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

if (data.raw.projectile["atomic-artillery-wave"] ~= nil) then
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