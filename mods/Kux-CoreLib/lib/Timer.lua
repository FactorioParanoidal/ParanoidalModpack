-- WORK IN PROGRESS - NOT USABLE YET


require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Timer : KuxCoreLib.Class
---@field asGloaböl fun():KuxCoreLib.Timer Provides Timer in the global namespace
local Timer = {
	__class  = "Timer",
	__guid   = "fba8b087-083d-43d9-b4d6-4fa1743b1562",
	__origin = "Kux-CoreLib/lib/Timer.lua",
}
if not KuxCoreLib.__classUtils.ctor(Timer) then return self end
---------------------------------------------------------------------------------------------------
if(not script) then
	KuxCoreLib.__classUtils.finalize(Timer)
	return Timer
end -- only initialized if in control stage

local PlayerStorage = KuxCoreLib.PlayerStorage
local Events = KuxCoreLib.Events


---@class KuxCoreLib.TimerData
---@field tick integer   game.ticks on which the event raises
---@field action string  The action which is executed, The action must be registered in Timer.actions
---@field args table     Te parameters for the action


--- A dictionary of functions accessible by name.
--- The functions must be registered like other events in on_init and re-gistrered in on_load each time
---@type {[string]: fun(args:table)}
Timer.actions = {}

---@param player_index integer
---@param tick integer
---@param action string
---@param args table
function Timer.add(player_index, tick, action, args)
	if not Timer.actions[action] then error("Action not found: " .. action) end

	local new_timer = {
        tick = tick,
        action = action,
        args = args
    }
    local timers = PlayerStorage[player_index].__KuxCoreLib__.timers  -- TODO
    for i = 1, #timers do
        if tick < timers[i].tick then
            table.insert(timers, i, new_timer)
            return
		end
    end
    table.insert(timers, new_timer)
end


---@param e EventData.on_tick
---@param player_index uint
---@param timers KuxCoreLib.TimerData[]
local function check(e, player_index, timers)
	if timers then return end
	while timers[1] and timers[1].tick <= e.tick do
		local timerData = table.remove(timers, 1)
		timerData.args = timerData.args or {}
		timerData.args.player_index = player_index
		local f = Timer.actions[timerData.action]
		if f then f(timerData.args) end
	end
end

function Timer.next_tick(player_index, action, data)
	Timer.add(player_index, game.tick + 1, action, data)
end

if not Events.__isInitialized then error("KuxCoreLib.Events is not yet initialized!") end

Events.on_tick(function(e)
	for player_index, pdata in pairs(PlayerStorage.raw) do
		check(e, player_index, pdata.__KuxCoreLib__.timers)
	end
end)
---------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(Timer)
return Timer