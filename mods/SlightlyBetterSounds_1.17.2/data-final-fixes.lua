-- Setup each replacement sound as a function that returns a new appropriate sound table
-- That way someone clobbering a sound table in the raws doesn't hurt.
local sounds = {}
local function setup_sound(file, volume)
	local files = {
		"__SlightlyBetterSounds__/sounds/"..file.."1.ogg",
		"__SlightlyBetterSounds__/sounds/"..file.."2.ogg",
		"__SlightlyBetterSounds__/sounds/"..file.."3.ogg",
	}
	sounds[file] = function()
		return {
			{filename = files[1], volume = volume},
			{filename = files[2], volume = volume},
			{filename = files[3], volume = volume},
		}
	end
end
setup_sound("Tank_Turret", 0.5)
setup_sound("Gun_Turret", 0.5)
setup_sound("Laser_Turret", 0.9)
setup_sound("Sniper_Turret", 0.5)

-- Replacements based on sound file
local sound_map = {
	["__base__/sound/fight/tank-cannon.ogg"] = sounds.Tank_Turret,
	[make_heavy_gunshot_sounds()[1].filename] = sounds.Gun_Turret,
	[make_laser_sounds()[1].filename] = sounds.Laser_Turret,
}

-- Replacements based on key name
local key_map = {
	-- ["bob-sniper-turret-1"] = sounds.Sniper_Turret,
	-- ["bob-sniper-turret-2"] = sounds.Sniper_Turret,
	-- ["bob-sniper-turret-3"] = sounds.Sniper_Turret,
}

-- Replacements on partial key name - be mindful of magic characters (^$()%.[]*+-?)
local partial_key_map = {
	["sniper%-turret"] = sounds.Sniper_Turret,
}

local partial_keys = {}
local partial_values = {}
local pi = 0
for k,v in pairs(partial_key_map) do
	pi = pi + 1
	partial_keys[pi] = k
	partial_values[pi] = v
end

-- Check data.raw for stuff we want to update
local find = string.find
for rk,rv in pairs(data.raw) do
	for k,v in pairs(rv) do
		if v.attack_parameters and v.attack_parameters.sound then
			-- By key
			if key_map[k] then
				v.attack_parameters.sound = key_map[k]()
			else
				-- By partial key match
				for i=1,pi do 
					if find(k, partial_keys[i]) then
						v.attack_parameters.sound = partial_values[i]()
						goto skip
					end
				end
				if not matched then
					-- By sound file
					local s = v.attack_parameters.sound[1]
					if s and s.filename and sound_map[s.filename] then
						v.attack_parameters.sound = sound_map[s.filename]()
					end
				end
				::skip::
			end
		end
	end
end

--from DrD
data.raw["utility-sounds"]["default"]["game_lost"] =
{
  {
	filename = "__SlightlyBetterSounds__/sounds/you_died.ogg",
	volume = 1.5
  }
}

