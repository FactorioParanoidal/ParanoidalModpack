--todo (sigh), this is old spaghetti, maybe make it fresh, use a map of unit number and next() to clean it up...

function check_interfaces()
  local count = global.wind_interfaces_index
  if not count then count = 1 end
  local array = global.wind_interfaces
  if not array then array = {} end
  local max = global.wind_interfaces_max_count
  if not max then max = 1 end
  local entity = array[count]
  if entity then
    if entity.valid then
      if entity.is_connected_to_electric_network() then
        local power = 10000*entity.surface.wind_speed
        local this_power = power * (math.random()+0.5)
        entity.power_production = this_power
        entity.electric_buffer_size = this_power
      end
    else
      array[count] = nil
    end
  end
  if count >= max then
    count = 1
  else
    count = count + 1
  end
  global.wind_interfaces_index = count
  global.wind_interfaces = array
  global.wind_interfaces_max_count = max
end

function built_interface(entity)
  if not entity.valid then return end
  local count = global.wind_interfaces_max_count + 1
  local power = 10000*entity.surface.wind_speed
  global.wind_interfaces[count] = entity
  entity.energy = 1000
  entity.power_production = power
  global.wind_interfaces_max_count = count
end

function change_wind_hour()
  global.wind_hour = math.random(5,40)/1000
end

function change_wind_day()
	global.wind_day = math.random(80,120)/100
end

function tick_wind()

  global.wind_day = global.wind_day or 1
  global.wind_hour = global.wind_hour or 0.02

  local nv = global.wind_hour * global.wind_day
  for k, s in pairs(game.surfaces) do
    local v = s.wind_speed
    dv = (nv-v)/45
    s.wind_speed = v + dv
  end
end
