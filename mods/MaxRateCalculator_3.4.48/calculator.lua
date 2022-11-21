-- ----------------------------------------------------------------
-- MaxRateCalculator/calculator.lua
-- ----------------------------------------------------------------

-- TODO: keyboard +-*/=
-- TODO: paste from marc_


local function init_calculator(player)
	global.marcalc_context[player.index] = {}
	global.marcalc_context[player.index].current_value = 0
	global.marcalc_context[player.index].in_data_entry = false
	global.marcalc_context[player.index].in_left_of_decimal = false
	global.marcalc_context[player.index].decimal_place = 10
	global.marcalc_context[player.index].operand = 0
	global.marcalc_context[player.index].current_func = ""

end

-- ----------------------------------------------------------------

local function get_gui_root(player)
	return player.gui.screen
end

-- ----------------------------------------------------------------

local function init_context(player)
	global.marcalc_context = global.marcalc_context or {}
	
	if global.marcalc_context[player.index] == nil
	then
		init_calculator(player)
	end
end

-- ----------------------------------------------------------------

local function destroy_calculator(player)
	local root = get_gui_root(player)
	if root.marcalc
	then
		root.marcalc.destroy()
	end
	
end


-- ----------------------------------------------------------------


local function update_display(player,msg)
	local root = get_gui_root(player)
	if msg == nil or msg == ""
	then
	    -- bug repored by EugeneBeetle indicated we somehow got in here with current_value = nil
		if global.marcalc_context[player.index].current_value == nil
		then
		    debug_print("update_display.  cv is nil???")
			return
	    end
		debug_print("update_display cv is " .. global.marcalc_context[player.index].current_value)

		if global.marcalc_context[player.index].in_left_of_decimal 
		   and global.marcalc_context[player.index].decimal_place == 10
		then
			debug_print("update_display() add the dot")
			root.marcalc.marcalc_display.caption = tostring(global.marcalc_context[player.index].current_value) .. "."
		else
			root.marcalc.marcalc_display.caption = global.marcalc_context[player.index].current_value
		end
	else
		root.marcalc.marcalc_display.caption = msg
	end
end

-- ----------------------------------------------------------------

function show_calculator(player)
	local root = get_gui_root(player)
	destroy_calculator(player)
	
	init_context(player)
	

	marcalc = root.add({type = "frame", name = "marcalc", direction = "vertical", caption="Calc"})
	marcalc_display = marcalc.add({type = "textfield", name = "marcalc_display", caption = global.marcalc_context[player.index].current_value })

	marcalc_mem = marcalc.add({type = "flow", name = "marcalc_mem", direction = "horizontal"})
		marcalc_mem.add({type = "button", style="marcalc_button_style", caption = "ms", name="marcalc_button_MS"})
		marcalc_mem.add({type = "button", style="marcalc_button_style", caption = "m+", name="marcalc_button_M+"})
		marcalc_mem.add({type = "button", style="marcalc_button_style", caption = "m-", name="marcalc_button_M-"})
		marcalc_mem.add({type = "button", style="marcalc_button_style", caption = "mr", name="marcalc_button_MR"})

	marcalc_row1 = marcalc.add({type = "flow", name = "marcalc_row1", direction = "horizontal"})
		marcalc_row1.add({type = "button", style="marcalc_button_style", caption = "CE", name="marcalc_button_CE"})
		marcalc_row1.add({type = "button", style="marcalc_button_style", caption = "C", name="marcalc_button_C"})
		marcalc_row1.add({type = "button", style="marcalc_button_style", caption = "BS", name="marcalc_button_BS"})
		marcalc_row1.add({type = "button", style="marcalc_button_style", caption = "/", name="marcalc_button_DIV"})

	marcalc_row2 = marcalc.add({type = "flow", name = "marcalc_row2", direction = "horizontal"})
		marcalc_row2.add({type = "button", style="marcalc_button_style", caption = "7", name="marcalc_button_7"})
		marcalc_row2.add({type = "button", style="marcalc_button_style", caption = "8", name="marcalc_button_8"})
		marcalc_row2.add({type = "button", style="marcalc_button_style", caption = "9", name="marcalc_button_9"})
		marcalc_row2.add({type = "button", style="marcalc_button_style", caption = "*", name="marcalc_button_MUL"})
		
	marcalc_row3 = marcalc.add({type = "flow", name = "marcalc_row3", direction = "horizontal"})
		marcalc_row3.add({type = "button", style="marcalc_button_style", caption = "4", name="marcalc_button_4"})
		marcalc_row3.add({type = "button", style="marcalc_button_style", caption = "5", name="marcalc_button_5"})
		marcalc_row3.add({type = "button", style="marcalc_button_style", caption = "6", name="marcalc_button_6"})
		marcalc_row3.add({type = "button", style="marcalc_button_style", caption = "-", name="marcalc_button_SUB"})
		
	marcalc_row4 = marcalc.add({type = "flow", name = "marcalc_row4", direction = "horizontal"})
		marcalc_row4.add({type = "button", style="marcalc_button_style", caption = "1", name="marcalc_button_1"})
		marcalc_row4.add({type = "button", style="marcalc_button_style", caption = "2", name="marcalc_button_2"})
		marcalc_row4.add({type = "button", style="marcalc_button_style", caption = "3", name="marcalc_button_3"})
		marcalc_row4.add({type = "button", style="marcalc_button_style", caption = "+", name="marcalc_button_ADD"})
		
	marcalc_row5 = marcalc.add({type = "flow", name = "marcalc_row5", direction = "horizontal"})
		marcalc_row5.add({type = "button", style="marcalc_button_style", caption = "+-", name="marcalc_button_CHS"})
		marcalc_row5.add({type = "button", style="marcalc_button_style", caption = "0", name="marcalc_button_0"})
		marcalc_row5.add({type = "button", style="marcalc_button_style", caption = ".", name="marcalc_button_DEC"})
		marcalc_row5.add({type = "button", style="marcalc_button_style", caption = "=", name="marcalc_button_EQU"})		
				
	update_display(player)
	
