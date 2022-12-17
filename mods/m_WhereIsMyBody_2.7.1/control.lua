if script.active_mods["zk-lib"] then
	require("__zk-lib__/static-libs/lualibs/event_handler_vZO.lua").add_lib(require("models/WhereIsMyBody"))
else
	require("event_handler").add_lib(require("models/WhereIsMyBody"))
end

if script.active_mods["gvv"] then require("__gvv__.gvv")() end
