local max_smog = 1000
local powers = {90, 70, 50, 30, 10, 1}

script.on_init(function(data)
	global = {}
	global.enabled = true
	global.panels = {}
	global.empty_panels_table = true
	global.last_panel = 0
	
	for i, surface in pairs (game.surfaces) do
		local entities = surface.find_entities_filtered{type = 'solar-panel'}
		if entities then
			for j, entity in pairs (entities) do 
				add_to_table(entity)
			end
		end
	end
end)


script.on_event(defines.events.on_built_entity, function(event)
	local entity = event.created_entity
	if entity.type == 'solar-panel' then
		add_to_table(entity)
	end
end)


script.on_event(defines.events.on_robot_built_entity, function(event)
	local entity = event.created_entity
	if entity.type == 'solar-panel' then
		add_to_table(entity)
	end
end)


function add_to_table(entity)
	local panel = {entity = entity, power = 100, orig_name = entity.name}
	table.insert (global.panels, panel)
	global.empty_panels_table = false
end


script.on_event(defines.events.on_tick, function(event)
	if global.empty_panels_table or (global.enabled == false) then return end
	
	local next_panel = global.last_panel + 1
	if not (global.panels[next_panel]) then
		global.last_panel = 0
		return
	end
	global.last_panel = next_panel
	local panel = global.panels[next_panel]
	
	local entity = panel.entity
	if not (entity.valid) then
		table.remove (global.panels, next_panel)
		global.last_panel = next_panel - 1
		if #global.panels == 0 then
			global.empty_panels_table = true
		end
		return
	end
	
	local force = entity.force
	
	local surface = entity.surface
	local position = entity.position
	local transp_p = (100-math.floor(100*surface.get_pollution(position)/max_smog)) -- in percents
	local power_p = 100
	for i, p in pairs (powers) do
		if transp_p < p then
			power_p = p
		end
	end
	if panel.power == power_p then -- nothing to replace
		return
	end
	
	if power_p == 100 then
		entity.destroy()
		
		local new_entity = surface.create_entity{
			name=panel.orig_name, 
			position=position, 
			force=force, 
			fast_replace=false, 
			spill=false,
			create_build_effect_smoke = false}
		global.panels[next_panel] = {entity = new_entity, power = 100, orig_name = panel.orig_name}
		return
	end
	
	local new_name = 'ssp-'..panel.orig_name..'-'..power_p
	if not (game.entity_prototypes[new_name]) then
		table.remove (global.panels, next_panel)
		global.last_panel = next_panel - 1
		if #global.panels == 0 then
			global.empty_panels_table = true
		end
		return
	end
	
	
	entity.destroy()
	local new_entity = surface.create_entity{
		name=new_name, 
		position=position, 
		force=force, 
		fast_replace=false, 
		spill=false,
		create_build_effect_smoke = false} -- can't fast replace!
	
--	draw_text{text=…, surface=…, target=…, target_offset=…, color=…, scale=…, font=…, time_to_live=…, forces=…, players=…, visible=…, draw_on_ground=…, orientation=…, alignment=…, scale_with_zoom=…, only_in_alt_mode=…} → uint64

	rendering.draw_text{
		text=(power_p.."%"), 
		surface=surface, 
		target=new_entity, 
		target_offset = {-0.25, -0.3},
		forces={new_entity.force.name}, 
		only_in_alt_mode = true, 
		color = {0.5, 0.5,0.7}}
	
	global.panels[next_panel] = {entity = new_entity, power = power_p, orig_name = panel.orig_name}
end)


--on_runtime_mod_setting_changed
--Called when a runtime mod setting is changed by a player.

--Contains
--player_index :: uint (optional): The player who changed the setting or nil if changed by script.
--setting :: string: The setting name that changed.
--setting_type :: string: The setting type: "runtime-per-user", or "runtime-global".

function replace_all_to_default ()
	for i, panel in pairs (global.panels) do
--		local panel = {entity = entity, power = 100, orig_name = entity.name}
		local entity = panel.entity
		local force = entity.force
		local surface = entity.surface
		local position = entity.position
		entity.destroy()
		
		local new_entity = surface.create_entity{
			name=panel.orig_name, 
			position=position, 
			force=force, 
			fast_replace=false, 
			spill=false}
		panel.entity = new_entity
		panel.power = 100
	end
end


script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	local setting = event.setting
	if (setting == "ssp-mod-enabled") then
		global.enabled = settings.global["ssp-mod-enabled"].value
		game.print ('[Smog: Solar Panels] enabled: ' .. tostring(global.enabled))
	end
	if not global.enabled then
		replace_all_to_default ()
	end
end)


script.on_configuration_changed(function(data)
	if (global.enabled == nil) then 
		global.enabled = true
	end
	
end)


















