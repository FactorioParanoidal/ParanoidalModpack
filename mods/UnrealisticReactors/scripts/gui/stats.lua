--copyright ownlyme, written for realistic reactors (free to use/distribute/edit/build upon as a module of this mod or other mods by ingoknieto)
--with minor_ bugfixes from dodo

local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local Setting = require(rroot .. "setting")
local tablemax = require(rroot .. "util").tablemax
local noop = require(rroot .. "util").noop
local util = require(rpath .. "util")
local string2sprite = util.string2sprite
local string2color  = util.string2color
local splitty = util.splitty


-- local gui constants
local COLUMN_COUNT = 70
local PIXEL_WIDTH = 2
local FONT_SIZE = 12
local GRAPH_HEIGHT = 101

local function create_graph(gui)

	gui.add{type = "sprite", name = "graph", sprite="rr-black-background", direction = "vertical"}
	gui.graph.style.width=math.floor(80*PIXEL_WIDTH)+32
	gui.graph.style.height=GRAPH_HEIGHT
	gui.graph.style.stretch_image_to_widget_size =true
	--gui.graph.style.scaleable = false
	gui.graph.add{type = "table", column_count=COLUMN_COUNT+1, name = "table", direction = "vertical"}
	gui.graph.table.style.horizontal_spacing=0
	gui.graph.table.style.vertical_spacing=0
	--gui.graph.table.style.scaleable = false
	
	for x=1,COLUMN_COUNT+1 do
		gui.graph.table.add{type = "table", column_count=1, name = "col_"..x, direction = "vertical"}
		gui.graph.table["col_"..x].style.horizontal_spacing=0
		gui.graph.table["col_"..x].style.vertical_spacing=0
		gui.graph.table["col_"..x].style.minimal_height=GRAPH_HEIGHT
		gui.graph.table["col_"..x].style.maximal_height=GRAPH_HEIGHT
		--gui.graph.table["col_"..x].style.scaleable = false
		if x>COLUMN_COUNT then
		gui.graph.table["col_"..x].style.left_padding = 3
		end
		--gui.graph.table["col_"..x].add{type = "flow", name = "space_5", direction = "vertical"}
		--gui.graph.table["col_"..x]["space_5"].style.maximal_height=100
		--gui.graph.table["col_"..x]["space_5"].style.minimal_height=1
		--gui.graph.table["col_"..x]["space_5"].style.maximal_width=PIXEL_WIDTH
		--gui.graph.table["col_"..x]["space_5"].style.minimal_width=PIXEL_WIDTH
		--gui.graph.table["col_"..x]["space_5"].style.scaleable = false
		
	end
	for x=1,COLUMN_COUNT+1 do
		for y=4,1,-1 do
			gui.graph.table["col_"..x].add{type = "flow", name = "space_"..y, direction = "vertical"}
			gui.graph.table["col_"..x]["space_"..y].style.maximal_height=100
			gui.graph.table["col_"..x]["space_"..y].style.minimal_height=1
			gui.graph.table["col_"..x]["space_"..y].style.maximal_width=PIXEL_WIDTH
			gui.graph.table["col_"..x]["space_"..y].style.minimal_width=PIXEL_WIDTH
			--gui.graph.table["col_"..x]["space_"..y].style.scaleable = false
			if x <=COLUMN_COUNT then
				gui.graph.table["col_"..x].add{type = "sprite", name = "dot_"..y.."_2", direction = "vertical"}
				gui.graph.table["col_"..x]["dot_"..y.."_2"].style.maximal_height=1
				gui.graph.table["col_"..x]["dot_"..y.."_2"].style.maximal_width=PIXEL_WIDTH
				gui.graph.table["col_"..x]["dot_"..y.."_2"].style.minimal_width=PIXEL_WIDTH
				gui.graph.table["col_"..x]["dot_"..y.."_2"].sprite="rr-black"
				--gui.graph.table["col_"..x]["dot_"..y.."_2"].value=1
				--gui.graph.table["col_"..x]["dot_"..y.."_2"].style.color={r=0,g=0,b=0}
				--gui.graph.table["col_"..x]["dot_"..y.."_2"].style.scaleable = false
				
				gui.graph.table["col_"..x].add{type = "sprite", name = "dot_"..y.."_1", direction = "vertical"}
				gui.graph.table["col_"..x]["dot_"..y.."_1"].style.maximal_height=1
				gui.graph.table["col_"..x]["dot_"..y.."_1"].style.maximal_width=PIXEL_WIDTH
				gui.graph.table["col_"..x]["dot_"..y.."_1"].style.minimal_width=PIXEL_WIDTH
				gui.graph.table["col_"..x]["dot_"..y.."_1"].sprite="rr-black"
				--gui.graph.table["col_"..x]["dot_"..y.."_1"].value=1
				--gui.graph.table["col_"..x]["dot_"..y.."_1"].style.color={r=0,g=0,b=0}
				--gui.graph.table["col_"..x]["dot_"..y.."_1"].style.scaleable = false
			else
				gui.graph.table["col_"..x].add{type = "label", name = "text_"..y, direction = "vertical"}
				gui.graph.table["col_"..x]["text_"..y].caption = ""
				gui.graph.table["col_"..x]["text_"..y].style.height = FONT_SIZE
				--gui.graph.table["col_"..x]["text_"..y].style.vertical_align = "top"
				--gui.graph.table["col_"..x]["text_"..y].style.single_line =false
				--gui.graph.table["col_"..x]["text_"..y].style.want_ellipsis  =false
				gui.graph.table["col_"..x]["text_"..y].style.font = "rr-small-bold"
				gui.graph.table["col_"..x]["text_"..y].style.top_padding 		= 0
				gui.graph.table["col_"..x]["text_"..y].style.right_padding 	= 0
				gui.graph.table["col_"..x]["text_"..y].style.bottom_padding 	= 0
				gui.graph.table["col_"..x]["text_"..y].style.left_padding 	= 0	
				--gui.graph.table["col_"..x]["text_"..y].style.scaleable = false
				
			end
		end
	end
