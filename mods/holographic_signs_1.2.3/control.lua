require "util"
require "utils"
require "speech-bubbles"
local format_number = util.format_number

function d_format_number(number, form)
if not form then form = "%.2f" end
return string.format(form, number)
end



local inputs = 
	{
	"hs_hologram_image",
	"hs_signal",
	"hs_logistic",
	"hs_production_m",
	"hs_consumption_m",
	"hs_research",
	"hs_rockets",
	"hs_players",
	"hs_enemy_evolution",
	"hs_kill_count",
--	"hs_wind_speed",
	"hs_timers",
	"hs_pollution",
	"hs_charge"	
	}

local sub_inputs =  {
 ['hs_research'] = {'hs_research_progress','hs_research_time_remaining'},
 ['hs_timers']   = {'hs_total_time','hs_day_time','hs_time_from_last_death'},
 ['hs_rockets'] = {"hs_rockets_launched","hs_item_launched"},
 ['hs_production_m'] = {"hs_production","hs_production_f","hs_production_p","hs_production_ratio","hs_production_ratio_f"},
 ['hs_consumption_m'] = {"hs_consumption","hs_consumption_f","hs_consumption_p"}, 
 ['hs_players'] = {"hs_player_casualties","hs_connected_players"}, 
 ['hs_warpdrive'] = {"hs_wdm_warping_in","hs_wdm_time_on_planet", "hs_native_evolution", "hs_planet_image"},
 }

local cb_opts = {'[img=utility/time_editor_icon]05 s','[img=utility/time_editor_icon]01 m','[img=utility/time_editor_icon]10 m','[img=utility/time_editor_icon]01 h','[img=utility/time_editor_icon]15 h','[img=infinity]'}
 
local sub_options = {
 ['hs_production_ratio'] = {type = "drop-down", options=cb_opts }, 
 ['hs_production_ratio_f'] = {type = "drop-down", options=cb_opts}, 
 }

	

local pk_item_list = {"hs_logistic","hs_production","hs_consumption","hs_item_launched","hs_production_ratio"}
local pk_fluid_list = {"hs_production_f","hs_consumption_f","hs_production_ratio_f"}
local pk_entity_list = {"hs_kill_count"}
local pk_signal_list = {"hs_hologram_image","hs_signal"}



function setup_mod_vars() 
global.entity_speech = global.entity_speech or {}
global.signs = global.signs or {}
global.players = global.players or {} -- to control opened guis
global.last_death_tick = global.last_death_tick or 0
global.force_research = global.force_research or {}

global.inputs = table.deepcopy(inputs)
global.sub_inputs = table.deepcopy(sub_inputs)
--[[global.signs[1] = {entity =
                   text=
				   icon = 
				   add_tag=
				   maptag=}]]
if game.active_mods['shield-projector'] then 
	global.animation = 'hs_hologram_animated'
	else
	global.animation = 'hs_hologram'
	end
if game.active_mods['WindSpeedChanging']  or game.active_mods['nullius'] or game.active_mods['windturbines-redux']  then add_list(global.inputs, "hs_wind_speed") end
if game.active_mods['Warp-Drive-Machine'] then add_list(global.inputs, "hs_warpdrive") add_list(global.inputs, "hs_wind_speed") end
	
ReadRunTimeSettings()	
end




function on_init()
setup_mod_vars()
if game and game.forces.player.technologies['optics'] and game.forces.player.technologies['optics'].researched and (not game.forces.player.recipes['hs_holo_sign'].enabled) then 
	game.forces.player.recipes['hs_holo_sign'].enabled=true
	end
end

function on_configuration_changed()
setup_mod_vars()
ValidateAllSigns()
end
script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)


function ReadRunTimeSettings(event)
global.opt_animation = settings.global["hs-opt-animation"].value
ValidateAnimations()
end
script.on_event(defines.events.on_runtime_mod_setting_changed, ReadRunTimeSettings)



function ValidateAnimations()
for UN, Sign_Data in pairs (global.signs) do
	local animation = Sign_Data.animation
	local entity    = Sign_Data.entity
	if animation and rendering.is_valid(animation) and (not global.opt_animation) then rendering.destroy(animation) Sign_Data.animation=nil end
	if global.opt_animation and ((not animation) or (not rendering.is_valid(animation))) then 
		if global.animation == 'hs_hologram_animated' then
			animation = rendering.draw_animation {
					animation = 'hs_hologram_animated',
					x_scale=0.07,y_scale=0.35,
					target = entity,
					target_offset = {0, -1.1},
					surface = entity.surface,
					animation_offset = 0}
			else 
			animation = rendering.draw_sprite {  
					sprite = 'hs_hologram',
					x_scale=0.4,y_scale=0.5,
					target = entity,
					target_offset = {0, -1.1},
					surface = entity.surface}
			end
		Sign_Data.animation = animation
		end
	end
end



function is_valid_input(input)
local valid = false
if in_list(global.inputs, input) then valid=true 
else
for g,tab in pairs (global.sub_inputs) do 
	if in_list(tab, input) then valid=true break end 
	end
end
return valid
end


