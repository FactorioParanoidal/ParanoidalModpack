local cfg1 = require("config.config-1")



local dr = data.raw
local tech = dr.technology
local FRG = {	-- Default fast_replaceable_group
	["stone-wall"] = "wall",
	["gate"] = "wall"
}
local stone_wall = dr.wall["stone-wall"]
local stone_gate = dr.gate["gate"]



if not cfg1.class_on["concrete-wall"] then
  tech["Schall-concrete-wall"] = nil
else
	if stone_wall then
		if stone_wall.fast_replaceable_group ~= FRG[stone_wall.name] then
			stone_wall.fast_replaceable_group = FRG[stone_wall.name]
		end
	  stone_wall.next_upgrade = "Schall-concrete-wall"
	end
	if stone_gate then
		if stone_gate.fast_replaceable_group ~= FRG[stone_gate.name] then
			stone_gate.fast_replaceable_group = FRG[stone_gate.name]
		end
	  stone_gate.next_upgrade = "Schall-concrete-gate"
	end
end
