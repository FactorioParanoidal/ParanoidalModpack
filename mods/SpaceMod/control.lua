require ("util")
local mod_gui = require ("mod-gui")


MOD_NAME = "SpaceMod"

global = global or {}

if global.launchMult == nil then

	global.launchProfile = settings.startup["SpaceX-launch-profile"].value
	if global.launchProfile == "Classic" then
		global.launchMult = 1
	elseif global.launchProfile == "Launch Mania(x5)" then
		global.launchMult = 5
	elseif global.launchProfile == "Launch Meglo-mania(x25)" then
		global.launchMult = 25
	else
		global.launchMult = 1
	end

end
	
local launchMult = global.launchMult
spaceshiprequirements = {
   satellite = 7 * launchMult,
   drydockstructure = 10 * launchMult,
   drydockcommand = 2 * launchMult,
   shipcasings = 10 * launchMult,
   shipthrusters = 4 * launchMult,
   shiptprotectionfield = 1 * launchMult,
   shipfusionreactor = 1 * launchMult,
   shipfuelcells = 2 * launchMult,
   shiphabitation = 1 * launchMult,
   shiplifesupport = 1 * launchMult,
   shipastrometrics = 1 * launchMult,
   shipcommand = 1 * launchMult,
   shipftldrive = 1 * launchMult
   }

local function glob_init()

  global = global or {}
  global.requirements = spaceshiprequirements
  if global.launches == nil then
    global.launches = {
      satellite = 0,
      drydockstructure = 0,
      drydockcommand = 0,
      shipcasings = 0,
      shipthrusters = 0,
      shiptprotectionfield = 0,
      shipfusionreactor = 0,
      shipfuelcells = 0,
      shiphabitation = 0,
      shiplifesupport = 0,
      shipastrometrics = 0,
      shipcommand = 0,
      shipftldrive = 0
	  }
	end
end

function debugp(text)
	-- for _, player in pairs(game.players) do
		-- player.print(text)
	-- end
end