end

-- ----------------------------------------------------------------



function hide_calculator(player)
	init_context(player)
	destroy_calculator(player)
end

-- ----------------------------------------------------------------


function toggle_calculator(player)
	init_context(player)
	local root = get_gui_root(player)
	if root and root.marcalc
	then
		hide_calculator(player)
	else
		show_calculator(player)
	end
end

-- ----------------------------------------------------------------

local function process_number_key(player, num)
	debug_print("process_number_key(" .. num .. ")")
	
	if global.marcalc_context[player.index].in_left_of_decimal
	then
		val = num / global.marcalc_context[player.index].decimal_place
		if global.marcalc_context[player.index].in_data_entry
		then
			global.marcalc_context[player.index].current_value = global.marcalc_context[player.index].current_value + val
		else
			global.marcalc_context[player.index].current_value = val
		end
		global.marcalc_context[player.index].decimal_place = global.marcalc_context[player.index].decimal_place * 10
	else
		if global.marcalc_context[player.index].in_data_entry
		then
			global.marcalc_context[player.index].current_value = global.marcalc_context[player.index].current_value * 10 + num
		else
			global.marcalc_context[player.index].current_value = tonumber(num)
		end
	end
	global.marcalc_context[player.index].in_data_entry = true
	update_display(player)
end

-- ----------------------------------------------------------------

local function process_decimal_key(player, key)
	debug_print("process_decimal_key(" .. key .. ")")
	if global.marcalc_context[player.index].in_left_of_decimal
	then
		return
	end
	
	global.marcalc_context[player.index].in_left_of_decimal = true
	global.marcalc_context[player.index].decimal_place = 10
	update_display(player)
end

-- ----------------------------------------------------------------

local function process_change_sign_key(player, key)
	global.marcalc_context[player.index].current_value = global.marcalc_context[player.index].current_value * -1
	update_display(player)
end

-- ----------------------------------------------------------------