-- avoid crash if removed mod icons
function ValidateAllSigns()
for UN, Sign_Data in pairs (global.signs) do
	local entity = Sign_Data.entity
	local icon = Sign_Data.icon
	local input = Sign_Data.input
	-- Manage INPUTS
	if input then 
		if  in_list(pk_signal_list, input) then  --'hs_signal'
			local signal = Sign_Data.input_signal
			if signal then 
				if signal.type=='item' then if not game.item_prototypes[signal.name] then Sign_Data.input=nil end
					elseif signal.type=='fluid' then if not game.fluid_prototypes[signal.name] then Sign_Data.input=nil end
					elseif signal.type=='virtual' then if not game.virtual_signal_prototypes[signal.name] then Sign_Data.input=nil end
					end
				end
		elseif in_list(pk_item_list, input) then 
			local item = Sign_Data.input_item
			if not (item and game.item_prototypes[item]) then Sign_Data.input=nil end
		elseif in_list(pk_fluid_list, input) then 
			local fluid = Sign_Data.input_fluid
			if not (fluid and game.fluid_prototypes[fluid]) then Sign_Data.input=nil end
		elseif input=='hs_kill_count' then 
			local killed = Sign_Data.input_entity
			if not (killed and game.entity_prototypes[killed]) then Sign_Data.input=nil end

        elseif not is_valid_input(input) then Sign_Data.input=nil end  
		end
	-- MAP TAG
	if icon and icon.type and icon.name then 
			if icon.type=='item' then if not game.item_prototypes[icon.name] then Sign_Data.icon=nil end
			elseif icon.type=='fluid' then if not game.fluid_prototypes[icon.name] then Sign_Data.icon=nil end
			elseif icon.type=='virtual' then if not game.virtual_signal_prototypes[icon.name] then Sign_Data.icon=nil end		
			end
		end
	end
end







---Gui creation

function add_gui(parent,element,destroy,style)
local E = parent[element.name]
if destroy and E then E.destroy() E=nil end
if not E then E=parent.add(element) end
if style then for s=1,#style do E.style[style[s][1]]=style[s][2] end end
return E
end



local function open_gui (player, entity)
if not (entity and entity.valid) then return end

local gui = player.gui.screen
--player.opened = nil

local UN = entity.unit_number
local Sign_Data = global.signs[UN] or {}

if not Sign_Data.entity then Sign_Data.entity=entity end

global.players[player.name] = Sign_Data

--gui.clear()

if gui.frame_holo_sign then gui.frame_holo_sign.destroy() end

local frame = add_gui(player.gui.screen,{type = "frame", name = "frame_holo_sign", caption ={'','[img=item/hs_holo_sign]',{'holographic_sign'}}, direction = "vertical"})
player.opened = frame
frame.style.minimal_width = 100
frame.auto_center = true
local tab = add_gui(frame, {type="table", name='tab1',  column_count = 3})

tab.add{type = "label", caption = {'hs_icon'}}.style.font = "default-bold"
tab.add{type = "label", caption = {'hs_text'}}.style.font = "default-bold"
tab.add{type="switch",name='hs_sw_onoff', tooltip={'hs_on_off'}, allow_none_state = false, switch_state=Sign_Data.state or 'right'}


local ico = add_gui(tab, {type="choose-elem-button", name='hs_icon_bt', elem_type="signal"} )  --elem_type ='item' item='steel-plate'    elem_value
ico.elem_value= Sign_Data.icon
local txt = add_gui(tab, {type="textfield", name='hs_text_field' , text =Sign_Data.text} )
local ico = add_gui(tab, {type="choose-elem-button", name='hs_icon_bt', elem_type="signal"} )  --elem_type ='item' item='steel-plate'    elem_value

local btc = add_gui(tab, {type="sprite-button", name='bt_hs_text_color', tooltip={'hs_color'}, style = "tool_button", sprite = "utility/brush_icon"})


local tab = add_gui(frame, {type="table", name='tab_cb',  column_count = 2})
tab.add{type="checkbox",name='hs_cb_add_map', caption={'hs_add_tag'}, state=Sign_Data.add_tag or false}.style.font = "default-bold"
tab.add{type="checkbox",name='hs_cb_plain_text', caption={'hs_plain_text'}, state=Sign_Data.plain_text or false}.style.font = "default-bold"

local tab = add_gui(frame, {type="table", name='tab3',  column_count = 4})
add_gui(tab, {type="sprite-button", sprite = "utility/close_white", name='bt_destroy_my_2parent', style = "back_button" }) --style='rounded_button'style="tool_button"
add_gui(tab, {type="sprite-button", name='bt_holo_sign_textbox', tooltip={'bt_holo_sign_textbox'}, style = "tool_button", sprite = "utility/custom_tag_icon"}) --rename_icon_normal
add_gui(tab, {type="sprite-button", name='bt_holo_sign_inputs', tooltip={'bt_holo_sign_inputs'},style = "tool_button", sprite = "utility/logistic_network_panel_black" }) --"item/red-wire"
add_gui(tab, {type="button", caption ='OK', name='bt_holo_sign_ok', tooltip={'bt_holo_sign_confirm'},  style = "confirm_button"})  



