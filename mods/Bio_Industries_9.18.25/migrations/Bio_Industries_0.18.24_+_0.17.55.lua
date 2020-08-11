local BioInd = require('__Bio_Industries__/common')('Bio_Industries')
------------------------------------------------------------------------------------
-- This version uses a different algorithm to wiring the powered rails. Only
-- Rail-to-power connectors and poles on rails connected to (not crossing!) a newly
-- placed track will be connected with each other.
------------------------------------------------------------------------------------

BioInd.writeDebug("Entered migration script 0.18.24+0.17.55")

-- Look for Rail-to-power connectors on all surfaces
for s, surface in pairs(game.surfaces) do
  local connectors = surface.find_entities_filtered{name = "bi-power-to-rail-pole"}
  for _, connector in ipairs(connectors) do
    -- Find connections to powered rails
    local neighbours = connector.neighbours["copper"]
BioInd.writeDebug("neighbours of connector " .. connector.unit_number .. ": " .. serpent.block(neighbours))
    for p, pole in pairs(neighbours) do
      -- Disconnect hidden power-rail poles from connector
      if pole.name == "bi-rail-hidden-power-pole" then
        connector.disconnect_neighbour(pole)
BioInd.writeDebug("Disconnected " .. pole.name .. " " .. pole.unit_number)
      end
    end
  end
end

-- Disconnect all hidden rail poles
for r, rail in pairs(global.bi_power_rail_table) do
  rail.pole.disconnect_neighbour()
BioInd.writeDebug("Disconnected pole number " .. rail.pole.unit_number)
end

-- Rewire hidden rail poles
for r, rail in pairs(global.bi_power_rail_table) do
BioInd.writeDebug("Disconnected pole number " .. rail.pole.unit_number)
  local rail_track = rail.base
  local rail_pole = rail.pole
  -- Look for connecting rails at front and back of the new rail
  for s, side in ipairs( {"front", "back"} ) do
BioInd.writeDebug("Looking for rails at " .. side)
    local neighbour
    -- Look in all three directions
    for d, direction in ipairs( {"left", "straight", "right"} ) do
BioInd.writeDebug("Looking for rails in " .. direction .. " direction")
      neighbour = rail_track.get_connected_rail{
        rail_direction = defines.rail_direction[side],
        rail_connection_direction = defines.rail_connection_direction[direction]
      }
BioInd.writeDebug("Rail " .. direction .. " of " ..
                  rail_track.name .. " (" .. rail_track.unit_number .. "): " ..
                  serpent.line(neighbour and neighbour.name) ..
                  " (" .. serpent.line(neighbour and neighbour.unit_number) ..")")

      -- Only make a connection if found rail is a powered rail
      -- (We'll know it's the right type if we find it in our table!)
      neighbour = neighbour and neighbour.valid and global.bi_power_rail_table[neighbour.unit_number]
      if neighbour then
        rail_pole.connect_neighbour(neighbour.pole)
BioInd.writeDebug("Connected poles!")
      end
    end

    -- Look for Power-rail connectors
    local connector = rail_track.surface.find_entities_filtered{
      position = rail_track.position,
      radius = BioInd.POWER_TO_RAIL_WIRE_DISTANCE,    -- maximum_wire_distance of Power-to-rail-connectors
      name = "bi-power-to-rail-pole"
    }

    -- Connect to first Power-rail connector we've found
    if connector and table_size(connector) > 0 then
        rail_pole.connect_neighbour(connector[1])
BioInd.writeDebug("Connected " .. rail_pole.name .. " (" .. rail_pole.unit_number ..
                  ") to " .. connector[1].name .. " (" .. connector[1].unit_number .. ")")
    end
  end
end

BioInd.writeDebug("End of migration script 0.18.24+0.17.55")
