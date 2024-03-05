if not late_migrations then return end

late_migrations['0.11.2'] = function()
	local config = require 'config'
	local cc_control = require 'script.cc'
	
	
	cc_control.on_load()
	
	log("Removing fixed recipe assemblers from combinators...")
	local bad_assemblers = {}
	for _, combinator in pairs(global.cc.data) do
		if combinator.assembler and combinator.assembler.prototype.fixed_recipe then
			print(("\t- Found bad assembler for combinator at %s"):format(serpent.line(combinator.entity.position)))
			table.insert(bad_assemblers, combinator.assembler)
			combinator:find_assembler()
		end
	end
	
	if table_size(bad_assemblers) > 0 then
		game.print{'crafting_combinator.chat-message', {'crafting_combinator.0-11-2-assembler-warning'}}
		local print_surface = table_size(game.surfaces) > 1
		for _, assembler in pairs(bad_assemblers) do
			game.print{'crafting_combinator.0-11-2-bad-assembler-list-item',
				assembler.name, assembler.position.x, assembler.position.y,
				print_surface and {'crafting_combinator.0-11-2-bad-assembler-list-item-surface', assembler.surface.name} or ""
			}
		end
	end
end
