
function tech_has_prereq(force,tech, check_prereq_only)
    if force.technologies[tech] then 
    local valid = (not force.technologies[tech].researched) or check_prereq_only
    local pre = prototypes.technology[tech].prerequisites
    if valid then	
    for k,req in pairs (pre) do
        if not force.technologies[req.name].researched then 
            valid=false
            break
            end
        end end
    return valid
    end
    end
    
    
function get_tech_level(force,techname)
    local level = 1
    while true do 
        if not (force.technologies[techname..'-'..level] and force.technologies[techname..'-'..level].researched) then break end
        level=level+1
        end
    return level-1
end
    

-- research utils
function is_multilevel(technology)
    if technology.object_name == "LuaTechnology" then
      technology = technology.prototype
    end
    return technology.level ~= technology.max_level
  end
  --- @param technology LuaTechnology
  --- @param level uint
  --- @return double
  function get_research_progress(technology, level)
    local force = technology.force
    local current_research = force.current_research
    if current_research and current_research.name == technology.name then
      if not is_multilevel(technology) or technology.level == level then
        return force.research_progress
      else
        return 0
      end
    else
      return force.get_saved_technology_progress(technology) or 0
    end
  end
  function get_research_unit_count(technology, level)
    local formula = technology.research_unit_count_formula
    if formula then
      local level = level or technology.level
      return math.floor(helpers.evaluate_expression(formula, { l = level, L = level }))
    else
      return math.floor(technology.research_unit_count) --[[@as double]]
    end
  end





-- get all avaliable techs for force
function get_techs_available_for_force(force,excludes,with_ingredients, allow_locked)
  local available = {}
  local locked = {} --TO DO...

  for name,tech in pairs (force.technologies) do
    if (tech.enabled or (allow_locked and tech.visible_when_disabled and in_list(locked,name))) and tech_has_prereq(force,name) then
      if (not excludes) or (not in_list(excludes,name)) then
        table.insert(available,name) 
        end
      end
    end

  -- remove expensive space techs
  local basic = {"basic-tech-card","automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","utility-science-pack","production-science-pack"}
  if script.active_mods['space-exploration'] then 
    concat_lists(basic, {'space-science-pack','se-rocket-science-pack','se-astronomic-science-pack-1','se-biological-science-pack-1','se-energy-science-pack-1','se-material-science-pack-1'})
    end


  for t=#available,1,-1 do
    local tech = available[t]
    local ing = prototypes.technology[tech].research_unit_ingredients 
    if with_ingredients and #ing<1 then table.remove(available,t) 
      else 
      for i=1, #ing do if not in_list(basic,ing[i].name) then 
        table.remove (available,t)
        break
        end end
      end
    end

  return available
  end


  function GetTechCost(tech,mp)
    local ing = tech.research_unit_ingredients
    local c = tech.research_unit_count
    if c<=0 then c=game.evaluate_expression(tech.research_unit_count_formula, {L=tech.level, l=tech.level}) end
    mp=mp or 1
    local cost = {}
    for k,i in pairs (ing) do
      local pack = i.name
      local qt = i.amount
      local count=math.ceil(qt*c*mp)
      table.insert(cost, {name=pack, count=count})
      end
    return cost
    end
    