if Sign_Data.input then add_inputs(frame,player) end
if Sign_Data.show_textbox then add_textbox(frame,player)	end


--frame.force_auto_center()
end





-- RGB Color editor
function show_team_color_gui(gui,player)

local Sign_Data = global.players[player.name]
local color = Sign_Data.text_color or {r = 1, g = 1, b = 1}
local frame = gui.hs_color_frame
    if frame then frame.destroy()
    else
		frame = gui.add{type="frame", name="hs_color_frame", direction = "vertical", caption={"hs_color"}} --style=mod_gui.frame_style, 
		
		local tabBars = frame.add{type = "table", name='hs_tab_rgb',  column_count = 2}
		      tabBars.add{type = "label", caption='R'}.style.font_color={r = 1, g = 0.5, b = 0.5}
		local sliderR = tabBars.add{type = "slider", name='hs_slider_color_R', value = color.r,minimum_value=0,maximum_value=1}
	
		      tabBars.add{type = "label", caption='G'}.style.font_color={r = 0.5, g = 1, b = 0.5}
		local sliderG = tabBars.add{type = "slider",  name='hs_slider_color_G', value = color.g,minimum_value=0,maximum_value=1}
		
		      tabBars.add{type = "label", caption='B'}.style.font_color={r = 0.5, g = 0.5, b = 1}
		local sliderB = tabBars.add{type = "slider",  name='hs_slider_color_B', value = color.b,minimum_value=0,maximum_value=1}

		local tabBarsBt = frame.add{type = "table", name='hs_color_bt_tab', column_count = 3}
		
		local btCancel= tabBarsBt.add{name="bt_destroy_my_2parent", type="sprite-button", style = "slot_button", sprite = "utility/deconstruction_mark"} --rounded_button  --back_button
		local btApply = tabBarsBt.add{name="bt_hs_color_apply",  type="sprite-button", style = "slot_button", sprite = "utility/check_mark_green"} --confirm_slot
		local label = tabBarsBt.add{name="label_hs_color",  type="label", caption={"hs_color"}} --confirm_slot
		label.style.font_color = color
		label.style.font = "default-large-bold"
	end
end


function color_apply(gui,player)
local Sign_Data = global.players[player.name]

if gui and gui.hs_tab_rgb then
	local R = gui.hs_tab_rgb.hs_slider_color_R.slider_value
	local G = gui.hs_tab_rgb.hs_slider_color_G.slider_value
	local B = gui.hs_tab_rgb.hs_slider_color_B.slider_value
	Sign_Data.text_color = {r = R, g = G, b = B}
	gui.destroy() 
	end
end


local function on_gui_value_changed(event) 
local gui = event.element
local player = game.players[event.player_index]

if gui.get_mod()=='holographic_signs' then
if gui.type=='slider'  then
	if gui.name=='hs_slider_color_R' or gui.name=='hs_slider_color_G' or gui.name=='hs_slider_color_B' then
		local tab = gui.parent
		local R=tab.hs_slider_color_R.slider_value
		local G=tab.hs_slider_color_G.slider_value
		local B=tab.hs_slider_color_B.slider_value
		local tab = tab.parent
		tab.hs_color_bt_tab.label_hs_color.style.font_color = {r=R,g=G,b=B}
		end
	end
end

end
script.on_event(defines.events.on_gui_value_changed, on_gui_value_changed)






local function on_gui_switch_state_changed(event) 
local gui = event.element
local player = game.players[event.player_index]
if gui.get_mod()=='holographic_signs' then
	if gui.name=="hs_sw_onoff" then
		local Sign_Data = global.players[player.name]
		Sign_Data.state = gui.switch_state
		apply_holo_sign(Sign_Data)
		end
	end
end
script.on_event(defines.events.on_gui_switch_state_changed, on_gui_switch_state_changed)



local function on_gui_click(event) 
local gui = event.element
local player = game.players[event.player_index]

if not (player) then return end
if not (gui and gui.valid) then return end

if gui.name and gui.name~='' then
	if gui.name == "bt_holo_sign_ok" then add_holo_sign(gui.parent.parent,player,event.shift)
		elseif gui.name == "bt_destroy_my_parent" then gui.parent.destroy() 
		elseif gui.name == "bt_destroy_my_2parent" then gui.parent.parent.destroy() 
		elseif gui.name == "bt_holo_sign_textbox" then toggle_textbox(gui.parent.parent,player)
		elseif gui.name == "bt_holo_sign_inputs" then toggle_inputs(gui.parent.parent,player)
		elseif gui.name == "bt_hs_cancel_input" then cancel_input(gui.parent.parent.parent,player) return
		elseif gui.name == "bt_hs_text_color" then show_team_color_gui(gui.parent.parent,player) return
		elseif gui.name == "bt_hs_color_apply" then color_apply(gui.parent.parent,player) return	
		end
end
end
script.on_event(defines.events.on_gui_click, on_gui_click)

function toggle_textbox(gui,player)
if gui.hs_textbox then 
	gui.hs_textbox.destroy()
	else
	add_textbox(gui,player)
	end