local function gui_init(player, after_research)

	local button = mod_gui.get_button_flow(player).space_toggle_button
    if button then
	  if player.force.technologies["rocket-silo"].researched ~= true then
        button.destroy() 
	  end
      return	  
    end 

    if (player.force.technologies["rocket-silo"].researched or after_research) then

        -- player.gui.top.add{
		mod_gui.get_button_flow(player).add{
            type = "button",
            name = "space_toggle_button",
			style = mod_gui.button_style,
            caption = {"space-toggle-button-caption"}
        }
		
    end

end

local function on_player_created(event)
  gui_init(game.players[event.player_index], false)
end


function gui_open_frame(player)

	local frame = mod_gui.get_frame_flow(player).space_progress_frame
	
	-- if frame then 
	if not frame then return end
	frame.clear()

    -- Now we can build the GUI.
	
	-- Launch history, if any
	if global.spacex == nil then
	elseif global.spacex > 0 then 
		local ltext = "Interstellar Launches: " .. global.spacex
		local launch = frame.add{type = "table", name = "launch_info", column_count = 2, style = "SpaceMod_table_style"}
		launch.add{type = "label", caption = ltext, style = "caption_label"}
		launch.add{
            type = "button",
            name = "launch_log",
			style = mod_gui.button_style,
            caption = "Log",
			tooltip = {"spacex-log-tooltip"}
        }
	end
	
	local sat_title = frame.add{type = "label", caption = {"satellite-network-progress-title"}, style = "caption_label"}
	local satellite = frame.add{type = "table", name = "satellite", column_count = 2, style = "SpaceMod_table_style"}
	satellite.style.column_alignments[2] = "right"	
 --   satellite.add{type = "label", caption = "-Satellites launched : "}
	satellite.add{type = "label", caption = {"SpaceX-Progress.satellites"} }
	satellite.add{type = "label", caption = " : " .. global.launches.satellite .. "/" .. global.requirements.satellite}
	

	-- Test for satellite network established condition
	if global.launches.satellite < global.requirements.satellite then
	  return
	end

--    drydock_frame_title(drydock)	
	local drydock_title = frame.add{type = "label", caption = {"drydock-progress-title"}, style = "caption_label"}
	local drydock = frame.add{type = "table", name = "drydock", column_count = 2, style = "SpaceMod_table_style"}
	drydock.style.column_alignments[2] = "right"
--	drydock.add{type = "label", caption = "-Drydock Structure Component : "}
	drydock.add{type = "label", caption = {"SpaceX-Progress.dsc"} }	
	drydock.add{type = "label", caption = " : " .. global.launches.drydockstructure .. "/" .. global.requirements.drydockstructure}
--	drydock.add{type = "label", caption = "-Drydock Assembly Component : "}
	drydock.add{type = "label", caption = {"SpaceX-Progress.dac"} }
	drydock.add{type = "label", caption = " : " .. global.launches.drydockcommand .. "/" .. global.requirements.drydockcommand}
	
	-- Test for drydock built condition
	if (global.launches.drydockstructure < global.requirements.drydockstructure or 
		global.launches.drydockcommand < global.requirements.drydockcommand) then
		return
	end
	
	local ship_title = frame.add{type = "label", caption = {"ship-progress-title"}, style = "caption_label"}
	local gui_ship = frame.add{type = "table", name = "ship", column_count = 2, style = "SpaceMod_table_style"}
	gui_ship.style.column_alignments[2] = "right"
--	gui_ship.add{type = "label", caption = "-Protection Field...... : "}
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.protection"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shiptprotectionfield .. "/" .. global.requirements.shiptprotectionfield}
--	gui_ship.add{type = "label", caption = "-Fusion Reactor........ : "}
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.fusion"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shipfusionreactor .. "/" .. global.requirements.shipfusionreactor }
--	gui_ship.add{type = "label", caption = "-Habitation............... : "}	
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.habitation"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shiphabitation .. "/" .. global.requirements.shiphabitation}
--	gui_ship.add{type = "label", caption = "-Life Support........... : "}	
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.life"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shiplifesupport .. "/" .. global.requirements.shiplifesupport}
--	gui_ship.add{type = "label", caption = "-Astrometrics.......... : "}	
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.astro"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shipastrometrics .. "/" .. global.requirements.shipastrometrics}
--	gui_ship.add{type = "label", caption = "-Command................ : "}	
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.command"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shipcommand .. "/" .. global.requirements.shipcommand}
--	gui_ship.add{type = "label", caption = "-Fuel Cells............... : "}	
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.fuel"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shipfuelcells .. "/" .. global.requirements.shipfuelcells}
--	gui_ship.add{type = "label", caption = "-Thrusters.............. : "}	
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.thrusters"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shipthrusters .. "/" .. global.requirements.shipthrusters}
--	gui_ship.add{type = "label", caption = "-Hull components.. : "}	
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.hull"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shipcasings .. "/" .. global.requirements.shipcasings}
--	gui_ship.add{type = "label", caption = "-FTL drive............. : "}
	gui_ship.add{type = "label", caption = {"SpaceX-Progress.ftl"} }
	gui_ship.add{type = "label", caption = " : " .. global.launches.shipftldrive .. "/" .. global.requirements.shipftldrive}
	
end

script.on_configuration_changed( function(event) 
  local changed = event.mod_changes and event.mod_changes["SpaceMod"]

  if changed then
	debugp("Processing mod change")
	global.spacex_com = global.spacex_com or {}
	for _,surface in pairs(game.surfaces) do
		debugp("Surface found")
		for _,spacexCom in pairs(surface.find_entities_filtered{type="constant-combinator", name="spacex-combinator"}) do
			debugp("Found an old spacex combinator")
			table.insert(global.spacex_com, {entity = spacexCom})	
		end
	end   
		local status,err = pcall(function()

			if game.players ~= nil then
				for _, player in pairs(game.players) do
					local frame = player.gui.left["space-progress-frame"]
					if frame then
						frame.destroy()					
					end
					local button = player.gui.top["space-toggle-button"]
					if button then
						button.destroy()
					end
					gui_init(player, player.force.technologies["rocket-silo"].researched)

					player.print("Mod version changed processed")
				end
			end
			for _, force in pairs(game.forces) do
				if force.technologies["space-assembly"].researched then
					force.recipes["spacex-combinator"].enabled=true
				end
			end		
		end)
	end
end)

-- local function on_gui_click(event)

	
-- end
  
local function gui_open_spacex_launch_gui(player)
	local gui = mod_gui.get_frame_flow(player)
	local gui_spacex = gui.spacex_launch
		if gui_spacex then
			gui_spacex.destroy()
			return
		end
		gui_spacex = gui.add{
			type = "frame",
			name = "spacex_launch",
			direction = "vertical",
			style = mod_gui.frame_style
			}
	if not gui_spacex then return end
	gui_spacex.clear()
	local sub_title = gui_spacex.add{type = "label", caption = {"spacex-launch-title"}, style = "caption_label"}
	-- local sxtxt_table = gui_spacex.add{type = "table", name = "spacex_launchtxt_table", column_count = 1}
	gui_spacex.add{type = "label", caption = {"spacex-completion-text"}, style = "Launch_label_style"}
	gui_spacex.add{type = "label", caption = " ", style = "Launch_label_style"}
	gui_spacex.add{type = "label", caption = {"spacex-completion-text1"}, style = "Launch_label_style"}
	gui_spacex.add{type = "label", caption = " ", style = "Launch_label_style"}	
	gui_spacex.add{type = "label", caption = {"spacex-completion-text2"}, style = "Launch_label_style"}
	gui_spacex.add{type = "label", caption = " ", style = "Launch_label_style"}
	gui_spacex.add{type = "label", caption = {"spacex-completion-text3"}, style = "Launch_label_style"}
	gui_spacex.add{type = "label", caption = " ", style = "Launch_label_style"}	
	gui_spacex.add{type = "label", caption = {"spacex-completion-text4"}, style = "caption_label"}
	gui_spacex.add{type = "label", caption = " ", style = "Launch_label_style"}	
--	local sxtext = gui_spacex.add{type = "label", text = stext, style = "Launch_text_box_style"}
	if player.admin then
	local sctable = gui_spacex.add{type = "table", name = "spacex_launch_table", column_count = 2, style = "SpaceMod_table_style"}
	sctable.style.minimal_width = 400
	sctable.style.horizontally_stretchable = "on"
	sctable.style.column_alignments[2] = "right"
		sctable.add{
            type = "button",
            name = "bio_button",
			style = mod_gui.button_style,
            caption = "Yes, Bring it On!",
			tooltip = {"spacex-bio-tooltip"}
        }	
	local iwmm = sctable.add{
            type = "button",
            name = "iwmm_button",
			style = mod_gui.button_style,
            caption = "No, I want my mummy!",
			tooltip = {"spacex-iwmm-tooltip"}
        }
	else
		gui_spacex.add{
		    type = "button",
            name = "notadmin_button",
			style = mod_gui.button_style,
            caption = "Admins Choice!",
			tooltip = {"spacex-notadmin-tooltip"}
        }
	end
end	

local function get_launch_log()
	global.launch_log = global.launch_log or {}
	local seconds = 60
	local minutes = 60 * seconds
	local hours = 60 * minutes
	local days = 24 * hours
	
	local log_tick = game.tick
	local log_days = (log_tick - (log_tick % days)) / days 
	log_tick = log_tick - (log_days * days)
	local log_hours = (log_tick - (log_tick % hours)) / hours 
	log_tick = log_tick - (log_hours * hours)
	local log_minutes = (log_tick - (log_tick % minutes)) / minutes 
	log_tick = log_tick - (log_minutes * minutes)
	local log_seconds = (log_tick - (log_tick % seconds)) / seconds 
	log_entry = log_days .. " Days: " .. log_hours .. " Hours: " .. log_minutes .. " Minutes: " .. log_seconds .. " Seconds" 
	return log_entry
end

local function gui_log_open(player)
	local gui = mod_gui.get_frame_flow(player)
	local llog = gui.spacex_log
	local scroll = llog.add{type = "scroll-pane", name = "scroll"}
	scroll.style.maximal_height = 800	
	local logtable = scroll.add{type = "table", name = "spacex_log_table", column_count = 2, style = "SpaceMod_table_style"}
	for i,launch in pairs(global.launch_log) do
		logtable.add{type = "label", caption = "#" .. i .. "- " .. launch.log, style = "Launch_label_style"}
		if player.admin then
			logtable.add{type = "textfield", name = "logdetail" .. i, enabled = true, text = launch.detail}
		else
			logtable.add{type = "textfield", name = "logdetail" .. i, enabled = false, text = launch.detail}
		end
	end
end

script.on_event(defines.events.on_gui_text_changed, function(event)
	local element = event.element
	local player = game.players[event.player_index]
	 
	if string.find(element.name, "logdetail") then
		if player.admin then
			local cur_log = tonumber(string.match(element.name, "%d+"))	
			global.launch_log[cur_log].detail = element.text
		end
	end
		
end)

function get_spacex_cb(entity)
	if entity.valid == true then
	local cb = entity.get_or_create_control_behavior()
	-- cb.parameters = cb.parameters or {}
	local satellite = global.requirements.satellite - global.launches.satellite
	local dsc = global.requirements.drydockstructure - global.launches.drydockstructure
	local dac = global.requirements.drydockcommand - global.launches.drydockcommand
	local fusion = global.requirements.shipfusionreactor - global.launches.shipfusionreactor
	local fuelcell = global.requirements.shipfuelcells - global.launches.shipfuelcells
	local hull = global.requirements.shipcasings - global.launches.shipcasings
	local shield = global.requirements.shiptprotectionfield - global.launches.shiptprotectionfield
	local thruster = global.requirements.shipthrusters - global.launches.shipthrusters
	local habitation = global.requirements.shiphabitation - global.launches.shiphabitation
	local life = global.requirements.shiplifesupport - global.launches.shiplifesupport
	local command = global.requirements.shipcommand - global.launches.shipcommand
	local astro = global.requirements.shipastrometrics - global.launches.shipastrometrics
	local ftl = global.requirements.shipftldrive - global.launches.shipftldrive
	local params = nil
	
	if satellite > 0 then
		debugp("spacex satellite")
		cb.parameters = {
			{
				signal = {
					type = "item",
					name = "satellite"
				},
				count = satellite,
				index = 1
			},
			{
				signal = {
					type = "virtual",
					name = "signal-S"
				},
				count = 1,
				index = 2
			}
		}	
	elseif (dsc > 0) or (dac > 0) then
		debugp("spacex drydock")
		cb.parameters = {
			{
				signal = {
					type = "item",
					name = "drydock-structural"
				},
				count = dsc,
				index = 1
			},
			{
				signal = {
					type = "item",
					name = "drydock-assembly"
				},
				count = dac,
				index = 2
			},
			{
				signal = {
					type = "virtual",
					name = "signal-S"
				},
				count = 2,
				index = 3
			}
		}		
	elseif (fusion > 0) or
			(fuelcell > 0) or
			(hull > 0) or
			(shield > 0) or
			(thruster > 0) or
			(habitation > 0) or
			(life > 0) or
			(command > 0) or
			(astro > 0) or
			(ftl > 0) then
		debugp("spacex endphase")
		cb.parameters = {
			{
				signal = {
					type = "item",
					name = "fusion-reactor"
				},
				count = fusion,
				index = 1
			},
			{
				signal = {
					type = "item",
					name = "hull-component"
				},
				count = hull,
				index = 2
			},
			{
				signal = {
					type = "item",
					name = "protection-field"
				},
				count = shield,
				index = 3
			},
			{
				signal = {
					type = "item",
					name = "space-thruster"
				},
				count = thruster,
				index = 4
			},
			{
				signal = {
					type = "item",
					name = "fuel-cell"
				},
				count = fuelcell,
				index = 5
			},
			{
				signal = {
					type = "item",
					name = "habitation"
				},
				count = habitation,
				index = 6
			},
			{
				signal = {
					type = "item",
					name = "life-support"
				},
				count = life,
				index = 7
			},
			{
				signal = {
					type = "item",
					name = "command"
				},
				count = command,
				index = 8
			},
			{
				signal = {
					type = "item",
					name = "astrometrics"
				},
				count = astro,
				index = 9
			},
			{
				signal = {
					type = "item",
					name = "ftl-drive"
				},
				count = ftl,
				index = 10
			},
			{
				signal = {
					type = "virtual",
					name = "signal-S"
				},
				count = 3,
				index = 11
			}
		}	
	else
		cb.parameters = {}
	end
		
			-- cb.parameters = {parameters = {
			-- {
				-- signal = {
					-- type = "virtual",
					-- name = "train-counter"
				-- },
				-- count = traincount,
				-- index = 1
			-- }
		-- }}
	end
end

function remove_spacex_com(entity)
	for i, coms in ipairs(global.spacex_com) do
		if coms.entity == entity then
			table.remove(global.spacex_com, i)
			break
		end
	end	
end

script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.name == "spacex-combinator" then
		debugp("Spacex combinator built")
		global.spacex_com = global.spacex_com or {}
		event.created_entity.operable = false
		table.insert(global.spacex_com, {entity = event.created_entity})
		get_spacex_cb(event.created_entity)
	end
	-- if event.entity.name == "spacex-combinator" then
		-- debugp("inserting spacex combinator")
		-- table.insert(global.spacex_com, {entity = event.entity})
	-- end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	if event.created_entity.name == "spacex-combinator" then
		debugp("Spacex combinator built")
		global.spacex_com = global.spacex_com or {}
		event.created_entity.operable = false
		table.insert(global.spacex_com, {entity = event.created_entity})
		get_spacex_cb(event.created_entity)
	end
	-- if event.created_entity.name == "spacex-combinator" then
		-- table.insert(global.spacex_com, {entity = event.created_entity})	
	-- end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	if event.entity.name == "spacex-combinator" then
		remove_spacex_com(event.entity)
	end
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	if event.entity.name == "spacex-combinator" then
		remove_spacex_com(event.entity)
	end
end)