end

local function create_signals(gui,reactor_key)
	gui.add{type = "table", column_count = 6, name = "signals", direction = "horizontal"}
	gui.signals.style.top_padding 		= 0
	gui.signals.style.right_padding 	= 0
	gui.signals.style.bottom_padding 	= 0
	gui.signals.style.left_padding 	= 0
	gui.signals.style.horizontal_spacing= 0
	gui.signals.style.vertical_spacing=0
	--gui.signals.style.scaleable = false
	
		gui.signals.add{type = "sprite-button", name = "temperature", sprite="virtual-signal/signal-reactor-core-temp", direction = "vertical", style = "slot_button"}
		gui.signals.temperature.number=0
		gui.signals.temperature.style.height = 	32
		gui.signals.temperature.style.width = 	32
		gui.signals.temperature.style.top_padding 	= 0
		gui.signals.temperature.style.right_padding 	= 0
		gui.signals.temperature.style.bottom_padding 	= 0
		gui.signals.temperature.style.left_padding 	= 0
		--gui.signals.temperature.style.scaleable = false
		gui.signals.temperature.ignored_by_interaction =true
		
		gui.signals.add{type = "sprite-button", name = "power", sprite="virtual-signal/signal-reactor-power-output", direction = "vertical", style = "slot_button"}
		gui.signals.power.number=0
		gui.signals.power.style.height = 	32
		gui.signals.power.style.width = 	32
		gui.signals.power.style.top_padding 	= 0
		gui.signals.power.style.right_padding 	= 0
		gui.signals.power.style.bottom_padding 	= 0
		gui.signals.power.style.left_padding 	= 0
		--gui.signals.power.style.scaleable = false
		gui.signals.power.ignored_by_interaction =true
		
		gui.signals.add{type = "sprite-button", name = "efficiency", sprite="virtual-signal/signal-reactor-efficiency", direction = "vertical", style = "slot_button"}
		gui.signals.efficiency.number=0
		gui.signals.efficiency.style.height = 	32
		gui.signals.efficiency.style.width = 	32
		gui.signals.efficiency.style.top_padding 	= 0
		gui.signals.efficiency.style.right_padding 	= 0
		gui.signals.efficiency.style.bottom_padding = 0
		gui.signals.efficiency.style.left_padding 	= 0
		--gui.signals.efficiency.style.scaleable = false
		gui.signals.efficiency.ignored_by_interaction =true
		
		if global.reactors[reactor_key].entity.name == BREEDER_ENTITY_NAME then
			gui.signals.add{type = "sprite-button", name = "bonuscells", sprite="virtual-signal/signal-reactor-cell-bonus", direction = "vertical", style = "slot_button"}
			gui.signals.bonuscells.number=0
			gui.signals.bonuscells.style.height = 	32
			gui.signals.bonuscells.style.width = 	32
			gui.signals.bonuscells.style.top_padding 	= 0
			gui.signals.bonuscells.style.right_padding 	= 0
			gui.signals.bonuscells.style.bottom_padding 	= 0
			gui.signals.bonuscells.style.left_padding 	= 0
			--gui.signals.bonuscells.style.scaleable = false
			gui.signals.bonuscells.show_percent_for_small_numbers =true
			gui.signals.bonuscells.ignored_by_interaction =true
		end
		
		gui.signals.add{type = "sprite-button", name = "coolant", sprite="virtual-signal/signal-coolant-amount", direction = "vertical", style = "slot_button"}
		gui.signals.coolant.number=0
		gui.signals.coolant.style.height = 	32
		gui.signals.coolant.style.width = 	32
		gui.signals.coolant.style.top_padding 	= 0
		gui.signals.coolant.style.right_padding 	= 0
		gui.signals.coolant.style.bottom_padding 	= 0
		gui.signals.coolant.style.left_padding 	= 0
		--gui.signals.coolant.style.scaleable = false
		gui.signals.coolant.ignored_by_interaction = true

