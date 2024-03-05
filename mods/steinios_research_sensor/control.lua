require "util"

local NINF = -math.huge
local PINF =  math.huge

--It is fired once every tick. Since this event is fired every tick, its handler shouldn't include performance heavy code.
function on_tick()
	if game.tick % 120 ~= 0 then return end
			
	global.last_percentage_value = global.last_percentage_value or 0
	local force = game.forces.player
	local current_research = force.current_research
	local research_progress = force.research_progress
	local text = ""
	
	if current_research ~= nil then
		local delta_percentage_value     	= research_progress - global.last_percentage_value
		local remaining_percentage_value	= 1 - research_progress
		local remaining_percentage_chunks 	= remaining_percentage_value / delta_percentage_value
		local remaining_time_seconds		= 5 * remaining_percentage_chunks

		global.last_percentage_value = research_progress

		text = {'rs-active', current_research.localised_name, string.format('%.2f', research_progress*100), build_clock_string(remaining_time_seconds)}
	else
		text = {'rs-inactive'}
	end   
		
	remote.call(
		"EvoGUI", 
		"update_remote_sensor", 
		"steinio_rs", 
		text
	)
end

local function on_init()
	global.last_percentage_value = 0

	remote.call
	(
		"EvoGUI", 
		"create_remote_sensor", 
		{ 
			mod_name = "steinios_research_sensor",
			name = "steinio_rs", 
			text = {'rs-inactive'}, 
			caption = {'rs-name'}
		}
	)
end

local function on_research_started()
	global.last_percentage_value = 0
end

local function on_research_finished()
	global.last_percentage_value = 0
end

-------------------
-- Helper methods
-------------------

function math.isinf(value)
    -- Returns 1 if given value is a positive infinity or -1 if given value is a negative infinity;
    -- otherwise 0 or nil if value is not of type string nor number.
    if type(value) == "string" then
        value = tonumber(value)
        if value == nil then
            return nil
        end
    elseif type(value) ~= "number" then
        return nil
    end
    
    if value == PINF then 
        return 1
    end
    
    if value == NINF then
        return -1
    end
    
    return 0
end

function build_clock_string(remaining_time_seconds)
    local remaining_time_seconds = tonumber(remaining_time_seconds)
    if math.isinf(remaining_time_seconds) == 1 or math.isinf(remaining_time_seconds) == -1 or remaining_time_seconds <= 0 or not remaining_time_seconds or remaining_time_seconds == nil then
        return "--:--:--";
    end

    local hours = string.format("%02.f", math.floor(remaining_time_seconds / 3600));
    local mins = string.format("%02.f", math.floor(remaining_time_seconds / 60 - (tonumber(hours) * 60)));
    local secs = string.format("%02.f", math.floor(remaining_time_seconds - tonumber(hours) * 3600 - tonumber(mins) * 60));
    return "" .. hours .. ":" .. mins .. ":" .. secs;
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--------------------
-- Register events
--------------------

script.on_event(defines.events.on_research_started, on_research_started)
script.on_event(defines.events.on_research_finished, on_research_finished)
script.on_event(defines.events.on_tick, on_tick)
script.on_init(on_init)