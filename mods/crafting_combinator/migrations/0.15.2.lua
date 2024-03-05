if not late_migrations then return end

late_migrations['0.15.2'] = function()
	local signals = require 'script.signals'
	
	for _, cache in pairs(global.signals.cache) do signals.cache.drop(cache.__entity); end
	global.signals = nil
	signals.init_global()
end
