--------------------------------------wind----------------
---   https://www.geogebra.org/m/GDgua6HK
---    y = sin(3x/2)/3+sin(2x/2+2)/3+sin(2x/2-3)/2-sin(4x/2+1)/3-sin(5x/2+3)/4-sin(6x/2+4)/2+sin(x/3)+2.5
---    y = 20*(sin(1.5*x)/3+sin(x+2)/3+sin(x-3)/2-sin(2*x+1)/3-sin(2.5*x+3)/4-sin(3*x+4)/2+sin(x/3)+1.5)
---    y = 14*((sin(x/2))+(sin(x/3))+(sin(x/5))+(sin(x/7))+(sin(x/11))+(sin(x/13))+(sin(x/17))+2)


require "util"

script.on_event(defines.events.on_tick, function(event)

	if global.windx == nil then
	global.windx = 0
	end
	
	if global.windz == nil then
	global.windz = 2
	end
		
	if global.windt == nil then
	global.windt = 0
	end
	
	if global.wind_turbine == nil then
	global.wind_turbine = {}
	end
	
	if (game.tick % 6100000) == 0 then
	if global.windx >= 180000000 then
	global.windx = 0
	--game.print("reset 1000s")
	end
	end

  	if (game.tick % 61) == 0 then
	global.windx = global.windx + math.random()/2
	
	local x = global.windx
	local y = (math.sin(x/2)) + (math.sin(x/3)) + (math.sin(x/5)) + (math.sin(x/7)) + (math.sin(x/11)) + (math.sin(x/13)) + (math.sin(x/17)) + (math.sin(x/19)) + (math.sin(x/23)) + (math.sin(x/29)) + 1.5
---	local y = (math.sin(3*x/2)/3)+(math.sin(2*x/2+2)/3)+(math.sin(3*x/2-3)/2)-(math.sin(4*x/2+1)/3)-(math.sin(5*x/2+3)/4)-(math.sin(6*x/2+4)/2)+math.sin(x/3)+5
---	local y = (math.sin(3*x)/3)+(math.sin(2*x+2)/3)+(math.sin(3*x-3)/2)-(math.sin(4*x+1)/3)-(math.sin(5*x+3)/4)-(math.sin(6*x+4)/2)+math.sin(x/3)+5

    global.windt = 0.99*global.windt + math.random() - 0.5 
    global.windz = 0.9*global.windz + 0.1*global.windt
	local z = 0.8*global.windz+3
---	game.print(z)





---			global.wind_next = math.random(0,100)/1000
---		end
---
---        local t = (game.tick % 3600) / 3600.0
---		
---        surface.wind_speed = global.wind_prev + (global.wind_next-global.wind_prev) * t
    
	
	for key,wind_turbine in pairs(global.wind_turbine) do
            if wind_turbine.valid then
                wind_turbine.fluidbox [1]= {name="steam", amount=2000, temperature=14*(y+z)}
            else
                table.remove(global.wind_turbine, key)
            end
		end
	end
end)
-------------------------------------------------------------------------------------------------------------------
------------------------------------------hiden poles---------------------------------------------

   local function on_passive_wood( entity )
   local twt_eletric_pole = entity.surface.create_entity{name="twt-electric-pole", position=entity.position, force=entity.force}
   twt_eletric_pole.minable = false
   twt_eletric_pole.destructible = false
   end

   local function on_passive_steel( entity )
   local twt_eletric_pole2 = entity.surface.create_entity{name="twt-electric-pole2", position=entity.position, force=entity.force}
   twt_eletric_pole2.minable = false
   twt_eletric_pole2.destructible = false
   end

   local function on_passive_huge( entity )
   local twt_eletric_pole3 = entity.surface.create_entity{name="twt-electric-pole3", position=entity.position, force=entity.force}
   twt_eletric_pole3.minable = false
   twt_eletric_pole3.destructible = false
   end
-------------------------------------------------------------------------------------------------------------------
function on_creation(event)
    if event.created_entity.name == "texugo-wind-turbine" or
	event.created_entity.name == "texugo-wind-turbine2" or 
	event.created_entity.name == "texugo-wind-turbine3" then
        local wind_turbine = event.created_entity
        table.insert(global.wind_turbine, wind_turbine)
    end
	if event.created_entity.name == "texugo-wind-turbine" then on_passive_wood( event.created_entity ) end
	if event.created_entity.name == "texugo-wind-turbine2" then on_passive_steel( event.created_entity ) end
	if event.created_entity.name == "texugo-wind-turbine3" then on_passive_huge( event.created_entity ) end
end

function on_remove(event)
--------------------------------------------------------------------------wind1
	if event.entity.name == "texugo-wind-turbine" then
    center = event.entity.position
    for _, entity in pairs(event.entity.surface.find_entities_filtered{
    area = {{center.x-0.5, center.y-0.5}, {center.x+0.5, center.y+0.5}},
    name = "twt-electric-pole"}) do
    entity.destroy()    
    end
	--end 
	elseif event.entity.name == "twt-electric-pole" then
    center = event.entity.position
    for _, entity in pairs(event.entity.surface.find_entities_filtered{
    area = {{center.x-0.5, center.y-0.5}, {center.x+0.5, center.y+0.5}},
    name = "texugo-wind-turbine"}) do
    entity.damage(6666, "neutral")    
    end
	--end 
--------------------------------------------------------------------------wind2

	elseif event.entity.name == "texugo-wind-turbine2" then
    center = event.entity.position
    for _, entity in pairs(event.entity.surface.find_entities_filtered{
    area = {{center.x-0.5, center.y-0.5}, {center.x+0.5, center.y+0.5}},
    name = "twt-electric-pole2"}) do
    entity.destroy()    
    end
	--end
	elseif event.entity.name == "twt-electric-pole2" then
    center = event.entity.position
    for _, entity in pairs(event.entity.surface.find_entities_filtered{
    area = {{center.x-0.5, center.y-0.5}, {center.x+0.5, center.y+0.5}},
    name = "texugo-wind-turbine2"}) do
    entity.damage(6666, "neutral")    
    end
	--end
--------------------------------------------------------------------------wind3
	elseif event.entity.name == "texugo-wind-turbine3" then
    center = event.entity.position
    for _, entity in pairs(event.entity.surface.find_entities_filtered{
    area = {{center.x-0.5, center.y-0.5}, {center.x+0.5, center.y+0.5}},
    name = "twt-electric-pole3"}) do
    entity.destroy()    
    end
	--end
	elseif event.entity.name == "twt-electric-pole3" then
    center = event.entity.position
    for _, entity in pairs(event.entity.surface.find_entities_filtered{
    area = {{center.x-0.5, center.y-0.5}, {center.x+0.5, center.y+0.5}},
    name = "texugo-wind-turbine3"}) do
    entity.damage(6666, "neutral")    
    end
	end
	
	
	
end



script.on_event(defines.events.on_built_entity, on_creation)
script.on_event(defines.events.on_robot_built_entity, on_creation)
script.on_event(defines.events.on_entity_died, on_remove)
script.on_event(defines.events.on_robot_mined_entity, on_remove)
script.on_event(defines.events.on_player_mined_entity, on_remove)