
local color_normal,color_low,color_critical

local colorbase_r, colorbase_g, colorbase_b, colorbase_a
local norm_r, norm_g, norm_b, norm_a
local crit_r, crit_g, crit_b, crit_a

local disp_mode
--local 

local draw_norm=	{target_offset={.0,-.1},only_in_alt_mode=true,scale=1.125,scale_with_zoom=true,alignment="center"}
local draw_low=		{target_offset={.0,-.1},only_in_alt_mode=true,scale=1.125,scale_with_zoom=true,alignment="center"}
local draw_crit=	{target_offset={.0,-.1},only_in_alt_mode=true,scale=1.125,scale_with_zoom=true,alignment="center"}

local draw_icon = {sprite="ammo-icon-white",use_target_orientation=false,render_layer=137}

local friend_ref

local _TURRET_INV = defines.inventory.turret_ammo
local _mag_size,_turret_mags = {},{}

local function mag_size(m)
	local x=_mag_size[m]
	if x == nil then
		x = game.item_prototypes[m].magazine_size
		_mag_size[m] = x
	end
	return x
end

local function turret_mags(t)
	local x=_turret_mags[t]
	if x == nil then
		x = game.entity_prototypes[t].automated_ammo_count
		_turret_mags[t] = x
	end
	return x
end


local drawparams={time_to_live=61,target_offset={.2,.375},forces={},only_in_alt_mode=true,scale=1.125,scale_with_zoom=true,alignment="right"}
local function do_turret(t)
	local m,info
	
	if disp_mode=="shot" then
		local i,s=t.get_inventory(_TURRET_INV)
		local shots = 0
		m = 0
		for j=1,#i do
			s=i[j]
			if s.valid_for_read then
				m = m + s.count
				shots = shots + mag_size(s.name)--[[s.prototype.magazine_size--]] * (s.count-1) + s.ammo
			end
		end
		if m == 0 then return 
		elseif m <= 1 then
			info = draw_crit
		elseif m < turret_mags(t.name) then --t.prototype.automated_ammo_count then
			info = draw_low
		else
			info = draw_norm
		end
		info.text = shots
	else
		m = t.get_inventory(_TURRET_INV).get_item_count() or 0
		if m == 0 then return end
		if disp_mode=="magazine" then
			if m <= 1 then
				info = draw_crit
			elseif m < turret_mags(t.name) then --t.prototype.automated_ammo_count then
				info = draw_low
			else
				info = draw_norm
			end
			info.text = m
		else
--			m = m/(t.prototype.automated_ammo_count)
			m = m/(turret_mags(t.name))
			if m>=1 then return end
			
			local color
			
			if disp_mode=="scaled-icon" then
				local scale = 1/(1+m)
				draw_icon.x_scale = scale
				draw_icon.y_scale = scale
			end

			m=m*2
			
			
			if m < 1 then
				m=1-m
				draw_icon.tint = {colorbase_r + m*crit_r, colorbase_g + m*crit_g, colorbase_b + m*crit_b, (colorbase_a + crit_a)*(m/2)}
			else
				m = m - 1
				draw_icon.tint = {colorbase_r + m*norm_r, colorbase_g + m*norm_g, colorbase_b + m*norm_b, (colorbase_a + norm_a)*(1-m)/2}
			end
			draw_icon.surface = t.surface
			draw_icon.target = t

			rendering.draw_sprite(draw_icon)
			return
		end
	end
	
	info.target=t
	info.surface=t.surface
	info.forces=friend_ref[t.force.name]
	
	rendering.draw_text(info)

end

local function team_views()
	local f
	friend_ref = {}
	for m,u in pairs(game.forces) do
		l = {u}
		for _,t in pairs(game.forces) do
			if u.get_friend(t) then l[#l+1] = t end
		end
		friend_ref[m]=l
	end
	--game.print(serpent.line(friend_ref))
end


local function update()
	local turrets = {}
	for _,p in pairs(game.connected_players) do
		for _,t in pairs(p.surface.find_entities_filtered{type="ammo-turret",position=p.position,radius=100}) do
			turrets[t]=true
		end
	end
	--game.print(serpent.line(turrets))
	if not friend_ref then team_views() end
	for t in pairs(turrets) do
		do_turret(t)
	end
end

local function set()

--	color_normal = settings.global["nearby-ammo-color-normal"].value
--	color_low = settings.global["nearby-ammo-color-low"].value
--	color_critical = settings.global["nearby-ammo-color-critical"].value


	draw_icon.render_layer = 139 --or 137

	draw_norm.color = settings.global["nearby-ammo-color-normal"].value
	draw_low.color = settings.global["nearby-ammo-color-low"].value
	draw_crit.color = settings.global["nearby-ammo-color-critical"].value
	
	colorbase_r = draw_low.color.r
	norm_r = draw_norm.color.r - colorbase_r
	crit_r = draw_crit.color.r - colorbase_r

	colorbase_g = draw_low.color.g
	norm_g = draw_norm.color.g - colorbase_g
	crit_g = draw_crit.color.g - colorbase_g

	colorbase_b = draw_low.color.b
	norm_b = draw_norm.color.b - colorbase_b
	crit_b = draw_crit.color.b - colorbase_b

	colorbase_a = draw_low.color.a
	norm_a = draw_norm.color.a - colorbase_a
	crit_a = draw_crit.color.a - colorbase_a

	disp_mode = settings.global["nearby-ammo-display-mode"].value
	
	if disp_mode=="icon" then
		draw_icon.x_scale = 1
		draw_icon.y_scale = 1
	end
	
	script.on_nth_tick(nil)
	local t = math.floor(60/settings.global["nearby-ammo-update-per-second"].value)
	script.on_nth_tick(t,update)
	t=t+1
	draw_norm.time_to_live = t
	draw_low.time_to_live = t
	draw_crit.time_to_live = t
	draw_icon.time_to_live = t
	
end


local function initialize()
	set()
	team_views()
end




script.on_event(defines.events.on_runtime_mod_setting_changed, set)
script.on_event({defines.events.on_force_friends_changed,
				 defines.events.on_forces_merged,
				 }, team_views)
script.on_load(set)
script.on_init(set)