end

function toggle_inputs(gui,player)
if gui.hs_inputs then 
	gui.hs_inputs.destroy()
	else
	add_inputs(gui,player)
	end
end

function cancel_input(gui,player)
local Sign_Data = global.players[player.name]
if Sign_Data then Sign_Data.input = nil end
toggle_inputs(gui,player)
end


function add_inputs(gui,player)
local Sign_Data = global.players[player.name]
	if gui.hs_inputs then gui.hs_inputs.destroy() end
	local input = Sign_Data.input
	local frame = gui.add{type="frame", name="hs_inputs",caption={"hs_input_box"}, direction='vertical'}
	frame.style.width=290
	--frame.style.height=100
	-- will need scroll-pane here
	

	--game.print(input)
	if not input   then  
		for i=1, #global.inputs do
			frame.add{type="radiobutton",name=global.inputs[i], caption={global.inputs[i]}, state=iif(global.inputs[i]==input, true, false) }.style.font = "default-bold"
			end
		else
		
		
		local tab = add_gui(frame, {type="table", name='tab_inp_sel',  column_count = 2})
		tab.add{type="label",name=input, caption={input}}.style.font = "default-bold"
		tab.add{name="bt_hs_cancel_input",  type="sprite-button", sprite = "utility/close_black", style = "shortcut_bar_button_small"}
		
		if global.sub_inputs[input] then 
			for i=1, #global.sub_inputs[input] do
				frame.add{type="radiobutton",name=global.sub_inputs[input][i], caption={global.sub_inputs[input][i]}, state=iif(global.sub_inputs[input][i]==input, true, false) }.style.font = "default-bold"
				end			
			end
		
			if in_list(pk_signal_list, input) then
				local ico = add_gui(frame, {type="choose-elem-button", name='hs_choose_input', elem_type="signal"} )  --elem_type ='item' item='steel-plate'    elem_value
				ico.elem_value= Sign_Data.input_signal
			
				elseif (in_list(pk_item_list, input)) then
					local ico = add_gui(frame, {type="choose-elem-button", name='hs_choose_item', elem_type="item"} )  --elem_type ='item' item='steel-plate'    elem_value
					ico.elem_value= Sign_Data.input_item

				elseif (in_list(pk_entity_list, input)) then
					local ico = add_gui(frame, {type="choose-elem-button", name='hs_choose_entity', elem_type="entity", elem_filters={{type = "entity", filter = "entity-with-health"}}  } )  --elem_type ='item' item='steel-plate'    elem_value
					ico.elem_value= Sign_Data.input_entity

				elseif (in_list(pk_fluid_list,input)) then
					local ico = add_gui(frame, {type="choose-elem-button", name='hs_choose_fluid', elem_type="fluid"} )  --elem_type ='item' item='steel-plate'    elem_value
					ico.elem_value= Sign_Data.input_fluid
			--	else
				--	tab.add{type="label"}
				end
				
			if sub_options[input] then 
			   local t=sub_options[input].type
			   if t=="drop-down" then add_gui(frame, {type=t, name=t,items=sub_options[input].options, selected_index = Sign_Data.sub_option or 1}) end
			   end
				
		--add_gui(frame, {type="sprite-button", sprite = "utility/close_white", name='bt_back_input', style = "back_button"}) 
		
		end
--	frame.style.horizontally_stretchable=false
end


local function on_gui_checked_state_changed(event)
local gui = event.element
if gui.get_mod()=='holographic_signs' then
	local player = game.players[event.player_index]
	--if in_list(global.inputs,gui.name) or in_list(global.sub_inputs[1],gui.name) or in_list(global.sub_inputs[2],gui.name) then
	if gui.parent.name=='hs_inputs' then	
		local Sign_Data = global.players[player.name]
		Sign_Data.input = gui.name
		add_inputs(gui.parent.parent,player)
		end
end
end
script.on_event(defines.events.on_gui_checked_state_changed, on_gui_checked_state_changed)



function add_textbox(gui,player)
local Sign_Data = global.players[player.name]
	local textbox = gui.add{type="text-box", name="hs_textbox",text=Sign_Data.textbox}
	textbox.style.width=290
	textbox.style.height=100 --300
	textbox.style.horizontally_stretchable=false
	textbox.word_wrap=true 
end



function add_holo_sign(gui,player,k_shift)
local Sign_Data = global.players[player.name]
local entity = Sign_Data.entity

