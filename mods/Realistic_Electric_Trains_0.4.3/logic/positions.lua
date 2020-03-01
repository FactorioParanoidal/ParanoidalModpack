--positions.lua

require("util")

do

	local n  = defines.direction.north
	local ne = defines.direction.northeast
	local e  = defines.direction.east
	local se = defines.direction.southeast
	local s  = defines.direction.south
	local sw = defines.direction.southwest
	local w  = defines.direction.west
	local nw = defines.direction.northwest

	local straight = "straight-rail"
	local curved = "curved-rail"

	-- Many, many lookup tables... 

	-- Note that a signal for driving northbound has the direction south

	local pole_to_wire = {
	    --        narrow                standard              wide
		[n]  = { {x =  1.2, y =  0.0}, {x =  1.5, y =  0.0}, {x =  1.8, y =  0.0} },
		[ne] = { {x =  0.8, y =  0.6}, {x =  1.1, y =  0.8}, {x =  1.4, y =  1.0} },
		[e]  = { {x =  0.0, y =  1.0}, {x =  0.0, y =  1.2}, {x =  0.0, y =  1.4} },
		[se] = { {x = -0.8, y =  0.6}, {x = -1.1, y =  0.8}, {x = -1.4, y =  1.0} },
		[s]  = { {x = -1.2, y =  0.0}, {x = -1.5, y =  0.0}, {x = -1.8, y =  0.0} },
		[sw] = { {x = -0.8, y = -0.6}, {x = -1.1, y = -0.8}, {x = -1.4, y = -1.0} },
		[w]  = { {x =  0.0, y = -1.0}, {x =  0.0, y = -1.2}, {x =  0.0, y = -1.4} },
		[nw] = { {x =  0.8, y = -0.6}, {x =  1.1, y = -0.8}, {x =  1.4, y = -1.0} }
	}

	local pole_to_rail = {
		[n] = {
			{x =  1.5, y =  0.5, rail = straight, dir = n},
			{x =  1.5, y = -0.5, rail = straight, dir = n},
			{x =  2.5, y = -3.5, rail = curved,   dir = ne},
			{x =  0.5, y = -3.5, rail = curved,   dir = n},
			{x =  0.5, y =  3.5, rail = curved,   dir = sw},
			{x =  2.5, y =  3.5, rail = curved,   dir = s},
		},
		[ne] = {
			{x =  1.5, y =  1.5, rail = straight, dir = nw},
			{x =  0.5, y =  0.5, rail = straight, dir = se},
			{x = -0.5, y =  3.5, rail = curved,   dir = ne},
			{x = -1.5, y =  2.5, rail = curved,   dir = e},
			{x =  3.5, y = -0.5, rail = curved,   dir = w},
			{x =  2.5, y = -1.5, rail = curved,   dir = sw},
		},
		[e] = {
			{x =  0.5, y =  1.5, rail = straight, dir = e},
			{x = -0.5, y =  1.5, rail = straight, dir = e},
			{x =  3.5, y =  2.5, rail = curved,   dir = se},
			{x =  3.5, y =  0.5, rail = curved,   dir = e},
			{x = -3.5, y =  2.5, rail = curved,   dir = w},
			{x = -3.5, y =  0.5, rail = curved,   dir = nw},
		},
		[se] = {
			{x = -1.5, y =  1.5, rail = straight, dir = ne},
			{x = -0.5, y =  0.5, rail = straight, dir = sw},
			{x =  0.5, y =  3.5, rail = curved,   dir = n},
			{x = -3.5, y = -0.5, rail = curved,   dir = se},
			{x =  1.5, y =  2.5, rail = curved,   dir = nw},
			{x = -2.5, y = -1.5, rail = curved,   dir = s},
		},
		[s] = {
			{x = -1.5, y =  0.5, rail = straight, dir = n},
			{x = -1.5, y = -0.5, rail = straight, dir = n},
			{x = -0.5, y = -3.5, rail = curved,   dir = ne},
			{x = -2.5, y = -3.5, rail = curved,   dir = n},
			{x = -0.5, y =  3.5, rail = curved,   dir = s},
			{x = -2.5, y =  3.5, rail = curved,   dir = sw},
		},
		[sw] = {
			{x = -0.5, y = -0.5, rail = straight, dir = nw},
			{x = -1.5, y = -1.5, rail = straight, dir = se},
			{x = -2.5, y =  1.5, rail = curved,   dir = ne},
			{x = -3.5, y =  0.5, rail = curved,   dir = e},
			{x =  1.5, y = -2.5, rail = curved,   dir = w},
			{x =  0.5, y = -3.5, rail = curved,   dir = sw},
		},
		[w] = {
			{x =  0.5, y = -1.5, rail = straight, dir = e},
			{x = -0.5, y = -1.5, rail = straight, dir = e},
			{x =  3.5, y = -2.5, rail = curved,   dir = e},
			{x =  3.5, y = -0.5, rail = curved,   dir = se},
			{x = -3.5, y = -0.5, rail = curved,   dir = w},
			{x = -3.5, y = -2.5, rail = curved,   dir = nw},
		},
		[nw] = { 
			{x =  0.5, y = -0.5, rail = straight, dir = ne},
			{x =  1.5, y = -1.5, rail = straight, dir = sw},
			{x =  2.5, y =  1.5, rail = curved,   dir = n},
			{x = -1.5, y = -2.5, rail = curved,   dir = se},
			{x =  3.5, y =  0.5, rail = curved,   dir = nw},
			{x = -0.5, y = -3.5, rail = curved,   dir = s},
		}
	}

	local rail_to_pole = {
		[straight] = {
			[n] = {
				{x = -1.5, y =  0.5, dir = n},
				{x = -1.5, y = -0.5, dir = n},
				{x =  1.5, y =  0.5, dir = s},
				{x =  1.5, y = -0.5, dir = s}
			},
			[e] = {
				{x = -0.5, y =  1.5, dir = w},
				{x = -0.5, y = -1.5, dir = e},
				{x =  0.5, y =  1.5, dir = w},
				{x =  0.5, y = -1.5, dir = e}
			},
			[nw] = {
				{x = -1.5, y = -1.5, dir = ne},
				{x =  0.5, y =  0.5, dir = sw}
			},
			[ne] = {
				{x =  1.5, y = -1.5, dir = se},
				{x = -0.5, y =  0.5, dir = nw}
			},
			[se] = {
				{x =  1.5, y =  1.5, dir = sw},
				{x = -0.5, y = -0.5, dir = ne}
			},
			[sw] = {
				{x = -1.5, y =  1.5, dir = nw},
				{x =  0.5, y = -0.5, dir = se}
			}
		},
		[curved] = {
			[n] = {
				{x =  2.5, y =  3.5, dir = s},
				{x = -0.5, y =  3.5, dir = n},
				{x = -0.5, y = -3.5, dir = se},
				{x = -2.5, y = -1.5, dir = nw}
			},
			[ne] = {
				{x = -2.5, y =  3.5, dir = n},
				{x =  0.5, y =  3.5, dir = s},
				{x =  2.5, y = -1.5, dir = sw},
				{x =  0.5, y = -3.5, dir = ne}
			},
			[e] = {
				{x = -3.5, y = -0.5, dir = e},
				{x = -3.5, y =  2.5, dir = w},
				{x =  1.5, y = -2.5, dir = ne},
				{x =  3.5, y = -0.5, dir = sw}
			},
			[se] = {
				{x = -3.5, y = -2.5, dir = e},
				{x = -3.5, y =  0.5, dir = w},
				{x =  3.5, y =  0.5, dir = se},
				{x =  1.5, y =  2.5, dir = nw}
			},
			[s] = {
				{x = -2.5, y = -3.5, dir = n},
				{x =  0.5, y = -3.5, dir = s},
				{x =  2.5, y =  1.5, dir = se},
				{x =  0.5, y =  3.5, dir = nw}
			},
			[sw] = {
				{x =  2.5, y = -3.5, dir = s},
				{x = -0.5, y = -3.5, dir = n},
				{x = -2.5, y =  1.5, dir = ne},
				{x = -0.5, y =  3.5, dir = sw}
			},
			[w] = {
				{x =  3.5, y = -2.5, dir = e},
				{x =  3.5, y =  0.5, dir = w},
				{x = -3.5, y =  0.5, dir = ne},
				{x = -1.5, y =  2.5, dir = sw}
			},
			[nw] = {
				{x =  3.5, y =  2.5, dir = w},
				{x =  3.5, y = -0.5, dir = e},
				{x = -1.5, y = -2.5, dir = se},
				{x = -3.5, y = -0.5, dir = nw}
			}
		}
	}

	local rail_to_rail = {
		[straight] = {
			-- rail rotation north
			[n] = {
				-- driving direction north
				[n] = {
					{x =  0, y = -2, rail = straight, dir = n,  drive = n},
					{x =  1, y = -5, rail = curved,   dir = ne, drive = ne},
					{x = -1, y = -5, rail = curved,   dir = n,  drive = nw}
				},
				-- driving direction south
				[s] = {
					{x =  0, y =  2, rail = straight, dir = n,  drive = s},
					{x =  1, y =  5, rail = curved,   dir = s,  drive = se},
					{x = -1, y =  5, rail = curved,   dir = sw, drive = sw}
				}
			},
			-- rail rotation east
			[e] = {
				-- driving direction east
				[e] = {
					{x =  2, y =  0, rail = straight, dir = e,  drive = e},
					{x =  5, y =  1, rail = curved,   dir = se, drive = se},
					{x =  5, y = -1, rail = curved,   dir = e,  drive = ne}
				},
				-- driving direction west
				[w] = {
					{x = -2, y =  0, rail = straight, dir = e,  drive = w},
					{x = -5, y =  1, rail = curved,   dir = w,  drive = sw},
					{x = -5, y = -1, rail = curved,   dir = nw, drive = nw}
				}
			},
			-- rail rotation northeast
			[ne] = {
				-- driving direction northwest
				[nw] = {
					{x =  0, y = -2, rail = straight, dir = sw, drive = nw},
					{x = -3, y = -3, rail = curved,   dir = se, drive = w}
				}, 
				-- driving direction southeast
				[se] = {
					{x =  2, y =  0, rail = straight, dir = sw, drive = se},
					{x =  3, y =  3, rail = curved,   dir = n,  drive = s}
				}
			},
			-- rail rotation southeast
			[se] = {
				-- driving directio northeast
				[ne] = {
					{x =  2, y =  0, rail = straight, dir = nw, drive = ne},
					{x =  3, y = -3, rail = curved,   dir = sw, drive = n}
				},
				-- driving direction southwest
				[sw] = {
					{x =  0, y =  2, rail = straight, dir = nw, drive = sw},
					{x = -3, y =  3, rail = curved,   dir = e,  drive = w}
				}
			},
			-- rail rotation southwest
			[sw] = {
				-- driving direction northwest
				[nw] = {
					{x = -2, y =  0, rail = straight, dir = ne, drive = nw},
					{x = -3, y = -3, rail = curved,   dir = s,  drive = n}
				},
				-- driving direction southeast
				[se] = {
					{x =  0, y =  2, rail = straight, dir = ne, drive = se},
					{x =  3, y =  3, rail = curved,   dir = nw, drive = e}
				}
			},
			-- rail rotation northwest
			[nw] = {
				-- driving direction northeast
				[ne] = {
					{x =  0, y = -2, rail = straight, dir = se, drive = ne},
					{x =  3, y = -3, rail = curved,   dir = w,  drive = e}
				},
				-- driving direction southwest
				[sw] = {
					{x = -2, y =  0, rail = straight, dir = se, drive = sw},
					{x = -3, y =  3, rail = curved,   dir = ne, drive = s}
				}
			}
		},
		[curved] = {
			-- rail rotation north
			[n] = {
				-- driving direction south
				[s] = {
					{x =  1, y =  5, rail = straight, dir = n,  drive = s},
					{x =  0, y =  8, rail = curved,   dir = sw, drive = sw},
					{x =  2, y =  8, rail = curved,   dir = s,  drive = se}
				},
				-- driving direction northwest
				[nw] = {
					{x = -3, y = -3, rail = straight, dir = ne, drive = nw},
					{x = -4, y = -6, rail = curved,   dir = s,  drive = n}
				}
			},
			-- rail rotation northeast
			[ne] = {
				-- driving direction south
				[s] = {
					{x = -1, y =  5, rail = straight, dir = n,  drive = s},
					{x =  0, y =  8, rail = curved,   dir = s,  drive = se},
					{x = -2, y =  8, rail = curved,   dir = sw, drive = sw}
				},
				-- driving direction northeast
				[ne] = {
					{x =  3, y = -3, rail = straight, dir = nw, drive = ne},
					{x =  4, y = -6, rail = curved,   dir = sw, drive = n}
				}
			},
			-- rail rotation east
			[e] = {
				-- driving direction west
				[w] = {
					{x = -5, y =  1, rail = straight, dir = e,  drive = w},
					{x = -8, y =  0, rail = curved,   dir = nw, drive = nw},
					{x = -8, y =  2, rail = curved,   dir = w,  drive = sw}
				},
				-- driving direction northeast
				[ne] = {
					{x =  3, y = -3, rail = straight, dir = se, drive = ne},
					{x =  6, y = -4, rail = curved,   dir = w,  drive = e}
				}
			},
			-- rail rotation southeast
			[se] = {
				-- driving direction west
				[w] = {
					{x = -5, y = -1, rail = straight, dir = e,  drive = w},
					{x = -8, y =  0, rail = curved,   dir = w,  drive = sw},
					{x = -8, y = -2, rail = curved,   dir = nw, drive = nw}
				},
				-- driving direction southeast
				[se] = {
					{x =  3, y =  3, rail = straight, dir = ne, drive = se},
					{x =  6, y =  4, rail = curved,   dir = nw, drive = e}
				}
			},
			-- rail rotation south
			[s] = {
				-- driving direction north
				[n] = {
					{x = -1, y = -5, rail = straight, dir = n,  drive = n},
					{x =  0, y = -8, rail = curved,   dir = ne, drive = ne},
					{x = -2, y = -8, rail = curved,   dir = n,  drive = nw}
				},
				-- driving direction southeast
				[se] = {
					{x =  3, y =  3, rail = straight, dir = sw, drive = se},
					{x =  4, y =  6, rail = curved,   dir = n,  drive = s}
				}
			},
			-- rail rotation southwest
			[sw] = {
				-- driving direction north
				[n] = {
					{x =  1, y = -5, rail = straight, dir = n,  drive = n},
					{x =  0, y = -8, rail = curved,   dir = n,  drive = nw},
					{x =  2, y = -8, rail = curved,   dir = ne, drive = ne}
				},
				-- driving direction southwest
				[sw] = {
					{x = -3, y =  3, rail = straight, dir = se, drive = sw},
					{x = -4, y =  6, rail = curved,   dir = ne, drive = s}
				}
			},
			-- rail rotation west
			[w] = {
				-- driving direction east
				[e] = {
					{x =  5, y = -1, rail = straight, dir = e,  drive = e},
					{x =  8, y =  0, rail = curved,   dir = se, drive = se},
					{x =  8, y = -2, rail = curved,   dir = e,  drive = ne}
				},
				-- driving direction southwest
				[sw] = {
					{x = -3, y =  3, rail = straight, dir = nw, drive = sw},
					{x = -6, y =  4, rail = curved,   dir = e,  drive = w}
				}
			},
			-- rail rotation northwest
			[nw] = {
				-- straight side
				[e] = {
					{x =  5, y =  1, rail = straight, dir = e,  drive = e},
					{x =  8, y =  0, rail = curved,   dir = e,  drive = ne},
					{x =  8, y =  2, rail = curved,   dir = se, drive = se}
				},
				-- diagonal side
				[nw] = {
					{x = -3, y = -3, rail = straight, dir = sw, drive = nw},
					{x = -6, y = -4, rail = curved,   dir = se, drive = w}
				}
			}
		}
	}

	local driving_dir_for_rail = {
		[straight] = {
			[n] =  {n, s},
			[e] =  {e, w},
			[ne] = {nw, se},
			[se] = {ne, sw},
			[sw] = {nw, se},
			[nw] = {ne, sw}
		},
		[curved] = {
			[n] =  {s, nw},
			[ne] = {s, ne},
			[e] =  {w, ne},
			[se] = {w, se},
			[s] =  {n, se},
			[sw] = {n, sw},
			[w] =  {e, sw},
			[nw] = {e, nw}
		}
	}

	function fix_pole_name_and_dir(pole)
		local name = pole.name
		local dir = pole.direction
		-- Zero directions in blueprints are not even stored.
		if not dir then dir = 0 end
		if name == "ret-pole-base-straight" then
			return "ret-pole-base", dir
		elseif name == "ret-pole-base-diagonal" then
			return "ret-pole-base", dir + 1
		else
			return name, dir
		end
	end

	function fix_pole_dir(pole)
		local dir = pole.direction
		-- Zero directions in blueprints are not even stored.
		if not dir then dir = 0 end
		if pole.name == "ret-pole-base-diagonal" then
			return dir + 1
		else
			return dir
		end
	end

	function fix_pole_build_name_and_dir(name, dir)
		if name == "ret-pole-base" then
			if dir % 2 == 0 then
				return "ret-pole-base-straight", dir
			else
				return "ret-pole-base-diagonal", dir - 1
			end
		else
			return name, dir
		end
	end

	function wire_pos_for_pole(pos, dir, mode)
		if not mode then mode = 2 end
		local l = pole_to_wire[dir][mode]
		return { x = pos.x + l.x, y = pos.y + l.y }
	end

	function find_wire_mode(pole, wire)
		local dir = fix_pole_dir(pole)
		local dx = wire.position.x - pole.position.x
		local dy = wire.position.y - pole.position.y

		local function approx(x, y)
			return math.abs(x - y) < 0.01
		end

		for mode = 1,3 do
			if approx(pole_to_wire[dir][mode].x, dx) and 
			   approx(pole_to_wire[dir][mode].y, dy) then
					return mode
			end
		end
		return 2 -- standard
	end

	function pole_pos_for_rail(rail_type, rail_pos, rail_dir)
		local lookup = table.deepcopy(rail_to_pole[rail_type][rail_dir])
		for _, v in pairs(lookup) do
			v.x = v.x + rail_pos.x
			v.y = v.y + rail_pos.y
		end
		return lookup
	end

	function rail_pos_for_pole(pole_pos, pole_dir)
		local lookup = table.deepcopy(pole_to_rail[pole_dir])
		for _, v in pairs(lookup) do
			v.x = v.x + pole_pos.x
			v.y = v.y + pole_pos.y
		end
		return lookup
	end

	function driving_dirs_for_rail(rail_type, rail_dir)
		return driving_dir_for_rail[rail_type][rail_dir]
	end	

	function rail_pos_for_rail(rail_type, rail_pos, rail_dir, drive_dir)
		local lookup_ref = rail_to_rail[rail_type][rail_dir][drive_dir]
		if lookup_ref == nil then return {} end
		local lookup = table.deepcopy(lookup_ref)
		for _, v in pairs(lookup) do
			v.x = v.x + rail_pos.x
			v.y = v.y + rail_pos.y
		end
		return lookup
	end

	function around_position(pos, d)
		if not d then d = 0.5 end
		return {{pos.x - d, pos.y - d}, {pos.x + d, pos.y + d}}
	end
end
