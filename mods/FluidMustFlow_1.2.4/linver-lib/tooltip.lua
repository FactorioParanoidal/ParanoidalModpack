-- Version 1

local _tooltip = {}

-- -- -- GUI

-- Show a text on surface
-- surface, on which surface
-- pos, x y where show
-- txt, text to show
-- clr, color or text 
function _tooltip.showOnSurfaceText(surface, pos, txt, clr)
	if clr == nil then clr = {} end
	if txt == nil or pos == nil then return end
	-- text formatting
	if type(txt) == table then 
		local tmp_txt = {}
		for _, string in pairs(txt) do
			table.insert(tmp_txt, string)
		end
		txt = tmp_txt
	elseif type(txt) == string then
		text = {txt}
	end
	
	surface.create_entity
	{
		type = "flying-text",
		name = "flying-text",
		position = pos,
		text = txt,
		color = clr,
		time_to_live = 550,
		speed = 0.0002
	}
end

function _tooltip.showOnSurfaceBlackText(surface, pos, txt)
	_tooltip.showOnSurfaceText(surface, pos, txt, {})
end

function _tooltip.showOnSurfaceGreyText(surface, pos, txt)
	_tooltip.showOnSurfaceText(surface, pos, txt, {125, 125, 125, 50})
end

return _tooltip