if entity and entity.valid then 
	local text = gui.tab1.hs_text_field.text
	local icon = gui.tab1.hs_icon_bt.elem_value
	local add_tag = gui.tab_cb.hs_cb_add_map.state
	local plain_text = gui.tab_cb.hs_cb_plain_text.state
	local big_hologram_render = Sign_Data.big_hologram_render
	if big_hologram_render then 
		if big_hologram_render and rendering.is_valid(big_hologram_render) then rendering.destroy(big_hologram_render) end
		Sign_Data.big_hologram_render = nil
		end
	if gui.hs_textbox then 
		Sign_Data.show_textbox = true
		Sign_Data.textbox = gui.hs_textbox.text 
		else 
		Sign_Data.show_textbox = false
		end
	if gui.hs_inputs then 
			if in_list(pk_signal_list, Sign_Data.input) then
				Sign_Data.input_signal = gui.hs_inputs.hs_choose_input.elem_value
				--if k_shift then icon = Sign_Data.input_signal game.print (icon) end 
			elseif in_list(pk_item_list, Sign_Data.input) then
				Sign_Data.input_item = gui.hs_inputs.hs_choose_item.elem_value
				--if k_shift then icon = Sign_Data.input_item game.print (icon) end
			elseif in_list(pk_fluid_list, Sign_Data.input) then
				Sign_Data.input_fluid = gui.hs_inputs.hs_choose_fluid.elem_value
				--if k_shift then icon = Sign_Data.input_fluid game.print (icon)end
			elseif in_list(pk_entity_list, Sign_Data.input) then
				Sign_Data.input_entity = gui.hs_inputs.hs_choose_entity.elem_value
				--if k_shift then icon = Sign_Data.input_entity game.print (icon)end
			else
			--Sign_Data.input = nil
			end
		
		if sub_options[Sign_Data.input] then 
			local t = sub_options[Sign_Data.input].type
			local sub_option
			if t=='drop-down' then sub_option = gui.hs_inputs[t].selected_index end
			Sign_Data.sub_option=sub_option
			end
		
			
		else
		Sign_Data.input = nil
		end
		
	Sign_Data.text      = text
	Sign_Data.icon      = icon
	Sign_Data.add_tag   = add_tag
	Sign_Data.plain_text= plain_text
	
	Sign_Data.last_user = player.name

	apply_holo_sign(Sign_Data)
	end
gui.destroy()
end




local function on_gui_opened(event)
  local player_index = event.player_index
  local player = game.players[player_index]
  if event.entity and event.entity.valid and event.entity.name=='hs_holo_sign' then
      open_gui(player, event.entity)
      else
	  local gui = player.gui.screen
	  if gui.frame_holo_sign then 
		if player.opened ~= gui.frame_holo_sign then gui.frame_holo_sign.destroy() end
		end
	  end
end
script.on_event(defines.events.on_gui_opened, on_gui_opened)


local function on_gui_closed(event)
  if event.element and event.element.valid and event.element.name == 'frame_holo_sign' then
	event.element.destroy()
  end
end
script.on_event(defines.events.on_gui_closed, on_gui_closed)
  
  

function apply_holo_sign(Sign_Data)
	local function get_precision_index(opt)
	local def = {
			defines.flow_precision_index.five_seconds,
			defines.flow_precision_index.one_minute,	
			defines.flow_precision_index.ten_minutes,	
			defines.flow_precision_index.one_hour,	
			defines.flow_precision_index.fifty_hours,	
			defines.flow_precision_index.one_thousand_hours
			}
	return def[opt] or defines.flow_precision_index.one_minute
	end

local entity = Sign_Data.entity

if entity and entity.valid then
local force = entity.force
local text = Sign_Data.text or ''
local icon = Sign_Data.icon
local add_tag = Sign_Data.add_tag 
local input = Sign_Data.input
local color = Sign_Data.text_color or {r=255,g=255,b=255}
local plain_text = Sign_Data.plain_text
local the_plain_text = Sign_Data.the_plain_text
local animation = Sign_Data.animation
local big_hologram_render = Sign_Data.big_hologram_render

local state = Sign_Data.state or 'right'   -- left=off  right=on

local is_it_on = true

if global.all_turned_off==true or state=='left' then is_it_on = false end

