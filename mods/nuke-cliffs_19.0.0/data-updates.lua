

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


--[[
local target_effects = data.raw.projectile["atomic-bomb-wave"].action[1].action_delivery.target_effects
if not target_effects[1] then
  target_effects[1] = {}
  for k,v in pairs(target_effects) do
    if type(k) == "string" then
      target_effects[1][k] = v
      target_effects[k] = nil
    end
  end
end
target_effects[#target_effects+1] = {
  type = "destroy-cliffs",
  radius = 3,
  explosion = "explosion"
}
]]


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