local function process_equal_key(player, key)
	debug_print("process_equal_key(" .. key .. ")  global.marcalc_context[player.index].current_func is " ..  global.marcalc_context[player.index].current_func)
	
	global.marcalc_context[player.index].in_data_entry = false
	doing_decimal = false
		
	if global.marcalc_context[player.index].current_func == "ADD"
	then
		global.marcalc_context[player.index].current_value = global.marcalc_context[player.index].operand + global.marcalc_context[player.index].current_value
	elseif global.marcalc_context[player.index].current_func == "SUB"
	then
		global.marcalc_context[player.index].current_value = global.marcalc_context[player.index].operand - global.marcalc_context[player.index].current_value
	elseif global.marcalc_context[player.index].current_func == "MUL"
	then
		global.marcalc_context[player.index].current_value = global.marcalc_context[player.index].operand * global.marcalc_context[player.index].current_value
	elseif global.marcalc_context[player.index].current_func == "DIV"
	then
		debug_print("process_equal_key global.marcalc_context[player.index].current_value " .. global.marcalc_context[player.index].current_value)
	
		if global.marcalc_context[player.index].current_value == 0
		then
			debug_print("process_equal_key DIVIDE BY ZERO")
			update_display(player, {"marcalc_divide_by_zero"}) -- TODO: localize
			return
		end
		global.marcalc_context[player.index].current_value = global.marcalc_context[player.index].operand / global.marcalc_context[player.index].current_value
		
	end
	global.marcalc_context[player.index].current_func = ""
	global.marcalc_context[player.index].in_data_entry = false
	update_display(player)

end


-- ----------------------------------------------------------------

local function process_func_key(player, key)
	debug_print("process_func_key(" .. key .. ") player ix " .. player.index)

	if global.marcalc_context[player.index].current_func ~= ""
	then
		process_equal_key(player, key)
	end
		
	global.marcalc_context[player.index].current_func = key
	global.marcalc_context[player.index].operand = global.marcalc_context[player.index].current_value
	global.marcalc_context[player.index].in_data_entry = false
	global.marcalc_context[player.index].in_left_of_decimal = false
end


-- ----------------------------------------------------------------

local function process_mem_key(player, key)
	debug_print("process_mem_key(" .. key .. ")")
	if calculator_memory == nil
	then
	    debug_print("process_mem_key(" .. key .. ") calculator_memory was nil")
	    calculator_memory = 0
	end
	if key == "MS"
	then
		calculator_memory = global.marcalc_context[player.index].current_value
	elseif key == "M+"
	then
		calculator_memory = calculator_memory + global.marcalc_context[player.index].current_value
	elseif key == "M-"
	then
		calculator_memory = calculator_memory - global.marcalc_context[player.index].current_value
	else
		global.marcalc_context[player.index].current_value = calculator_memory
	end
	global.marcalc_context[player.index].in_data_entry = false
	update_display(player)
end

-- ----------------------------------------------------------------

local function process_edit_key(player, key)
	debug_print("process_edit_key(" .. key .. ")")
	if key == "CE"
	then
		global.marcalc_context[player.index].current_value = 0
	elseif key == "C"
	then
		init_calculator(player)
	end
	global.marcalc_context[player.index].in_data_entry = false
	update_display(player)

end

-- ----------------------------------------------------------------

local function set_current_value_to_text(player, text)
		local val = tonumber(text)
		if val ~= nil
		then
			global.marcalc_context[player.index].current_value = val
			debug_print("set_current_value_to_text got value " .. text)
			local plain_text = true
			local dot = string.find(text, '.', 1, plain_text)
			if dot ~= nil
			then
				local number_decimal_places = #text - dot
				global.marcalc_context[player.index].decimal_place = 10 ^ (number_decimal_places + 1)
				global.marcalc_context[player.index].in_left_of_decimal = true
				debug_print("#text " .. #text .. " number_global.marcalc_context[player.index].decimal_places " ..
					number_decimal_places .. " global.marcalc_context[player.index].decimal_place " .. global.marcalc_context[player.index].decimal_place .. " dot " .. dot .. " in_lod " .. boolstr(global.marcalc_context[player.index].in_left_of_decimal))
			else
				debug_print("set_current_value_to_text no dot.  set lod to false" )
				global.marcalc_context[player.index].in_left_of_decimal = false
			end
		else
			debug_print("got junk " .. text)
		end
end

-- ----------------------------------------------------------------

