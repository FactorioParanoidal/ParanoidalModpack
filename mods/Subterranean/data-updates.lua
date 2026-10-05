-- Active Beta 8 compatibility effect. The nitinol pipe no longer exists in Bob 2.0.
-- Do not revive the old green/purple belt guards: neither matched Beta 8 entities.
local distances = {
  ["bob-copper-tungsten-pipe-to-ground"] = 250,
  ["bob-plastic-pipe-to-ground"] = 100,
}
for name, distance in pairs(distances) do
  local pipe = data.raw["pipe-to-ground"][name]
  if pipe then
    for _, connection in pairs(pipe.fluid_box.pipe_connections) do
      if connection.connection_type == "underground" then
        connection.max_underground_distance = distance
      end
    end
  end
end