script.on_event(defines.events.on_entity_died, function(event)
	if event.entity.name == "spacex-combinator" then
		remove_spacex_com(event.entity)
	end
end)

local function updateSpacexCombinators(surface)
--	for _,spacexCom in pairs(surface.find_entities_filtered{type="constant-combinator", name="spacex-combinator"}) do
	global.spacex_com = global.spacex_com or {}
	if global.spacex_com == {} then return end
	for _,spacexCom in pairs(global.spacex_com) do
		debugp("spacex combinator found")
		get_spacex_cb(spacexCom.entity)
	end
end

local function spacex_continue(surface)
	global.launches = nil
	glob_init()
	updateSpacexCombinators(surface)
	if global.spacex == nil then global.spacex = 0 end
	global.spacex = global.spacex + 1
	global.launch_log = global.launch_log or {}
	local launch_log = {log = get_launch_log(), detail = "?"}
	-- launch_log.detail = "?"
	table.insert(global.launch_log, launch_log )
end	

script.on_event(defines.events.on_gui_click, function(event) 

    local element = event.element
    local player = game.players[event.player_index]
    local gui = mod_gui.get_frame_flow(player)
    local frame = gui.space_progress_frame
  	local gui_spacex = gui.spacex_launch
	local spacex_log = gui.spacex_log

    if element.name == "space_toggle_button" then
	    if frame then
			frame.destroy()
			return
		end
		frame = gui.add{
			type = "frame",
			name = "space_progress_frame",
			direction = "vertical",
			caption = {"space-progress-frame-title"},
			style = mod_gui.frame_style
		}		
        gui_open_frame(player)
		
    end
	
	if element.name == "bio_button" then
		for _, player in pairs(game.players) do
			-- Close every launch gui
			gui_open_spacex_launch_gui(player)
		end
		spacex_continue(player.surface, gui)
--[[ 		global.launches = nil
		glob_init()
		updateSpacexCombinators(player.surface)
		if global.spacex == nil then global.spacex = 0 end
		global.spacex = global.spacex + 1
		global.launch_log = global.launch_log or {}
		local launch_log = {log = get_launch_log(), detail = "?"}
		-- launch_log.detail = "?"
		table.insert(global.launch_log, launch_log ) ]]
		if frame then
			frame.destroy()
		end
		if gui_spacex then
			gui_spacex.destroy()
		end
		frame = gui.add{
			type = "frame",
			name = "space_progress_frame",
			direction = "vertical",
			caption = {"space-progress-frame-title"},
			style = mod_gui.frame_style
		}
        gui_open_frame(player)
		return
	end
	if element.name == "iwmm_button" then
		for _, player in pairs(game.players) do
			-- Close every launch gui
			gui_open_spacex_launch_gui(player)
		end
		if gui_spacex then
			gui_spacex.destroy()
		end
		game.set_game_state{game_finished=true, player_won=true, can_continue=true}
		global.finished = true
		return
	end	

	if element.name == "launch_log" then
		if spacex_log then
			spacex_log.destroy()
			return
		end
		log = gui.add{
					type = "frame",
					name = "spacex_log",
					direction = "vertical",
					caption = {"gui-log-title"},
					style = mod_gui.frame_style
		}
		gui_log_open(player)
	end
	
	if element.name == "gnc_button" then
		open_gnc_msg(player)
		return
	end		

	if element.name == "drydock_button" then
		open_drydock_msg(player)
		return
	end	

	if element.name == "notadmin_button" then
		gui_open_spacex_launch_gui(player)
		return
	end
	
--	if player.gui.left["rocket_score"] ~= nil then
--	  player.gui.left["rocket_score"].destroy()
--	end

end)

