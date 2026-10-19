--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

-- Enable new leeching-mechanic for self-fueling of burner inserters:
for name, proto in pairs(data.raw["inserter"]) do
    proto.allow_burner_leech = true
end