-- 		gui.signals.add{type = "sprite-button", name = "ups", sprite="virtual-signal/signal-reactor-electric-power", direction = "vertical", style = "slot_button"}
-- 		gui.signals.ups.number = 0
-- 		gui.signals.ups.style.height = 32
-- 		gui.signals.ups.style.width = 32
-- 		gui.signals.ups.style.top_padding = 0
-- 		gui.signals.ups.style.right_padding = 0
-- 		gui.signals.ups.style.bottom_padding = 0
-- 		gui.signals.ups.style.left_padding = 0
-- 		--gui.signals.ups.style.scaleable = false
-- 		gui.signals.ups.ignored_by_interaction = true
		
		gui.signals.add{
			type = "sprite-button",
			name = "status",
			sprite = "virtual-signal/signal-state-stopped",
			style = "slot_button",
			number = 0,
			ignored_by_interaction = true, -- FIXME add status button anywhere else or use text
		}
		gui.signals.status.style.height = 32
		gui.signals.status.style.width = 32
		gui.signals.status.style.top_padding = 0
		gui.signals.status.style.right_padding = 0
		gui.signals.status.style.bottom_padding = 0
		gui.signals.status.style.left_padding = 0
		--gui.signals.status.style.scaleable = false

end

local function create_progress(gui,reactor_key)
	local cols = 3
	if #global.reactors[reactor_key].entity.get_burnt_result_inventory() > 1 then
		cols = 4
	end
	gui.add{type = "table", column_count = cols, name = "progress", direction = "horizontal"}
	gui.progress.style.top_padding 		= 0
	gui.progress.style.right_padding 	= 0
	gui.progress.style.bottom_padding 	= 0
	gui.progress.style.left_padding 	= 0
	gui.progress.style.horizontal_spacing= 1
	gui.progress.style.vertical_spacing=1
	--gui.progress.style.scaleable = false

	
		gui.progress.add{type = "sprite-button", name = "cells", sprite="rr-mini-sprite", direction = "vertical", style = "rr_button"}
		gui.progress.cells.style.maximal_height = 	25
		gui.progress.cells.style.maximal_width = 	25
		gui.progress.cells.style.top_padding 	= 0
		gui.progress.cells.style.right_padding 	= 0
		gui.progress.cells.style.bottom_padding 	= 0
		gui.progress.cells.style.left_padding 	= 0
		--gui.progress.cells.style.scaleable = false
		gui.progress.cells.ignored_by_interaction =true
	
		
		gui.progress.add{type = "table", column_count = 1, name = "bars", direction = "vertical"}
		gui.progress.bars.style.maximal_height = 28
		gui.progress.bars.style.maximal_width = 140
		gui.progress.bars.style.horizontal_spacing=0
		gui.progress.bars.style.vertical_spacing=0
		gui.progress.bars.style.top_padding 	= 4
		gui.progress.bars.style.right_padding 	= 0
		gui.progress.bars.style.bottom_padding 	= 0
		gui.progress.bars.style.left_padding 	= 0
		--gui.progress.bars.style.scaleable = false
	
		
			gui.progress.bars.add{type = "progressbar", name = "progress", direction = "vertical"}
			gui.progress.bars.progress.style.height=12
			gui.progress.bars.progress.style.width=140
			gui.progress.bars.progress.style.top_padding 	= 0
			gui.progress.bars.progress.style.right_padding 	= 0
			gui.progress.bars.progress.style.bottom_padding	= 0
			gui.progress.bars.progress.style.left_padding 	= 0
			gui.progress.bars.progress.value=0
			gui.progress.bars.progress.style.color={r=1,g=0,b=0}
			--gui.progress.bars.progress.style.scaleable = false
		
			if global.reactors[reactor_key].entity.name == BREEDER_ENTITY_NAME then
				gui.progress.bars.add{type = "progressbar", name = "bonus_cells", direction = "vertical"}
				gui.progress.bars.bonus_cells.style.height=12
				gui.progress.bars.bonus_cells.style.width=140
				gui.progress.bars.bonus_cells.style.top_padding 	= 0
				gui.progress.bars.bonus_cells.style.right_padding 	= 0
				gui.progress.bars.bonus_cells.style.bottom_padding 	= 0
				gui.progress.bars.bonus_cells.style.left_padding 	= 0
				gui.progress.bars.bonus_cells.value=0
				gui.progress.bars.bonus_cells.style.color={r=0.8,g=0,b=0.8}
				--gui.progress.bars.bonus_cells.style.scaleable = false
			else
				gui.progress.bars.style.top_padding = 2
			end
	
		
		gui.progress.add{type = "sprite-button", name = "used_cells", sprite="rr-transparent-sprite", direction = "vertical", style = "rr_button"}
		gui.progress.used_cells.style.height = 25
		gui.progress.used_cells.style.width = 25
		gui.progress.used_cells.style.top_padding = 0
		gui.progress.used_cells.style.right_padding = 0
		gui.progress.used_cells.style.bottom_padding = 0
		gui.progress.used_cells.style.left_padding = 0
		--gui.progress.used_cells.style.scaleable = false
		gui.progress.used_cells.ignored_by_interaction =true
		if #global.reactors[reactor_key].entity.get_burnt_result_inventory() > 1 then
			gui.progress.add{type = "sprite-button", name = "used_cells2", sprite="rr-transparent-sprite", direction = "vertical", style = "rr_button"}
			gui.progress.used_cells2.style.height = 25
			gui.progress.used_cells2.style.width = 25
			gui.progress.used_cells2.style.top_padding = 0
			gui.progress.used_cells2.style.right_padding = 0
			gui.progress.used_cells2.style.bottom_padding = 0
			gui.progress.used_cells2.style.left_padding = 0
			--gui.progress.used_cells.style.scaleable = false
			gui.progress.used_cells2.ignored_by_interaction = true
			gui.progress.bars.progress.style.width=115
			gui.progress.bars.bonus_cells.style.width = 115
			
		end
		
