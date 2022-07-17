function add_trail_to_ammo(ammo_name, trail_name)
  local ammo = data.raw.ammo[ammo_name]
  if not (ammo and ammo.ammo_type) then return end
  local action1 = ammo.ammo_type.action[1] or ammo.ammo_type.action
  if not action1 then return end
  local action_delivery1 = action1.action_delivery[1] or action1.action_delivery
  if not action_delivery1 then return end
  if not action_delivery1.target_effects then action_delivery1.target_effects = {} end
  if (not action_delivery1.target_effects[1]) and action_delivery1.target_effects.type then
    action_delivery1.target_effects = {action_delivery1.target_effects}
  end
  local target_effects = action_delivery1.target_effects
  if #target_effects > 0 and target_effects[#target_effects].entity_name
    and string.find(target_effects[#target_effects].entity_name, "bullet-beam-", 1, true) then
      target_effects[#target_effects].entity_name = trail_name
  else
      table.insert(action_delivery1.target_effects, { type = "create-explosion", entity_name = trail_name })
  end
end

for ammo_name, ammo in pairs(data.raw.ammo) do
  if ammo.ammo_type and ammo.ammo_type.category and ammo.ammo_type.category == "bullet" then
    add_trail_to_ammo(ammo_name, "bullet-beam-white-faint")
  end
end

-- vanilla
add_trail_to_ammo('firearm-magazine', "bullet-beam-yellow-faint")
add_trail_to_ammo('piercing-rounds-magazine', "bullet-beam-red-faint")
add_trail_to_ammo('uranium-rounds-magazine', "bullet-beam-olive")

-- bobs
add_trail_to_ammo('bullet-magazine', "bullet-beam-white-faint")
add_trail_to_ammo('ap-bullet-magazine', "bullet-beam-white")
add_trail_to_ammo('he-bullet-magazine', "bullet-beam-yellow")
add_trail_to_ammo('flame-bullet-magazine', "bullet-beam-red")
add_trail_to_ammo('acid-bullet-magazine', "bullet-beam-purple")
add_trail_to_ammo('poison-bullet-magazine', "bullet-beam-green-faint")
add_trail_to_ammo('electric-bullet-magazine', "bullet-beam-cyan")
