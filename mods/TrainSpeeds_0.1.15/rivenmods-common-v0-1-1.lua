GAME_FRAMERATE = 60.0;
IS_VERBOSE = false



function ensure_global_mapping(key)
	if not global[key] then
		global[key] = {}
	end
end

function ensure_global_rndm()
	if not global.rndm then
		global.rndm = game.create_random_generator()
		global.rndm.re_seed(1337);
	end
end

function map_value_equals(map, key, value)
	return map[key] and map[key] == value
end

function mod_log(msg)
	if IS_VERBOSE then
		game.print('log: ' .. msg);
	end
end



function math_sign(x)
   if x < 0 then
     return -1
   elseif x > 0 then
     return 1
   else
     return 0
   end
end

function math_pow2(x)
	return x * x
end



function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function starts_with(str, start)
   return str:sub(1, #start) == start
end

function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function table_length(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end



function deeptostring(orig)
    local text
	if orig == nil then
		text = 'nil'
	elseif type(orig) == 'string' then
		text = '"' .. orig .. '"'
	elseif type(orig) == 'table' then
		text = ''
        for orig_key, orig_value in next, orig, nil do
            text = text .. deeptostring(orig_key) .. '=' .. deeptostring(orig_value) .. ','
        end
        -- text = '[' .. text .. deeptostring(getmetatable(orig)) .. ']'
        text = '[' .. text .. ']'
    else
        text = tostring(orig)
    end
    return text
end













function findTrains()
	global.trainId2train = {}
	for _idx1_, surface in pairs(game.surfaces) do
		for _idx2_, train in pairs(surface.get_trains()) do
			global.trainId2train[train.id] = train;
		end
	end
end


function getTrainSpeed(train)
	return train.speed * GAME_FRAMERATE * 3.6;
end

function setTrainSpeed(train, speed)
	local signA = math_sign(train.speed);
	local signB = math_sign(speed);
	if math.abs(signA - signB) == 2 then
		-- do not flip velocity, stop instead
		speed = 0.0
	end
	train.speed = speed / GAME_FRAMERATE / 3.6;
end