function open_gnc_msg(player)
	local gui = mod_gui.get_frame_flow(player)
	local gui_gnc = gui.gnc_msg
		if gui_gnc then
			gui_gnc.destroy()
			return
		end	
	gui_gnc = gui.add{
			type = "frame",
			name = "gnc_msg",
			direction = "vertical",
			caption = {"gnc-title"},
			style = mod_gui.frame_style
		}
	gui_gnc.add{type = "label", caption = {"satellite-network-text1"}, style = "Launch_label_style"}
	gui_gnc.add{type = "button",
            name = "gnc_button",
			style = mod_gui.button_style,
            caption = "Great!",
			tooltip = {"gnc-tooltip"}
        }	
end

function open_drydock_msg(player)
	local gui = mod_gui.get_frame_flow(player)
	local gui_drydock = gui.drydock_msg
		if gui_drydock then
			gui_drydock.destroy()
			return
		end	
	gui_drydock = gui.add{
			type = "frame",
			name = "drydock_msg",
			direction = "vertical",
			caption = {"drydock-title"},
			style = mod_gui.frame_style
		}
	gui_drydock.add{type = "label", caption = {"drydock-text1"}, style = "Launch_label_style"}
	gui_drydock.add{type = "button",
            name = "drydock_button",
			style = mod_gui.button_style,
            caption = "Awesome!",
			tooltip = {"drydock-tooltip"}
        }	
