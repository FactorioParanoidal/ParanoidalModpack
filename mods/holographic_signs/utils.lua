require "util"
local format_number = util.format_number

local format_time   = util.formattime
function format_time_from_tick(ThatTick)
  if game.tick > ThatTick then return format_time(game.tick-ThatTick)
  else return format_time(ThatTick - game.tick)
  end
end

function format_t(tick)
return format_time(tick)
end

function getDayTimeString(surface)
 local daytime = surface.daytime + 0.5
 local dayminutes = math.floor(daytime * 24 * 60) % 60
 local dayhour = math.floor(daytime * 24 ) % 24
return string.format("%02d:%02d", dayhour, dayminutes)
end

function format_time_hour(tick)
return string.format("%d:%02d:%02d", math.floor(tick / 216000), math.floor(tick / 3600) % 60, math.floor(tick / 60) % 60)
end


function format_evolution(force)
 return string.format("%.2f", math.floor(force.evolution_factor * 1000) / 10)
end


function shortnumberstring(number)
    local steps = {
        {1,""},
        {1e3,"k"},
        {1e6,"m"},
        {1e9,"g"},
        {1e12,"t"},
    }
    for _,b in ipairs(steps) do
        if b[1] <= number+1 then
            steps.use = _
        end
    end
    local result = string.format("%.1f", number / steps[steps.use][1])
    if tonumber(result) >= 1e3 and steps.use < #steps then
        steps.use = steps.use + 1
        result = string.format("%.1f", tonumber(result) / 1e3)
    end
    return result .. steps[steps.use][2]
end

function my_format_number(number, maxed)
if not maxed then maxed=1000000000 end
local result 
if number < maxed then result=format_number(number)  --- 
	else result=shortnumberstring(number) end
return result
end


function get_gps_tag(position)
if get_gps_tag then 
	return '[gps='..math.floor(position.x)..','..math.floor(position.y)..']'
	else return ''
	end
end



--------------------------------------------------------------------------------------
function iif( cond, val1, val2 )
	if cond then
		return val1
	else
		return val2
	end
end


--for k,v in Sort_a_Table(your_table, function(t,a,b) return t[b] > t[a] end) do
function Sort_a_Table(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--------------------------------------------------------------------------------------
function add_list(list, obj)
	-- to avoid duplicates...
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			return(false)
		end
	end
	table.insert(list,obj)
	return(true)
end

--------------------------------------------------------------------------------------
function del_list(list, obj)
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			table.remove( list, i )
			return(true)
		end
	end
	return(false)
end
--------------------------------------------------------------------------------------
function del_list2(list, list2)
	for i, obj2 in pairs(list2) do del_list(list, obj2) end
end
--------------------------------------------------------------------------------------
function in_list(list, obj)
	for k, obj2 in pairs(list) do
		if obj2 == obj then
			return(k)
		end
	end
	return(nil)
end



function Log(what)
game.write_file("hs.log", serpent.block(what), true)
end

function dLog(what)
log(serpent.block(what))
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
    return math.floor(game.evaluate_expression(formula, { l = level, L = level }))
  else
    return math.floor(technology.research_unit_count) --[[@as double]]
  end
end