-- Manage INPUTS
local ipt, holo_img,img_scale
if is_it_on  then 
	if input then 
			if input=='hs_signal' then 
				local signal = Sign_Data.input_signal
				if signal and signal.type and signal.name then 
					ipt = format_number (entity.get_merged_signal(signal)) --get signal
					end
			elseif input=='hs_hologram_image' then 
				local signal = Sign_Data.input_signal
				if signal and signal.type and signal.name then 
					img_scale = 2
					if signal.type=='virtual' then 
						holo_img ='virtual-signal/'..signal.name 
						
						else
						holo_img =signal.type .. '/'..signal.name 
						end
					end
			elseif input=='hs_logistic' then 
				local item = Sign_Data.input_item
				local logistic_network = entity.surface.find_logistic_network_by_position(entity.position, force)
				if item and logistic_network then 
					ipt = logistic_network.get_item_count(item) --get signal
					end				

			elseif in_list({'hs_production','hs_consumption','hs_item_launched'},input) then 
				local item = Sign_Data.input_item
				if item then 
					local count
						if input=='hs_production' then count = force.item_production_statistics.get_input_count(item)
						elseif input=='hs_consumption' then count  = force.item_production_statistics.get_output_count(item)
						elseif input=='hs_item_launched' then count  = force.get_item_launched(item)
						end
					ipt = format_number(count) 
					end
					
			elseif input=='hs_production_ratio' then 
				local item = Sign_Data.input_item
				if item then 
					local sub_option = Sign_Data.sub_option
					sub_option = get_precision_index(sub_option)
					local count = force.item_production_statistics.get_flow_count{name=item,input=true, precision_index=sub_option}
					local cons = force.item_production_statistics.get_flow_count{name=item,input=false, precision_index=sub_option}
					local ratio = 0
					if cons>0 then ratio=count/cons end
					ipt = math.ceil(count) .. '/' .. math.ceil(cons) ..  iif(count>=cons,'[img=virtual-signal/signal-green]','[img=virtual-signal/signal-red]')..  d_format_number(ratio, "%.1f")
					end
					
			elseif input=='hs_production_ratio_f' then 
				local fluid = Sign_Data.input_fluid
				if fluid then 
					local sub_option = Sign_Data.sub_option
					sub_option = get_precision_index(sub_option)
					local count = force.fluid_production_statistics.get_flow_count{name=fluid,input=true, precision_index=sub_option}
					local cons = force.fluid_production_statistics.get_flow_count{name=fluid,input=false, precision_index=sub_option}
					local ratio = 0
					if cons>0 then ratio=count/cons end
					ipt = my_format_number(math.ceil(count) , 1000000).. '/' .. my_format_number(math.ceil(cons), 1000000) ..  iif(count>=cons,'[img=virtual-signal/signal-green]','[img=virtual-signal/signal-red]')..  d_format_number(ratio, "%.1f")
					end
					

			elseif input=='hs_production_f' or input=='hs_consumption_f' then 
				local fluid = Sign_Data.input_fluid
				if fluid then 
					local count
						if input=='hs_production_f' then count = force.fluid_production_statistics.get_input_count(fluid)
						elseif input=='hs_consumption_f' then count  = force.fluid_production_statistics.get_output_count(fluid)
						end
					ipt = my_format_number(math.floor(count), 1000000)
					end

			elseif input=='hs_production_p' or input=='hs_consumption_p' then 
				local pole = entity.surface.find_entities_filtered{type='electric-pole', force=force, position=entity.position, radius=2, limit=1}
				if pole[1] then 
					local NS = pole[1].electric_network_statistics
					local cons=0
					local prod=0
					-- prod
					for n,v in pairs (NS.output_counts) do 
						prod = prod + NS.get_flow_count{name=n,input=false, precision_index=defines.flow_precision_index.five_seconds, sample=1}
						end
					-- cons
					for n,v in pairs (NS.input_counts) do 
						cons = cons + NS.get_flow_count{name=n,input=true, precision_index=defines.flow_precision_index.five_seconds, sample=1}
						end
					
					prod=prod*60/1000000
					cons=cons*60/1000000
					
					if input=='hs_production_p' then ipt =d_format_number(prod, "%.1f").. " MJ"
						elseif input=='hs_consumption_p' then ipt = d_format_number(cons, "%.1f") .. " MJ"
					end
					end


			elseif  input=='hs_charge' then 
				local ch,t =0,0
				local acc = entity.surface.find_entities_filtered{type='accumulator', force=force}
					for _,a in pairs(acc) do
						ch = ch + a.energy
						t = t + a.electric_buffer_size
						end						
				ipt = d_format_number(ch/1000000, "%.1f") .. " / " .. d_format_number(t/1000000, "%.1f") .. " MJ"


			elseif input=='hs_research_progress' then 
				if force.research_progress then ipt = d_format_number(force.research_progress*100, "%.1f")  end --.. '%'
			elseif input=='hs_rockets_launched' then 
				ipt = format_number(force.rockets_launched )
			elseif input=='hs_connected_players' then 
				ipt = #force.connected_players
			elseif input=='hs_player_casualties' then 
				ipt = force.kill_count_statistics.get_output_count('character')			
			elseif input=='hs_enemy_evolution' then 
				ipt = format_evolution(game.forces.enemy) -- .. '%'
			elseif input=='hs_kill_count' then 
				local killed = Sign_Data.input_entity
				if killed then ipt = format_number(force.kill_count_statistics.get_input_count(killed)) end
			elseif input=='hs_wind_speed' then 
				ipt = d_format_number(entity.surface.wind_speed*100, "%.1f") --  'default 0.02'
			elseif input=='hs_day_time' then 
				ipt = getDayTimeString(entity.surface)
				
			elseif input=='hs_total_time' then 
				ipt = format_time_hour(game.tick)
			elseif input=='hs_time_from_last_death' then 
				ipt = format_time_from_tick(global.last_death_tick)

			elseif input=='hs_research_time_remaining' then 
				ipt = get_force_research_time_remaining(force)

			elseif input=='hs_pollution' then 
				ipt = d_format_number(entity.surface.get_pollution(entity.position))

			--WARP DRIVE MACHINE remote interface
			elseif input=='hs_wdm_warping_in' then 
				ipt = remote.call("WDM","get_ship_warp_time",force.name)
			elseif input=='hs_wdm_time_on_planet' then 
				ipt = remote.call("WDM","get_ship_planet_time",force.name)
			elseif input=='hs_native_evolution' then 
				ipt = remote.call("WDM","get_planet_natives_evolution",force.name)
			elseif input=='hs_planet_image' then 
				holo_img = remote.call("WDM","get_planet_image",force.name)
				img_scale = 0.65
			end
		end


	local iss, ise
	if ipt then
		iss, ise = string.find(text, '|#|')
		if iss then 
			text = string.gsub(text, '|#|', ipt)
			else
			text = text.. ' ' .. ipt
			end
		end

	end

	
