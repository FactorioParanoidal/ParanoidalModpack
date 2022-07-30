local F = '__factorissimo-2-notnotmelon__'
alien_biomes_priority_tiles = alien_biomes_priority_tiles or {}
local alt_graphics = settings.startup['Factorissimo2-alt-graphics'].value

local function make_tile(tinfo)
	table.insert(alien_biomes_priority_tiles, tinfo.name)
	data:extend({
		{
			type = 'tile',
			name = tinfo.name,
			needs_correction = false,
			collision_mask = tinfo.collision_mask,
			layer = tinfo.layer or 50,
			variants = {
				main = tinfo.pictures,
				inner_corner = { picture = F..'/graphics/nothing.png', count = 0 },
				outer_corner = { picture = F..'/graphics/nothing.png', count = 0 },
				side = { picture = F..'/graphics/nothing.png', count = 0 },
				u_transition = { picture = F..'/graphics/nothing.png', count = 0 },
				o_transition = { picture = F..'/graphics/nothing.png', count = 0 },
			},
			walking_speed_modifier = 1.3,
			walking_sound = {
				{
					filename = '__base__/sound/walking/concrete-01.ogg',
					volume = 1.2
				},
				{
					filename = '__base__/sound/walking/concrete-02.ogg',
					volume = 1.2
				},
				{
					filename = '__base__/sound/walking/concrete-03.ogg',
					volume = 1.2
				},
				{
					filename = '__base__/sound/walking/concrete-04.ogg',
					volume = 1.2
				}
			},
			map_color = tinfo.map_color or {r = 1},
			pollution_absorption_per_second = 0.0006
		},
	})
end

local function wall_mask()
	return {
		'ground-tile',
		'water-tile',
		'resource-layer',
		'floor-layer',
		'item-layer',
		'object-layer',
		'player-layer',
		'doodad-layer'
	}
end

local function edge_mask()
	return {
		'ground-tile',
		'water-tile',
		'resource-layer',
		'floor-layer',
		'item-layer',
		'object-layer',
		'doodad-layer'
	}
end

local function floor_mask()
	return {
		'ground-tile'
	}
end

local function pictures_ff(i)
	return {
		{
			picture = F..'/graphics/tile/ff_1.png',
			count = 16,
			size = 1
		},
		{
			picture = F..'/graphics/tile/ff_2.png',
			count = 4,
			size = 2,
			probability = 0.39
		},
		{
			picture = F..'/graphics/tile/ff_4.png',
			count = 4,
			size = 4,
			probability = 1
		},
	}
end

local function pictures_fp(i)
	return {
		{
			picture = F..'/graphics/tile/fw'..i..'_1.png',
			count = 16,
			size = 1
		},
	}
end

local function pictures_fw(i)
	return {
		{
			picture = F..'/graphics/tile/fw'..i..'_1.png',
			count = 16,
			size = 1
		},
	}
end

local function f1fc() return {r=130,g=110,b=100} end
local function f1wc() return {r=190,g=125,b=80} end
local function f2fc() return {r=100,g=120,b=140} end
local function f2wc() return {r=80,g=140,b=200} end
local function f3fc() return {r=120,g=120,b=100} end
local function f3wc() return {r=190,g=190,b=80} end

make_tile{
	name = 'factory-entrance',
	collision_mask = edge_mask(),
	layer = 30,
	pictures = pictures_ff(1),
	map_color = f1fc(),
}

make_tile{
	name = 'factory-floor',
	collision_mask = floor_mask(),
	layer = 30,
	pictures = pictures_ff(1),
	map_color = f1fc(),
}

-- Factory 1

make_tile{
	name = 'factory-wall-1',
	collision_mask = edge_mask(),
	layer = 30,
	pictures = pictures_fw(1),
	map_color = f1wc(),
}

make_tile{
	name = 'factory-pattern-1',
	collision_mask = floor_mask(),
	layer = 30,
	pictures = alt_graphics and pictures_ff(1) or pictures_fw(1),
	map_color = f1wc(),
}

-- Factory 2

make_tile{
	name = 'factory-wall-2',
	collision_mask = edge_mask(),
	layer = 70,
	pictures = pictures_fw(2),
	map_color = f2wc(),
}

make_tile{
	name = 'factory-pattern-2',
	collision_mask = floor_mask(),
	layer = 70,
	pictures = alt_graphics and pictures_ff(1) or pictures_fw(2),
	map_color = f2wc(),
}

-- Factory 3

make_tile{
	name = 'factory-wall-3',
	collision_mask = edge_mask(),
	layer = 70,
	pictures = pictures_fw(3),
	map_color = f3wc(),
}

make_tile{
	name = 'factory-pattern-3',
	collision_mask = floor_mask(),
	layer = 70,
	pictures = alt_graphics and pictures_ff(1) or pictures_fw(3),
	map_color = f3wc(),
}
