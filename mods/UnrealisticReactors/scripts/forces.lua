
local function init()
	for _,force in ipairs{"radioactivity","radioactivity-strong"} do
		if not game.forces[force] then
			game.create_force(force)
		end
	end
end


return { -- exports
	init = init,
}