end

local function create_gui(player, reactor_key)
	local reactor = global.reactors[reactor_key]
	local gui = player.gui.left.add{type = "frame", name = "rr_gui_"..reactor_key, caption = "", direction = "vertical"}
	gui.style.top_padding    = 1
	gui.style.right_padding  = 4
	gui.style.bottom_padding = 4
	gui.style.left_padding   = 4
	--gui.style.scaleable    = false

	if not global.stats[reactor_key] then
		global.stats[reactor_key] = {}
		global.stats[reactor_key].temperature = {}
		global.stats[reactor_key].efficiency = {}
		global.stats[reactor_key].production = {}
		global.stats[reactor_key].aqua = {}
		global.stats[reactor_key].max = 1
	end
	gui.add{type = "table", column_count = 4, name = "rr_buttons_flow", direction = "horizontal"}
	gui.rr_buttons_flow.style.top_padding        = 0
	gui.rr_buttons_flow.style.right_padding      = 0
	gui.rr_buttons_flow.style.bottom_padding     = 0
	gui.rr_buttons_flow.style.left_padding       = 13
	gui.rr_buttons_flow.style.horizontal_spacing = 20
	--gui.rr_buttons_flow.style.scaleable = false

		gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_signals", sprite = "rr-button-signals", style = "rr_button"}
		gui.rr_buttons_flow.rr_button_signals.style.top_padding 	= 0
		gui.rr_buttons_flow.rr_button_signals.style.right_padding 	= 0
		gui.rr_buttons_flow.rr_button_signals.style.bottom_padding 	= 0
		gui.rr_buttons_flow.rr_button_signals.style.left_padding 	= 0
		gui.rr_buttons_flow.rr_button_signals.style.height 	= 14
		gui.rr_buttons_flow.rr_button_signals.style.width 	= 40
		--gui.rr_buttons_flow.rr_button_signals.style.scaleable = false

		gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_progress", sprite = "rr-button-progress", style = "rr_button"}
		gui.rr_buttons_flow.rr_button_progress.style.top_padding 		= 0
		gui.rr_buttons_flow.rr_button_progress.style.right_padding 		= 0
		gui.rr_buttons_flow.rr_button_progress.style.bottom_padding 	= 0
		gui.rr_buttons_flow.rr_button_progress.style.left_padding 		= 0
		gui.rr_buttons_flow.rr_button_progress.style.height 	= 14
		gui.rr_buttons_flow.rr_button_progress.style.width 		= 30
		--gui.rr_buttons_flow.rr_button_progress.style.scaleable = false

		gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_graph", sprite = "rr-button-graph-off", style = "rr_button"}
		gui.rr_buttons_flow.rr_button_graph.style.top_padding 		= 0
		gui.rr_buttons_flow.rr_button_graph.style.right_padding 	= 0
		gui.rr_buttons_flow.rr_button_graph.style.bottom_padding 	= 0
		gui.rr_buttons_flow.rr_button_graph.style.left_padding 		= 0
		gui.rr_buttons_flow.rr_button_graph.style.height 		= 14
		gui.rr_buttons_flow.rr_button_graph.style.width 		= 30
		--gui.rr_buttons_flow.rr_button_graph.style.scaleable = false


		--gui.rr_buttons_flow.add{type = "flow", name = "titlebar_spacer", direction = "horizontal"}
		--gui.rr_buttons_flow.titlebar_spacer.style.width=2
		--gui.rr_buttons_flow.titlebar_spacer.style.height=1
		--gui.rr_buttons_flow.titlebar_spacer.style.scaleable = false


		gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_exit", sprite = "rr-button-x", style = "rr_button"}
		gui.rr_buttons_flow.rr_button_exit.style.top_padding 		= 0
		gui.rr_buttons_flow.rr_button_exit.style.right_padding 		= 0
		gui.rr_buttons_flow.rr_button_exit.style.bottom_padding 	= 0
		gui.rr_buttons_flow.rr_button_exit.style.left_padding 		= 0
		gui.rr_buttons_flow.rr_button_exit.style.height 	= 18
		gui.rr_buttons_flow.rr_button_exit.style.width 		= 18
		--gui.rr_buttons_flow.rr_button_exit.style.scaleable = false

	create_signals(gui,reactor_key)
	create_progress(gui,reactor_key)

	global.gui_count = global.gui_count + 1
	global.guis[reactor_key.."-"..player.index] = gui

end


