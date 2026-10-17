-- Paranoidal: кнопка объединителя на верхней панели. Саму кнопку создаёт и оформляет GUI_Unifyer
-- (mod_gui, имя MergingChests.top_button_name), здесь только нажатие: как ярлык, но не нужно
-- включать его на панели быстрого доступа. Повторное нажатие с объединителем в руке убирает его.

--- @param event EventData.on_gui_click
local function on_gui_click(event)
	local element = event.element
	if not (element and element.valid and element.name == MergingChests.top_button_name) then
		return
	end

	local player = game.get_player(event.player_index)
	if not player then
		return
	end

	local cursor = player.cursor_stack
	if cursor and cursor.valid_for_read and cursor.name == MergingChests.merge_selection_tool_name then
		player.clear_cursor()
		return
	end

	if not player.clear_cursor() then
		return
	end

	cursor = player.cursor_stack
	if cursor then
		cursor.set_stack({ name = MergingChests.merge_selection_tool_name })
	end
end

script.on_event(defines.events.on_gui_click, on_gui_click)
