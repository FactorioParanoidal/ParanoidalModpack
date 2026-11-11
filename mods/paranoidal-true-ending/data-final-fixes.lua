-- After every other mod: only the technology of this mod opens the debris belt and the Shattered Planet, and the
-- promethium science pack opens the halfway point (a later mod could have put Space Age's unlock back).
local names = require("shared.names")

local LATE = {[names.belt] = true, [names.target] = true}
local removed = {}
for name, technology in pairs(data.raw.technology) do
	if name ~= names.technology and technology.effects then
		for i = #technology.effects, 1, -1 do
			local effect = technology.effects[i]
			if effect.type == "unlock-space-location" and LATE[effect.space_location] then
				table.remove(technology.effects, i)
				removed[#removed + 1] = name .. ":" .. effect.space_location
			end
		end
	end
end

local promethium = data.raw.technology[names.promethium_technology]
if promethium then
	local present = false
	for _, effect in ipairs(promethium.effects or {}) do
		present = present or (effect.type == "unlock-space-location" and effect.space_location == names.halfway)
	end
	if not present then
		promethium.effects = promethium.effects or {}
		table.insert(promethium.effects, 1, {type = "unlock-space-location", space_location = names.halfway,
			use_icon_overlay_constant = true})
		removed[#removed + 1] = "halfway unlock added back to " .. names.promethium_technology
	end
end

if #removed > 0 then log("paranoidal-true-ending: late unlocks fixed: " .. table.concat(removed, ", ")) end
