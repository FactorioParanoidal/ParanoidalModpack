if not late_migrations then return end

late_migrations['0.15.0'] = function(changes)
	local cc_control = require 'script.cc'
	local rc_control = require 'script.rc'
	local signals = require 'script.signals'
	
	
	local change = changes.mod_changes['crafting_combinator']
	if not change or not change.old_version then return; end
	
	local message = {'crafting_combinator.0-15-0-compatibility-warning', change.old_version, change.new_version}
	log(message)
	game.show_message_dialog{text = message}
	
	
	log "Initializing new globals..."
	signals.init_global()
	
	
	cc_control.on_load()
	rc_control.on_load()
	
	
	log(("Updating %d crafting combinators..."):format(table_size(global.cc.data)))
	for _, combinator in pairs(global.cc.data) do
		combinator.last_recipe = false
		combinator.settings.read_recipe = true
		combinator.settings.mode = combinator.settings.mode.set and 'w' or 'r'
		combinator.settings_parser:update(combinator.entity, combinator.settings)
	end
	
	
	log(("Updating %d recipe combinators..."):format(table_size(global.rc.data)))
	for _, combinator in pairs(global.rc.data) do
		combinator.last_recipe = false
		combinator.last_name = false
		combinator.last_count = false
	end
end
