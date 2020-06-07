--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: processTrainBasic.lua
 * Description: Reads a train and locates locomotives to replace per the "basic" algorithm.
 *    Upgraded pairs must be part of a contiguous unit of locomotives (not separated by any wagons).
 *    Upgraded locomotives that are found with a partner will be downgraded.
--]]


function processTrainBasic(t)

	local front_movers = t.locomotives["front_movers"]
	local back_movers = t.locomotives["back_movers"]

	-- We can only convert locomotives that are adjacent to one another
	-- Make a list of contiguous units of two or more locomotives
	local loco_units = {}
	local unit_start = 0
	local unit_end = 0
	for i,c in ipairs(t.carriages) do
		if unit_start == 0 then
			-- Look for first locomotive in the unit, skip wagons
			-- For compatibility with X-12 Nuclear Locomotive mod, x12-nuclear-tender is a fluid wagon that acts as part of a locomotive.
			if c.type == "locomotive" or c.name == "x12-nuclear-tender" then
				-- start unit that is length 1
				unit_start = i
				unit_end = i
				table.insert(loco_units,{c})
			end
		else
			-- Look for the last locomotive in the unit
			if c.type == "locomotive" or c.name == "x12-nuclear-tender" then
				-- update end of unit to this index
				unit_end = i
				table.insert(loco_units[#loco_units],c)
			else
				-- found wagon, close previous unit.
				unit_start = 0
				--local n = #loco_units
				--if #loco_units[n] < 2 then
				--	loco_units[n] = nil
				--end
			end
		end
	end
	
	-- Now search each loco_unit separately
	
	local found_pairs = {}
	local upgrade_locos = {}
	local unpaired_locos = {}
	
	for _,unit in pairs(loco_units) do
		
		
		-- For every front_mover, look for its twin in back_movers
		for _,loco1 in pairs(front_movers) do
			local loco1_here = false
			for _,loco1a in pairs(unit) do
				if loco1 == loco1a then
					loco1_here = true
					break
				end
			end
			if loco1_here then
				-- Loco1 is a front_mover in this unit
				local loco1_done = false
				if global.downgrade_pairs[loco1.name] then
					local mu_name = loco1.name
					local std_name = global.downgrade_pairs[mu_name]
					-- Found an MU, look for its twin as an MU first
					for _,loco2 in pairs(back_movers) do
						if loco2.name == mu_name then
							-- Potential twin, make sure it's in this unit
							local loco2_here = false
							for _,loco2a in pairs(unit) do
								if loco2 == loco2a then
									loco2_here = true
									break
								end
							end
							if loco2_here then
								-- Potential twin, make sure it's not in a pair already
								local loco2_free = true
								for _,this_pair in pairs(found_pairs) do
									if this_pair[1] == loco2 or this_pair[2] == loco2 then  -- (back_mover is always 2nd member of a pair)
										loco2_free = false
										break
									end
								end
								if loco2_free and checkModuleMatching(loco1,loco2) then
									-- Found an MU twin, they are already a pair
									--game.print("Adding pair [" .. loco1.backer_name .. ", " .. loco2.backer_name .. "]")
									table.insert(found_pairs,{loco1,loco2})
									loco1_done = true
									break
								end
							end
						end
					end
					if not loco1_done then
						-- Didn't find an MU twin, look for a normal twin to this MU so we can upgrade it
						for _,loco2 in pairs(back_movers) do
							if loco2.name == std_name then
								-- Potential twin, make sure it's in this unit
								local loco2_here = false
								for _,loco2a in pairs(unit) do
									if loco2 == loco2a then
										loco2_here = true
										break
									end
								end
								if loco2_here then-- Potential twin, make sure it's not in a pair already
									local loco2_free = true
									for _,this_pair in pairs(found_pairs) do
										if this_pair[1] == loco2 or this_pair[2] == loco2 then  -- (back_mover is always 2nd member of a pair)
											loco2_free = false
											break
										end
									end
									if loco2_free and checkModuleMatching(loco1,loco2) then
										-- Found a normal twin, upgrade loco2
										--game.print("Adding pair [" .. loco1.backer_name .. ", " .. loco2.backer_name .. "]")
										table.insert(found_pairs,{loco1,loco2})
										table.insert(upgrade_locos,{loco2,mu_name})
										loco1_done = true
										break
									end
								end
							end
						end
						
						if not loco1_done then
							-- Didn't find a twin to upgrade, have to downgrade this one :(
							--game.print("Downgrading unpaired front mover " .. loco1.backer_name )
							table.insert(upgrade_locos,{loco1,std_name})
							table.insert(unpaired_locos,loco1)
						end
					end
					
				elseif global.upgrade_pairs[loco1.name] then
					local std_name = loco1.name
					local mu_name = global.upgrade_pairs[std_name]
					-- Found a normal, look for its twin as an MU first
					for _,loco2 in pairs(back_movers) do
						if loco2.name == mu_name then
							-- Potential twin, make sure it's in this unit
							local loco2_here = false
							for _,loco2a in pairs(unit) do
								if loco2 == loco2a then
									loco2_here = true
									break
								end
							end
							if loco2_here then
								-- Potential twin, make sure it's not in a pair already
								local loco2_free = true
								for _,this_pair in pairs(found_pairs) do
									if this_pair[1] == loco2 or this_pair[2] == loco2 then  -- (back_mover is always 2nd member of a pair)
										loco2_free = false
										break
									end
								end
								if loco2_free and checkModuleMatching(loco1,loco2) then
									-- Found an MU twin, upgrade loco1
									--game.print("Adding pair [" .. loco1.backer_name .. ", " .. loco2.backer_name .. "]")
									table.insert(found_pairs,{loco1,loco2})
									table.insert(upgrade_locos,{loco1,mu_name})
									loco1_done = true
									break
								end
							end
						end
					end
					if not loco1_done then
						-- Didn't find an MU twin, look for a normal twin to this MU so we can upgrade it
						for _,loco2 in pairs(back_movers) do
							if loco2.name == std_name then
								-- Potential twin, make sure it's in this unit
								local loco2_here = false
								for _,loco2a in pairs(unit) do
									if loco2 == loco2a then
										loco2_here = true
										break
									end
								end
								if loco2_here then
									-- Potential twin, make sure it's not in a pair already
									local loco2_free = true
									for _,this_pair in pairs(found_pairs) do
										if this_pair[1] == loco2 or this_pair[2] == loco2 then  -- (back_mover is always 2nd member of a pair)
											loco2_free = false
											break
										end
									end
									if loco2_free and checkModuleMatching(loco1,loco2) then
										-- Found a normal twin, upgrade loco1 and loco2
										--game.print("Adding pair [" .. loco1.backer_name .. ", " .. loco2.backer_name .. "]")
										table.insert(found_pairs,{loco1,loco2})
										table.insert(upgrade_locos,{loco1,mu_name})
										table.insert(upgrade_locos,{loco2,mu_name})
										loco1_done = true
										break
									end
								end
							end
							if not loco1_done then
								-- if no twin for std loco1, do nothing
								table.insert(unpaired_locos,loco1)
							end
						end
						
					end
				end
			end
		end
		
		
	end
	
	-- If there are any unpaired MU locos left over in back_movers, they must be downgraded!
	-- Didn't find an MU twin, look for a normal twin to this MU so we can upgrade it
	for _,loco2 in pairs(back_movers) do
		-- Potential straggler, make sure it's not in a pair already
		local loco2_free = true
		for _,this_pair in pairs(found_pairs) do
			if this_pair[1] == loco2 or this_pair[2] == loco2 then  -- (back_mover is always 2nd member of a pair)
				loco2_free = false
				break
			end
		end
		if loco2_free then
			if global.downgrade_pairs[loco2.name] then
				-- Found an unpaired MU, downgrade it
				--game.print("Found back straggler " .. loco2.backer_name)
				table.insert(upgrade_locos,{loco2, global.downgrade_pairs[loco2.name]})
				loco1_done = true
				break
			end
			-- record straggler
			table.insert(unpaired_locos,loco2)
		end
	end
	
	return found_pairs, upgrade_locos, unpaired_locos
end

return processTrainBasic	