local function process_backspace_key(player, key)
	local root = get_gui_root(player)
	debug_print("process_backspace_key(" .. key .. ")")
	local old_text = root.marcalc.marcalc_display.caption
	local old_len = #old_text
	text = string.sub(old_text, 1, old_len -1)
	debug_print("process_backspace_key(" .. key .. ") old_text " .. old_text .. " old_len " .. old_len .. " text " .. text .. 
		" in_decimal " .. boolstr(global.marcalc_context[player.index].in_left_of_decimal) .. " global.marcalc_context[player.index].decimal_place " .. global.marcalc_context[player.index].decimal_place)
	if #text == 0
	then
		global.marcalc_context[player.index].current_value = 0
	else
		set_current_value_to_text(player, text)
	end
	update_display(player)
end
-- ----------------------------------------------------------------

local button_dispatch =
{
	["1"] = process_number_key,
	["2"] = process_number_key,
	["3"] = process_number_key,
	["4"] = process_number_key,
	["5"] = process_number_key,
	["6"] = process_number_key,
	["7"] = process_number_key,
	["8"] = process_number_key,
	["9"] = process_number_key,
	["0"] = process_number_key,
	["MS"] = process_mem_key,
	["M+"] = process_mem_key,
	["M-"] = process_mem_key,
	["MR"] = process_mem_key,
	["DIV"] = process_func_key,
	["MUL"] = process_func_key,
	["ADD"] = process_func_key,
	["SUB"] = process_func_key,
	["EQU"] = process_equal_key,
	["CHS"] = process_change_sign_key,
	["CE"] = process_edit_key,
	["C"] = process_edit_key,
	["BS"] = process_backspace_key,
	["DEC"] = process_decimal_key
}

function handle_marcalc_click(event_name, player)

	-- debug_print("handle_marcalc_click()")
	local button_prefix = "marcalc_button_"
	local prefix_len = string.len(button_prefix)
	local s = string.sub( event_name, 1, prefix_len)
	
	if s == button_prefix
	then
		button = string.sub(event_name, prefix_len + 1 )
		-- debug_print("handle_marcalc_click button " .. button)
		local dispatch_func = button_dispatch[button]
		if dispatch_func then
			dispatch_func(player, button)
		else
			debug_print("handle_marcalc_click no func")
		end
	end
end


-- ----------------------------------------------------------------

function marcalc_intercept_func_key(player, text)
	local was_not_func_key = true	
	local len = string.len(text)
	local last = string.sub(text,len,len)
	if last == "/"
	then
		process_func_key(player, "DIV")
		was_not_func_key = false
	elseif last == "="
	then
		process_func_key(player, "EQU")
		was_not_func_key = false
	end
	
	return was_not_func_key
end

function marcalc_on_gui_text_changed(event)
	local player_index = event.player_index
	local player = game.players[event.player_index]
	local root = get_gui_root(player)
	local element = event.element
	if element.name ~= "marcalc_display" or root.marcalc == nil
	then
		return
	end
	local text = root.marcalc.marcalc_display.text
	
	debug_print("marcalc_on_gui_text_changed element.name " .. element.name .. " text " .. text .. " caption " .. root.marcalc.marcalc_display.caption)
	root.marcalc.marcalc_display.caption = text
	
	
	if element.name == "marcalc_display"
	then
			set_current_value_to_text(player, text)
			global.marcalc_context[player.index].in_data_entry = true
			
			debug_print("call update_display, cv " .. global.marcalc_context[player.index].current_value .. " decimal_place " .. global.marcalc_context[player.index].decimal_place .. " in_lod " .. boolstr(global.marcalc_context[player.index].in_left_of_decimal))
			update_display(player)

	end

end

-- ----------------------------------------------------------------

local function marcalc_toggle_key(event)
	
	local player = game.players[event.player_index]
	toggle_calculator(player)
end

-- ----------------------------------------------------------------

function marcalc_clickable_value_clicked(player, val) -- a value in the main Max Rate Calculator has been clicked on.  Paste into current value
	local root = get_gui_root(player)
	if root ~=nil and root.marcalc ~= nil
	then
		local text = tostring(val)
		set_current_value_to_text(player, text)
		update_display(player)
	end
end

script.on_event( "marcalc_toggle", marcalc_toggle_key )
