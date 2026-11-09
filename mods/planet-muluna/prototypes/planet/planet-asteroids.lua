local rro = Muluna.rro
local asteroid_util = require "__space-age__.prototypes.planet.asteroid-spawn-definitions"

local parent_ratio = {3, 2, 1 , 0}
local muluna_ratio = {1,1,1,0}
local muluna_asteroids =
{
  probability_on_range_chunk =
  {
    {position = 0.1, probability = 0.0125, angle_when_stopped = 1},
    {position = 0.9, probability = 0.025, angle_when_stopped = 1}
  },
  -- probability_on_range_medium = 
  -- {
  --   {position = 0.1, probability = 0, angle_when_stopped = asteroid_util.medium_angle},
  --   --{position = 0.5, probability = 0, angle_when_stopped = asteroid_util.medium_angle},
  --   {position = 0.9, probability = 0, angle_when_stopped = asteroid_util.medium_angle}
  -- },
  type_ratios =
  {
    {position = 0.1, ratios = parent_ratio},
    {position = 0.9, ratios = muluna_ratio},
  }
}


local asteroid_spawn_definitions_connection = asteroid_util.spawn_definitions(muluna_asteroids)

local new_asteroids = {}
-- for i = 1,#asteroid_spawn_definitions_connection do
--   if asteroid_spawn_definitions_connection[i].type == "asteroid-chunk" then
--     table.insert(new_asteroids,asteroid_spawn_definitions_connection[i])
--   end
-- end

-- table.remove(asteroid_spawn_definitions_connection,6) --Removes medium asteroids from path
-- table.remove(asteroid_spawn_definitions_connection,5)
-- table.remove(asteroid_spawn_definitions_connection,4)
--table.remove(asteroid_spawn_definitions_connection,2)


data.raw["planet"]["muluna"].asteroid_spawn_definitions = asteroid_util.spawn_definitions(muluna_asteroids,0.9)
data.raw["planet"]["muluna"].asteroid_spawn_influence = 0.1

local anorthite = table.deepcopy(asteroid_spawn_definitions_connection[1])
rro.deep_replace(anorthite,"metallic-asteroid-chunk","anorthite-chunk")
table.insert(asteroid_spawn_definitions_connection,anorthite)

local anorthite = table.deepcopy(data.raw["planet"]["muluna"].asteroid_spawn_definitions[1])
rro.deep_replace(anorthite,"metallic-asteroid-chunk","anorthite-chunk")
table.insert(data.raw["planet"]["muluna"].asteroid_spawn_definitions,anorthite)

if data.raw["space-connection"]["nauvis-muluna"] then
  data.raw["space-connection"]["nauvis-muluna"].asteroid_spawn_definitions= asteroid_spawn_definitions_connection
end