local function clear_invalid_gui()
	clear_invalid_gui = noop
	for key, gui in pairs(global.guis) do
		if not gui.valid then -- might be opened in map editor
			log("removed invalid gui " .. key)
			local reactor_key, playerid = splitty(key,"-")
			global.stats[reactor_key] = nil
			global.guis[key] = nil
			global.gui_count = global.gui_count - 1
		end
	end
end

local function on_tick(tick)
	clear_invalid_gui()

	if tick % (TICKS_PER_UPDATE*2) == 0 then
		--if not global.stats[reactor_key] then global.stats[reactor_key] = {efficiency = {},production = {},temperature = {}, aqua = {}} end
		for reactor_key, stats in pairs (global.stats) do
			if not global.reactors[reactor_key] then
				global.stats[reactor_key] = nil
			else
				signals = global.reactors[reactor_key].signals.parameters
				if global.reactors[reactor_key].power_usage.interface > 1 then
					stats.temperature[COLUMN_COUNT] = math.min(100,math.max(1,math.floor((signals["core_temperature"].count or 1)/10)))
					stats.efficiency[COLUMN_COUNT] = math.min(100,math.max(1,math.floor((signals["efficiency"].count or 1)/global.reactors[reactor_key].max_efficiency*100)))

					stats.production[COLUMN_COUNT] = signals["power-output"].count or 1 --math.min(100,math.max(1,
					stats.aqua[COLUMN_COUNT] = global.reactors[reactor_key].cooling_history
				else
					stats.efficiency[COLUMN_COUNT]  = -1
					stats.production[COLUMN_COUNT]  = -1
					stats.temperature[COLUMN_COUNT] = -1
					stats.aqua[COLUMN_COUNT] = -1

				end
				--local cooling = 0
				--for i=1,math.floor(1/(TICKS_PER_UPDATE/30)) do
				--	cooling = cooling + global.reactors[reactor_key].cooling_history[i]
				--end
				--stats.aqua[COLUMN_COUNT] = math.floor(cooling / math.floor(1/(TICKS_PER_UPDATE/30))/2)

				--game.players[1].print(stats.aqua[COLUMN_COUNT])
				for k=1,COLUMN_COUNT-1 do
					stats.efficiency[k] = stats.efficiency[k+1]
					stats.production[k] = stats.production[k+1]
					stats.temperature[k] = stats.temperature[k+1]
					stats.aqua[k]=stats.aqua[k+1]
				end
				local maxpower = {tablemax(stats.production), tablemax(stats.aqua),global.reactors[reactor_key].max_power}
				stats.max = tablemax(maxpower)

			end
		end
	end

	if tick % TICKS_PER_UPDATE == 0 then
		for key, gui in pairs(global.guis) do
			local reactor_key, playerid = splitty(key,"-")

			local reactor = global.reactors[reactor_key]

			if not (reactor and reactor.entity.valid and global.stats[reactor_key]) then
				global.stats[reactor_key] = nil
				gui.destroy()
				global.guis[key] = nil
				global.gui_count = global.gui_count - 1
			else
				local signals = reactor.signals.parameters
				if gui.signals then
					gui.signals.temperature.number = math.floor(signals["core_temperature"].count)
-- 					gui.signals.ups.number = math.floor(signals["electric-power"].count)
					gui.signals.power.number = math.floor(signals["power-output"].count)
					gui.signals.efficiency.number = math.floor(signals["efficiency"].count)
					if reactor.entity.name == BREEDER_ENTITY_NAME then
						gui.signals.bonuscells.number = math.floor(signals["cell-bonus"].count)/100
					end
					gui.signals.coolant.number=signals["coolant-amount"].count
					if signals["state_stopped"].count > 0 then
						gui.signals.status.number=signals["state_stopped"].count
						gui.signals.status.sprite="virtual-signal/signal-state-stopped"
					elseif signals["state_starting"].count > 0 then
						gui.signals.status.number=signals["state_starting"].count
						gui.signals.status.sprite="virtual-signal/signal-state-starting"
					elseif signals["state_running"].count > 0 then
						gui.signals.status.number=signals["state_running"].count
						gui.signals.status.sprite="virtual-signal/signal-state-running"
					elseif signals["state_scramed"].count > 0 then
						gui.signals.status.number=signals["state_scramed"].count
						gui.signals.status.sprite="virtual-signal/signal-state-scramed"
					end
				end
				if gui.progress then
					if reactor.entity.get_fuel_inventory().is_empty() then
						gui.progress.cells.number = nil
						gui.progress.cells.sprite = "rr-transparent-sprite"
					else
						gui.progress.cells.number = reactor.entity.get_fuel_inventory()[1].count
						gui.progress.cells.sprite = "item/"..reactor.entity.get_fuel_inventory()[1].name
					end

					if reactor.entity.get_burnt_result_inventory().is_empty() then
						gui.progress.used_cells.number = nil
						gui.progress.used_cells.sprite = "rr-transparent-sprite"
						if gui.progress.used_cells2 then
							gui.progress.used_cells2.number = nil
							gui.progress.used_cells2.sprite = "rr-transparent-sprite"
						end
					else
						local inv1 = reactor.entity.get_burnt_result_inventory()[1]
						gui.progress.used_cells.number =  inv1.valid_for_read and inv1.count or nil
						gui.progress.used_cells.sprite = inv1.valid_for_read and "item/"..inv1.name or "rr-transparent-sprite"
						if gui.progress.used_cells2 then
							local inv2 = reactor.entity.get_burnt_result_inventory()[2]
							gui.progress.used_cells2.number = inv2.valid_for_read and inv2.count or nil
							gui.progress.used_cells2.sprite = inv2.valid_for_read and "item/"..inv2.name or "rr-transparent-sprite"
						end
					end

					if reactor.entity.burner.currently_burning == nil then
						gui.progress.bars.progress.value=0
						if reactor.entity.name == BREEDER_ENTITY_NAME then
							gui.progress.bars.bonus_cells.value=0
						end
					else
						local burnt_result = reactor.entity.burner.currently_burning.burnt_result.name
						if burnt_result == "apm_fuel_cell_mox_used" then
							burnt_result = "apm_nuclear_breeder_uranium_inventory_enriched"
						end
						--gui.progress.cells.sprite = "item/"..reactor.entity.burner.currently_burning.name
						--gui.progress.used_cells.sprite = "item/"..burnt_result.name
						gui.progress.bars.progress.value = reactor.entity.burner.remaining_burning_fuel / reactor.entity.burner.currently_burning.fuel_value

						if reactor.entity.name == BREEDER_ENTITY_NAME then
							gui.progress.bars.bonus_cells.value = math.min(1,reactor.bonus_cells[burnt_result] or 0)
						end
					end
				end
			end
		end
	end

	--process graphs
	if tick % (TICKS_PER_UPDATE*2) == 0 then
		for key, gui in pairs(global.guis) do
			if gui.graph then
				local reactor_key,playerid = splitty(key,"-")
				if not (global.reactors[reactor_key] and global.stats[reactor_key]) then
					global.stats[reactor_key] = nil
					gui.destroy()
					global.guis[key] = nil
					global.gui_count = global.gui_count - 1
				else
					if gui.graph.valid then
						local stats = global.stats[reactor_key]
						for k, temperature in pairs(stats.temperature) do
							local colors={}
							local production = math.min(100,math.max(1,math.floor(  stats.production[k] / stats.max * 100  )))
							local aqua = math.min(100,math.max(1,math.floor(  stats.aqua[k] / stats.max * 100  )))

							colors[production] = ""
							colors[stats.efficiency[k]] = ""
							colors[aqua] = ""
							colors[production+1] = ""
							colors[stats.efficiency[k]+1] = ""
							colors[aqua+1] = ""

							colors[stats.temperature[k]] = "r"
							colors[stats.temperature[k]+1] = "r"
							colors[production] = colors[production] .."y"
							colors[production+1] = colors[production+1] .."y"
							colors[stats.efficiency[k]] = colors[stats.efficiency[k]] .."b"
							colors[stats.efficiency[k]+1] = colors[stats.efficiency[k]+1] .."b"
							colors[aqua] = colors[aqua].."a"
							colors[aqua+1] = colors[aqua+1].."a"

							local height = 0
							local counter = 1
							local value,color = next(colors)

							while value do
								if value >0 then
									if counter > 1 then
										gui.graph.table["col_".. k]["space_"..counter-1].style.minimal_height=math.max(0,value-height)
									end

									height=value+2
									gui.graph.table["col_".. k]["dot_"..counter.."_1"].sprite=string2sprite(color)
									if colors[value+1] then
										gui.graph.table["col_".. k]["dot_"..counter.."_2"].sprite=string2sprite(colors[value+1])
										value,color = next(colors,value)
									else
										gui.graph.table["col_".. k]["dot_"..counter.."_2"].sprite="rr-black"
									end
									counter=counter+1
								end
								value,color = next(colors,value)
							end
							for i=counter,4 do
								if i~=1 then
									gui.graph.table["col_".. k]["space_"..i-1].style.minimal_height=0
								end
								gui.graph.table["col_".. k]["dot_"..i.."_1"].sprite = "rr-black"
								gui.graph.table["col_".. k]["dot_"..i.."_2"].sprite = "rr-black"
								height=height+2

							end
							gui.graph.table["col_".. k]["space_".. 4].style.minimal_height=math.max(0,103-height)
						end
						local temp_stats = {}
						local signals = global.reactors[reactor_key].signals.parameters

						local production = math.min(100,math.max(1,math.floor(  stats.production[COLUMN_COUNT] / stats.max * 100  )))
						local aqua = math.min(100,math.max(1,math.floor(  stats.aqua[COLUMN_COUNT] / stats.max * 100  )))

						freespot = 0
						while temp_stats[math.min(100,production+math.floor(FONT_SIZE/2))+freespot] do
							freespot = freespot + 1
						end
						temp_stats[math.min(100,production+math.floor(FONT_SIZE/2))+freespot] = "y"
						--game.players[1].print(game.tick.." y = "..stats.production[COLUMN_COUNT])

						freespot = 0
						while temp_stats[math.min(100,stats.efficiency[COLUMN_COUNT]+math.floor(FONT_SIZE/2))+freespot] do
							freespot = freespot + 1
						end
						temp_stats[math.min(100,stats.efficiency[COLUMN_COUNT]+math.floor(FONT_SIZE/2))+freespot] = "b"
						--game.players[1].print(game.tick.." b = "..stats.efficiency[COLUMN_COUNT])

						freespot = 0
						while temp_stats[math.min(100,aqua+math.floor(FONT_SIZE/2))+freespot] do
							freespot = freespot + 1
						end
						temp_stats[math.min(100,aqua+math.floor(FONT_SIZE/2))+freespot] = "a"
						--game.players[1].print(game.tick.." a = "..stats.aqua[COLUMN_COUNT])

						freespot = 0
						while temp_stats[math.min(100,stats.temperature[COLUMN_COUNT]+math.floor(FONT_SIZE/2))+freespot] do
							freespot = freespot + 1
						end
						temp_stats[math.min(100,stats.temperature[COLUMN_COUNT]+math.floor(FONT_SIZE/2))+freespot] = "r"
						--game.players[1].print(game.tick.." r = "..stats.temperature[COLUMN_COUNT])

						--local checked_stats = {}
						local groups = {}
						local i = 1

						local currentvalue = next(temp_stats, nil)
						while currentvalue do
							groups[i] = {min_value = currentvalue, max_value = currentvalue, avg_value = currentvalue, count = 1, values = {}}
							groups[i].values[currentvalue] = temp_stats[currentvalue]
							local nextvalue = next(temp_stats,currentvalue)
							local values = 1
							--game.players[1].print(game.tick.." group "..i.." "..currentvalue.." = "..temp_stats[currentvalue])    --
							--if nextvalue then                                                  --
							--	game.players[1].print(game.tick..i.." next: "..nextvalue)      --
							--end                                                                --
							--game.players[1].print(i.." "..nextvalue - groups[i].min_value)
							--if nextvalue and nextvalue - groups[i].min_value < 10 * groups[i].count then
							--	game.players[1].print(game.tick.."GROUP: ")
							--end
							while nextvalue and nextvalue - groups[i].min_value < FONT_SIZE * groups[i].count do
								groups[i].count = groups[i].count + 1
								groups[i].values[nextvalue] = temp_stats[nextvalue]
								--game.players[1].print (game.tick.." "..groups[i].count..": "..nextvalue .." = "..temp_stats[nextvalue])
								local values_sum = 0
								for value, stat in pairs(groups[i].values) do
									values_sum = values_sum + value
								end

								groups[i].avg_value = values_sum / groups[i].count
								groups[i].min_value = values_sum / groups[i].count - math.floor(FONT_SIZE/2) * (groups[i].count-1)
								groups[i].max_value = values_sum / groups[i].count + math.floor(FONT_SIZE/2) * (groups[i].count-1)
								if groups[i].min_value < 1 then
									groups[i].max_value = groups[i].max_value + (1 - groups[i].min_value)
									groups[i].min_value = 1
								end
								if groups[i].max_value > 100 then
									groups[i].min_value = groups[i].min_value - (groups[i].max_value - 100)
									groups[i].max_value = 100
								end
								nextvalue = next(temp_stats,nextvalue)
							end

							if nextvalue then
								currentvalue = nextvalue
								i=i+1
							else
								currentvalue = nil
							end
						end

						local last_maximal = 0
						for key, group in pairs(groups) do
							if group.min_value < last_maximal+FONT_SIZE then
								group.min_value = group.min_value + last_maximal - group.min_value+FONT_SIZE
								group.max_value = group.max_value + last_maximal - group.min_value+FONT_SIZE
							end
							last_maximal = group.max_value
						end

						local last_minimal = 100+FONT_SIZE
						for key=i, 1, -1 do
							local group = groups[key]
							if group.max_value > last_minimal-FONT_SIZE then
								group.min_value = group.min_value - (group.max_value - (last_minimal-FONT_SIZE))
								group.max_value = group.max_value - (group.max_value - (last_minimal-FONT_SIZE))
							end
							last_minimal = group.min_value
						end

						local temp_stats2 = {}
						for key, group in pairs(groups) do
							i = 0
							for _, stat in pairs(group.values) do
								--if temp_stats2[math.floor(group.min_value + i*12)] then
								--	game.players[1].print(i.."occupied")
								--end
								table.insert(temp_stats2,{value = math.floor(group.min_value + i*FONT_SIZE), stat = stat})
								--game.players[1].print(game.tick.." ("..i..") "..math.floor(group.min_value + i*FONT_SIZE).." = "..stat)
								i = i+1
							end
						end
						local height = 100
						--for value,stat in pairs(temp_stats2) do
						for counter = 4, 1, -1 do
							local value = temp_stats2[counter].value
							local stat = temp_stats2[counter].stat

							gui.graph.table["col_".. COLUMN_COUNT+1]["space_"..counter].style.height=math.max(0,height-value-1)

							--game.players[1].print(game.tick.." spacer "..counter.." = "..gui.graph.table["col_".. COLUMN_COUNT+1]["space_"..counter].style.minimal_height.."px, value = "..value)
							height=height-math.max(0,height-value-1)-FONT_SIZE
							--game.players[1].print(game.tick .." height:"..height-16 .." value:"..value.." color:"..stat)
							if global.reactors[reactor_key].power_usage.interface >1 then
								if stat=="r" then
									gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = "  "..math.floor(signals["core_temperature"].count).."°"
								elseif stat=="y" then
									gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = "  "..signals["power-output"].count.."MW"
								elseif stat=="b" then
									gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = "  "..signals["efficiency"].count.."%"
								else
									gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = math.floor(global.reactors[reactor_key].cooling_history)*-1 .."MW"
								end
								gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].style.font_color = string2color(stat)
							else
								gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = ""
								gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].style.font_color = {r=0,g=0,b=0}
							end
						end
						--gui.graph.table["col_".. COLUMN_COUNT+1]["space_".. 5].style.height= 0 --height
						--game.players[1].print(game.tick.." spacer 5 = "..gui.graph.table["col_".. COLUMN_COUNT+1]["space_5"].style.minimal_height.."px")
						--game.players[1].print(100-height)
					end
				end
			end
		end
	end