end

script.on_event(defines.events.on_research_finished, function(event)

    if event.research.name == 'rocket-silo' then
        for _, player in pairs(game.players) do
            gui_init(player, true)
        end
    end

end)

script.on_init(function()

    glob_init()

    for _, player in pairs(game.players) do
        gui_init(player, false)
    end
	
end)

-- script.on_event(defines.events.on_built_entity, function(event)
	-- if event.created_entity.name == "spacex-combinator" then
		-- debugp("Spacex combinator built")
		-- event.created_entity.operable = false
		-- get_spacex_cb(event.created_entity)
	-- end
-- end)

script.on_event(defines.events.on_player_created, on_player_created)


script.on_event(defines.events.on_rocket_launched, function(event)
  local status,err = pcall(function()
	remote.call("silo_script","set_show_launched_without_satellite", false)
	remote.call("silo_script","set_finish_on_launch", false)
  end)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") > 0 then
    if global.launches.satellite < global.requirements.satellite then
	  global.launches.satellite = global.launches.satellite + 1	
		if global.launches.satellite == global.requirements.satellite then

			for _, player in pairs(game.players) do
				player.print({"satellite-network-complete-msg"}) 
				if settings.global['SpaceX-no-popup'].value == false then
					open_gnc_msg(player)
				end
			end
		end	
		updateSpacexCombinators(event.rocket.surface)
	end
	game.set_game_state{game_finished=false, player_won=false, can_continue=true}	

--	for index, player in pairs(force.players) do
--		if player.gui.left["rocket_score"] ~= nil then
--			player.gui.left["rocket_score"].destroy()
--		end
--	end
	for _, player in pairs(game.players) do
		-- frame = player.gui.left["space-progress-frame"]
		local frame = mod_gui.get_frame_flow(player).space_progress_frame
		if frame then
			frame.clear()
			gui_open_frame(player)
		end
	end	

	return
  end
  
	if event.rocket.get_item_count("drydock-structural") > 0 then
		if global.launches.drydockstructure < global.requirements.drydockstructure then
			global.launches.drydockstructure = global.launches.drydockstructure + 1
		end

	end
  
	if event.rocket.get_item_count("drydock-assembly") > 0 then
		if global.launches.drydockcommand < global.requirements.drydockcommand then
			global.launches.drydockcommand = global.launches.drydockcommand + 1
		end

	end  

--	local condition = (ship == nil) and (global.launches.drydockstructure = global.requirements.drydockstructure) and (global.launches.drydockcommand = globallaunches.drydockcommand)			
						
	if ((event.rocket.get_item_count("drydock-structural") > 0 or event.rocket.get_item_count("drydock-assembly") > 0) and
		global.launches.drydockstructure == global.requirements.drydockstructure and
		global.launches.drydockcommand == global.requirements.drydockcommand) then
		for _, player in pairs(game.players) do
			player.print({"drydock-complete-msg"}) 
			if settings.global['SpaceX-no-popup'].value == false then
				open_drydock_msg(player)
			end
			updateSpacexCombinators(event.rocket.surface)
		end
	end

	if event.rocket.get_item_count("fusion-reactor") > 0 then
		if global.launches.shipfusionreactor < global.requirements.shipfusionreactor then
			global.launches.shipfusionreactor = global.launches.shipfusionreactor + 1
		end

	end  

	if event.rocket.get_item_count("fuel-cell") > 0 then
		if global.launches.shipfuelcells < global.requirements.shipfuelcells then
			global.launches.shipfuelcells = global.launches.shipfuelcells + 1
		end

	end 	

	if event.rocket.get_item_count("hull-component") > 0 then
		if global.launches.shipcasings < global.requirements.shipcasings then
			global.launches.shipcasings = global.launches.shipcasings + 1
		end

	end 

	if event.rocket.get_item_count("protection-field") > 0 then
		if global.launches.shiptprotectionfield < global.requirements.shiptprotectionfield then
			global.launches.shiptprotectionfield = global.launches.shiptprotectionfield + 1
		end

	end 

	if event.rocket.get_item_count("space-thruster") > 0 then
		if global.launches.shipthrusters < global.requirements.shipthrusters then
			global.launches.shipthrusters = global.launches.shipthrusters + 1
		end

	end 

	if event.rocket.get_item_count("habitation") > 0 then
		if global.launches.shiphabitation < global.requirements.shiphabitation then
			global.launches.shiphabitation = global.launches.shiphabitation + 1
		end

	end

	if event.rocket.get_item_count("life-support") > 0 then
		if global.launches.shiplifesupport < global.requirements.shiplifesupport then
			global.launches.shiplifesupport = global.launches.shiplifesupport + 1
		end

	end  

	if event.rocket.get_item_count("command") > 0 then
		if global.launches.shipcommand < global.requirements.shipcommand then
			global.launches.shipcommand = global.launches.shipcommand + 1
		end

	end 

	if event.rocket.get_item_count("astrometrics") > 0 then
		if global.launches.shipastrometrics < global.requirements.shipastrometrics then
			global.launches.shipastrometrics = global.launches.shipastrometrics + 1
		end

	end 

	if event.rocket.get_item_count("ftl-drive") > 0 then
		if global.launches.shipftldrive < global.requirements.shipftldrive then
			global.launches.shipftldrive = global.launches.shipftldrive + 1
		end
	end  

	-- Test for victory condition
	global.finished = global.finished or false
	
	if  global.launches.shipfusionreactor == global.requirements.shipfusionreactor and
		global.launches.shipcasings == global.requirements.shipcasings and
		global.launches.shiptprotectionfield == global.requirements.shiptprotectionfield and
		global.launches.shipthrusters == global.requirements.shipthrusters and
		global.launches.shiphabitation == global.requirements.shiphabitation and
		global.launches.shiplifesupport == global.requirements.shiplifesupport and
		global.launches.shipfuelcells == global.requirements.shipfuelcells and
		global.launches.shipcommand == global.requirements.shipcommand and
		global.launches.shipastrometrics == global.requirements.shipastrometrics and
		global.launches.shipftldrive == global.requirements.shipftldrive and
		global.finished == false then
		if settings.global['SpaceX-auto-continue'].value == false then
			for _, player in pairs(game.players) do
				player.print({"spaceship-complete-msg"})
				gui_open_spacex_launch_gui(player)
			end
		else
			spacex_continue(event.rocket.surface)
		end
		-- game.set_game_state{game_finished=true, player_won=true, can_continue=true}
		-- global.finished = true
	end
	for _, player in pairs(game.players) do
		frame = mod_gui.get_frame_flow(player).space_progress_frame
		if frame then
			gui_open_frame(player)
		end
	end	
	updateSpacexCombinators(event.rocket.surface)
--	if (#game.players <= 1) then
--		ipc.keypress(9)
--	end
end)

commands.add_command("resetSpaceX", {"resetSpaceX_help"}, function(event)
	global.finished = false
end)

commands.add_command("modlist", {"modlist_help"}, function(event)
	for name, version in pairs(game.active_mods) do
		game.player.print(name .. " version " .. version)
	end
end)

commands.add_command("spacex_settings", {"x_settings_help"}, function(event)
	game.player.print("research" .. settings.startup["SpaceX-research"].value)

end)

commands.add_command("Get_log_file", {"get log file help"}, function(event)
	game.write_file("spacex_log",serpent.block(global.launch_log),{comment=false})
end)

commands.add_command("spacex_combinators", {"get spacex_combinator help"}, function(event)
	game.write_file("spacex_combinator",serpent.block(global.spacex_com),{comment=false})
end)

--Cheat command
--[[ commands.add_command("SpaceX_complete_launch_cycle", {"SpaceX_cheat_help"}, function(event)
		global.launches.satellite = global.requirements.satellite
		global.launches.drydockstructure = global.requirements.drydockstructure 
		global.launches.drydockcommand = global.requirements.drydockcommand
	    global.launches.shipfusionreactor = global.requirements.shipfusionreactor
		global.launches.shipcasings = global.requirements.shipcasings 
		global.launches.shiptprotectionfield = global.requirements.shiptprotectionfield 
		global.launches.shipthrusters = global.requirements.shipthrusters 
		global.launches.shiphabitation = global.requirements.shiphabitation 
		global.launches.shiplifesupport = global.requirements.shiplifesupport 
		global.launches.shipfuelcells = global.requirements.shipfuelcells
		global.launches.shipcommand = global.requirements.shipcommand 
		global.launches.shipastrometrics = global.requirements.shipastrometrics 
		global.launches.shipftldrive = global.requirements.shipftldrive - 1
		updateSpacexCombinators(game.player.surface)
end)

commands.add_command("SpaceX_complete_satellite", {"SpaceX_cheat_sat_help"}, function(event)
	global.launches.satellite = global.requirements.satellite - 1
	updateSpacexCombinators(game.player.surface)
end)

commands.add_command("SpaceX_complete_drydock", {"SpaceX_cheat_dry_help"}, function(event)
	global.launches.satellite = global.requirements.satellite
	global.launches.drydockstructure = global.requirements.drydockstructure - 1
	global.launches.drydockcommand = global.requirements.drydockcommand
	updateSpacexCombinators(game.player.surface)
end) ]]