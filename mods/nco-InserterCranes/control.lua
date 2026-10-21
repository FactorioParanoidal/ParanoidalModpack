local reload_tech_unlock = require("script.reload-tech-unlock")
-------------------------------------------------------------------------------
-- Cranes use the Bob's position grid (size-aware mapping in bobinserters);
-- remove them from the blacklist left by older versions of this mod.
local function unblacklist_inserters()
	remote.call(
		"bobinserters",
		"unblacklist_inserters",
		{
			"nco-wide-crane",
			"nco-crane"
		}
	)
	if script.active_mods["boblogistics"] then
		remote.call(
			"bobinserters",
			"unblacklist_inserters",
			{
				"nco-red-wide-crane",
				"nco-red-crane",
				"nco-wide-turbo-crane",
				"nco-turbo-crane",
				"nco-wide-express-crane",
				"nco-express-crane"
			}
		)
	end
	if script.active_mods["Krastorio2"] then
		remote.call(
			"bobinserters",
			"unblacklist_inserters",
			{
				"nco-superior-wide-crane",
				"nco-superior-crane"
			}
		)
	end
end
-------------------------------------------------------------------------------
script.on_configuration_changed(
	function()
		reload_tech_unlock.reload_tech_unlock()
		if script.active_mods["bobinserters"] then
			if remote.interfaces["bobinserters"] and remote.interfaces["bobinserters"]["unblacklist_inserters"] then
				unblacklist_inserters()
			end
		end
	end
)
-------------------------------------------------------------------------------
script.on_event(
	defines.events.on_force_created,
	function()
		reload_tech_unlock.reload_tech_unlock()
	end
)