end

local function on_gui_opened(player_index)
	local player = game.players[player_index]
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	local entity = player.opened
	if entity and I2E_NAME[entity.name] then
		local reactor_key
		for key, reactor in pairs(global.reactors) do
			if reactor.interface == entity then
				reactor_key = key
				break
			end
		end
		if reactor_key then
			local frame = player.gui.left["rr_gui_"..reactor_key]
			if frame then
				frame.destroy()
				global.guis[reactor_key.."-"..player_index] = nil
				global.gui_count = global.gui_count - 1
			else
				create_gui(player,reactor_key)
			end
		end
		player.opened = nil
	end
end

local function on_gui_clicked(player_index, element, tick)
	if not element.parent or (element.parent.name ~="rr_buttons_flow" and element.parent.name ~="signals") then return end
	local reactor_key = tonumber(string.sub(element.parent.parent.name,8)) -- cut off "rr_gui_"
	if (not global.reactors[reactor_key]) or element.name == "rr_button_exit" then
		global.guis[reactor_key.."-"..player_index] = nil
		global.gui_count = global.gui_count -1
		element.parent.parent.destroy()

	elseif element.name == "rr_button_signals" then
		if element.parent.parent.signals then
			element.parent.parent.signals.destroy()
			element.parent.rr_button_signals.sprite = "rr-button-signals-off"
		else
			create_signals(element.parent.parent,reactor_key)
			element.parent.rr_button_signals.sprite = "rr-button-signals"
		end

	elseif element.name == "rr_button_progress" then
		if element.parent.parent.progress then
			element.parent.parent.progress.destroy()
			element.parent.rr_button_progress.sprite = "rr-button-progress-off"
		else
			create_progress(element.parent.parent,reactor_key)
			element.parent.rr_button_progress.sprite = "rr-button-progress"
		end

	elseif element.name == "rr_button_graph" then
		if element.parent.parent.graph then
			element.parent.parent.graph.destroy()
			element.parent.rr_button_graph.sprite = "rr-button-graph-off"
		else
			create_graph(element.parent.parent)
			element.parent.rr_button_graph.sprite = "rr-button-graph"
		end
	elseif element.name == "status" then
		local reactor = global.reactors[reactor_key]

		local signal_scram = false
		for _,wire in ipairs{defines.wire_type.green,defines.wire_type.red} do
			local network = reactor.control.get_circuit_network(wire)
			if network then
				--logging("-> Found circuit network. Network ID: " .. network.network_id)
				if network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
					signal_scram = true
					--logging("--> found SCRAM signal")
				end
			end
		end
		game.players[player_index].print("[RealisticReactors] Reactor greets you!")

		if reactor.entity.get_fuel_inventory().is_empty() and reactor.entity.burner.remaining_burning_fuel == 0 then
			game.players[player_index].print("[RealisticReactors] Reactor can't start, because it has no fuel cell.")
		elseif reactor.power.energy < (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60 * Setting.map("energy-consumption-multiplier")) then
			game.players[player_index].print("[RealisticReactors] Reactor can't start, because it has not enough electricity.")
		elseif signal_scram then
			game.players[player_index].print("[RealisticReactors] Reactor can't start, because there's a scram control signal on its circuit interface.")
		else
			if reactor.state == 3 then
-- 			if reactor.state == 0 then
-- 				change_reactor_state(1, reactor, tick)
-- 				update_reactor_states(reactor, tick)
-- 			elseif reactor.state == 1 or reactor.state == 2 then
-- 				change_reactor_state(3, reactor, tick)
-- 				update_reactor_states(reactor, tick)
-- 			else
				game.players[player_index].print("[RealisticReactors] Reactor is already scramed.")
			end
		end

	end
end


return { -- exports
	tick = on_tick,
	opened = on_gui_opened,
	clicked = on_gui_clicked,
}
