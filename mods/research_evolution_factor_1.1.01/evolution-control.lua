local science_packet_cost = { --evolution cost coefficients for specific science packs
  ["planetary-data"] = 1400,
  ["station-science"] = 3000
}
local constant_factor = 0.15  --percent of evolution per each researched technology
local linear_factor = 0.35    --percent of evolution per 1000 total researched science packs

local function proto_tech_cost(tech)
  log("new tech "..tech.name.." researched for "..(tech.unit.count or 0))
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
        log(name..'----'..amount) 
        sum  = sum + amount * (science_packet_cost[name] or 1)
      end
    end
  end
  if not tech.unit.count then return nil end
  return tech.unit.count*sum*0.00001*linear_factor+constant_factor*0.01
end

local function tech_cost(tech)
  local sum = 0
  if tech.research_unit_ingredients then
    for _, item in pairs(tech.research_unit_ingredients) do
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
        log(name..'----'..amount) 
        sum  = sum + amount * (science_packet_cost[name] or 1)
      end
    end
  end
  local unit_count = tech.research_unit_count
  local formula = tech.research_unit_count_formula
  log("new tech "..tech.name.." researched for "..(unit_count or 0))
  if formula then
    local level = tech.level
    if formula and level ~= nil then
      level = math.max(0, (tech.level or 1)-1)
      unit_count = game.evaluate_expression(formula, {L=level, l=level})
    end
    log("calculate unit count by formula "..formula.." with level "..(level or "NAN").." and result value "..unit_count)
  end    
  sum = sum * (unit_count or 0)
  return sum*0.00001*linear_factor+constant_factor*0.01
end

function researchEvolutionFactor_on_research_finished(event)
  log("tech ".. event.research.name)
  local inc = tech_cost(event.research)
  log("adding "..inc.." to evolution factor")
  for _,force in pairs(game.forces) do
    if force.ai_controllable or force == game.forces.enemy then
      force.evolution_factor = 1-(1-force.evolution_factor)*math.exp(-inc)
    end
  end
end

function add_tech_effects()
  for _,tech in pairs(data.raw.technology) do
    local inc = proto_tech_cost(tech)
    if inc then 
      local effect = {
        type  = "nothing",
        effect_description = {"research-evolution-factor-effect", math.floor((1-math.exp(-inc))*100000+0.5)*0.001}
      }
      if tech.effects then
        table.insert(tech.effects, effect)
      else
        tech.effects = {effect}
      end
    end  
  end  
end

--[[
  from linear to exponential:
    ex = 1-math.exp(-lin)
  from exponential to linear:
    math.exp(-lin)= 1-ex , 
    lin = -math.log(1-ex) 
  
  1-exp(-(add - ln(1-ex))) ->  1-exp(ln(1-ex)-add) -> 1-(1-ex)*exp(-add)
]]
