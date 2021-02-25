require "parameters"
local function proto_tech_cost(tech)
  --log("new tech "..tech.name.." researched for "..(tech.unit.count or 0))
  local sum = 0
  if tech.unit.ingredients then
    for _, item in pairs(tech.unit.ingredients) do
      local name, amount
      if item.type then
        if item.type=="item" then
          name = item.name
          amount = item.amount
        end
      else
        name = item[1]
        amount = item[2]
      end
      if name then 
        --log(name..'----'..amount) 
        sum  = sum + amount * (science_packet_cost[name] or 1)
      end
    end
  end
  if not tech.unit.count then return nil end
  return tech.unit.count*sum*0.00001*linear_factor+constant_factor*0.01
end

for _,tech in pairs(data.raw.technology) do
  if not tech.hidden then
    local inc = proto_tech_cost(tech)
    local effect
    if inc then 
      effect = {
        type  = "nothing",
        effect_description = {"research-evolution-factor-effect", math.floor((1-math.exp(-inc))*100000+0.5)*0.001}
      }
    else
      effect = {
        type  = "nothing",
        effect_description = {"research-evolution-factor-effect-unknown"}
      }
    end
    if tech.effects then
      table.insert(tech.effects, effect)
    else
      tech.effects = {effect}
    end
  end
end