local pt = text
if icon and icon.type and icon.name and (not plain_text) then 
	pt = '[img=' .. iif(icon.type=='virtual','virtual-signal', icon.type) .. '/' .. icon.name ..']' .. text 
	end	

local destroy_plan_text = false
clear_speach_bubble(entity)

if (pt~='' or holo_img) and is_it_on then 
	if pt~='' then 
		if plain_text then 
		if the_plain_text and rendering.is_valid(the_plain_text) then 
			rendering.set_color(the_plain_text, color)
			rendering.set_text(the_plain_text, pt)
			else 
			the_plain_text = rendering.draw_text{text=pt, surface=entity.surface, target=entity, color=color,target_offset={-1,-1} }
			Sign_Data.the_plain_text = the_plain_text
			end
		else
			if the_plain_text then destroy_plan_text =true end
			pt = '[color=' .. color.r ..',' .. color.g ..',' .. color.b ..']' .. pt .. '[/color]'
			Entity_Speak(entity,pt) 
			end
		end


	if holo_img then
		if big_hologram_render and rendering.is_valid(big_hologram_render) then 
			if rendering.get_sprite(big_hologram_render) ~= holo_img then rendering.set_sprite(big_hologram_render, holo_img) end
			else
			big_hologram_render = rendering.draw_sprite {  
					sprite = holo_img,
					x_scale=img_scale,y_scale=img_scale,
					target = entity,
					target_offset = {0, -2},
					surface = entity.surface}
			Sign_Data.big_hologram_render=big_hologram_render
			end
		end 
	
	
	if global.opt_animation and ((not animation) or (not rendering.is_valid(animation))) then 
		if global.animation == 'hs_hologram_animated' then
			animation = rendering.draw_animation {
					animation = 'hs_hologram_animated',
					x_scale=0.07,y_scale=0.35,
					target = entity,
					target_offset = {0, -1.1},
					surface = entity.surface,
					animation_offset = 0}
			else 
			animation = rendering.draw_sprite {  
					sprite = 'hs_hologram',
					x_scale=0.4,y_scale=0.5,
					target = entity,
					target_offset = {0, -1.1},
					surface = entity.surface}
			end
		Sign_Data.animation = animation
		end
	
	else
	if the_plain_text then destroy_plan_text =true end
	if animation and rendering.is_valid(animation) then rendering.destroy(animation) Sign_Data.animation=nil end
	if big_hologram_render and rendering.is_valid(big_hologram_render) then rendering.destroy(big_hologram_render) Sign_Data.big_hologram_render=nil end
	end

if destroy_plan_text then 
	rendering.destroy(the_plain_text)
	Sign_Data.the_plain_text = nil
	end


-- MAP TAG
if Sign_Data.maptag and Sign_Data.maptag.valid then Sign_Data.maptag.destroy() end
if add_tag and is_it_on then 
	local ico 
	if icon and icon.type and icon.name then ico=icon end
	if ico or (text~='') then 
		local tag = {icon=ico,text=text,position=entity.position}
		local thetag = force.add_chart_tag(entity.surface,tag)
		Sign_Data.maptag = thetag
		end
	end

local UN = entity.unit_number
global.signs[UN]=Sign_Data
end
end




function update_force_research_durations(force, current_research)
  local force_table = global.force_research[force.name]
  local current_progress = force.research_progress
  local research_time = current_research.research_unit_energy * get_research_unit_count(current_research)

  local last_research_progress = force_table.last_research_progress or 0
  local last_research_progress_tick = force_table.last_research_progress_tick or 0
  local progress_delta = current_progress - last_research_progress
  local tick_delta = game.tick - last_research_progress_tick

  local research_speed = (progress_delta * research_time) / tick_delta

  force_table.last_research_progress = current_progress
  force_table.last_research_progress_tick = game.tick
  force_table.research_speed = research_speed

  local duration_text = "[img=infinity]"
    if research_speed > 0 then
      local level = current_research.level
      local progress = get_research_progress(current_research, level)
      local duration = (1 - progress)
          * get_research_unit_count(current_research, level)
          * current_research.research_unit_energy
          / research_speed
      duration_text = format_t(duration)
    end
	force_table.duration_text = duration_text
end



function get_force_research_time_remaining(force)
if not global.force_research[force.name] then global.force_research[force.name] = {} end

local last_check = global.force_research[force.name].last_research_progress_tick or 0
if game.tick - last_check  > 60 then 
    local current_research = force.current_research
    if current_research then
       update_force_research_durations(force, current_research)
	   else
	   global.force_research[force.name].duration_text = "[img=infinity]"
	   end
  end
return global.force_research[force.name].duration_text
end


function Copy_Sign_Data(Entity, Sign_Data)
	Sign_Data.entity = Entity 
	Sign_Data.maptag = nil
	Sign_Data.animation = nil
	Sign_Data.the_plain_text = nil
	Sign_Data.big_hologram_render=nil
	local NUN = Entity.unit_number
	if global.signs[NUN] then 
		if global.signs[NUN].the_plain_text then 
			rendering.destroy(global.signs[NUN].the_plain_text)
			global.signs[NUN].the_plain_text=nil
			end
		if global.signs[NUN].animation then 
			rendering.destroy(global.signs[NUN].animation)
			global.signs[NUN].animation=nil
			end			
		if global.signs[NUN].big_hologram_render then 
			rendering.destroy(global.signs[NUN].big_hologram_render)
			global.signs[NUN].big_hologram_render=nil
			end

		
		if global.signs[NUN].maptag and global.signs[NUN].maptag.valid then global.signs[NUN].maptag.destroy() end
		end
	global.signs[NUN] = Sign_Data
	apply_holo_sign(Sign_Data)
end


function on_entity_cloned(event)
local new = event.destination
local old = event.source
if new.name=='hs_holo_sign' and old.name=='hs_holo_sign' then
local UN = old.unit_number
if global.signs[UN] then 
	local Sign_Data = table.deepcopy(global.signs[UN])
	Copy_Sign_Data(new, Sign_Data)
	end
	end
end
script.on_event(defines.events.on_entity_cloned, on_entity_cloned, {{filter = "name", name = 'hs_holo_sign'}})
script.on_event(defines.events.on_entity_settings_pasted, on_entity_cloned)



function on_player_setup_blueprint(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end

  local item = player.cursor_stack
  if not (item and item.valid_for_read) then
    item = player.blueprint_to_setup
    if not (item and item.valid_for_read) then return end
  end
  local count = item.get_blueprint_entity_count()
  if count == 0 then return end

  for index, entity in pairs(event.mapping.get()) do
    if entity.valid and entity.name == "hs_holo_sign" then
	  local UN = entity.unit_number
	  if global.signs[UN] then 
		local Sign_Data = table.deepcopy(global.signs[UN])	 
			if index <= count then
			  item.set_blueprint_entity_tag(index, "Sign_Data", Sign_Data)
			  end
		end
    end
    end
end
script.on_event(defines.events.on_player_setup_blueprint, on_player_setup_blueprint)


function restore_data_from_tags(entity, tags)
  local Sign_Data = tags.Sign_Data
  if not Sign_Data then return end
  Copy_Sign_Data(entity, Sign_Data)
end

local ghost_revived_event = function(event)
  local entity = event.created_entity or event.entity
  if not (entity and entity.valid) then return end
  if entity.name ~= "hs_holo_sign" then return end

  local tags = event.tags
  if not tags then return end

  restore_data_from_tags(entity, tags)
end
script.on_event(defines.events.on_robot_built_entity, ghost_revived_event)
script.on_event(defines.events.script_raised_revive, ghost_revived_event)


function on_post_entity_died(event)
  local UN = event.unit_number
  if not UN then return end
  if global.signs[UN] then 
  local Sign_Data = table.deepcopy(global.signs[UN])
  if not Sign_Data then return end
  local ghost = event.ghost
  if not (ghost and ghost.valid) then return end
  local tags = ghost.tags or {}
  tags.Sign_Data = Sign_Data
  ghost.tags = tags
  end
end
script.on_event(defines.events.on_post_entity_died, on_post_entity_died)

script.on_event(defines.events.on_pre_player_died, function(event)
local player = game.players[event.player_index]
global.last_death_tick = game.tick
end)










commands.add_command('hologram-turn-on', 'Turn ON all holograms', function(event)
local player = game.players[event.player_index]
if player.admin then 
    global.all_turned_off = false
	UpdateAll()
	end
end)
commands.add_command('hologram-turn-off', 'Turn OFF all holograms', function(event)
local player = game.players[event.player_index]
if player.admin then 
    global.all_turned_off = true
	UpdateAll()
	end
end)

 
function UpdateAll()
for UN, Sign_Data in pairs (global.signs) do
	local entity = Sign_Data.entity
	if entity and entity.valid then apply_holo_sign(Sign_Data)
	else global.signs[UN]=nil end
	end
end


script.on_nth_tick(60*2, function (event)
for UN, Sign_Data in pairs (global.signs) do
	local entity = Sign_Data.entity
	if entity and entity.valid then
		local green = entity.get_merged_signal({type="virtual",name='signal-green'})==1
		local red   = entity.get_merged_signal({type="virtual",name='signal-red'})==1
		if green then Sign_Data.state='right' end		
		if red then Sign_Data.state='left' end
		if Sign_Data.input or green or red then apply_holo_sign(Sign_Data) end
		else
		global.signs[UN]=nil
		end
	end
end)



--------------------------------------------------------------------------------------

-- INTERFACE
	
--------------------------------------------------------------------------------------
local interface = {}
function interface.refresh_all()
UpdateAll()
end
remote.add_interface( "holographic_signs", interface )


