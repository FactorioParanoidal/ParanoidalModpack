local hyper_inserter_cache = {} --This cache is organized by surface.
local golden_tech_cache = {}
local golden_tech_cache_built = false

local hyper_inserter_cache_built = false
local loaded_level = 1

--First parameter is a string, second is an array of LuaTechnology
---@param input_name string 
local function get_technology_level(input_name,technology_cache)
    local out = 0
    for k,v in pairs(technology_cache) do

        if(v ~= nil and v.name == input_name) then
            --v.level stuck at 1.
            out = v.level
        end    
    end
    return out
end 

--Input_cahce needs to be a lua entity
local function update_hyper_inserters(entity_list)
    local level = 1 --get_technology_level("hyper-inserter-capacity",golden_tech_cache )
    for k,v in pairs(entity_list) do
        --log("v=")
        --log(serpent.block(v))
        if (v ~=nil and v.name == "hyper-inserter") then
            --v.prototype.inserter_stack_size_bonus = 4 + level --4 is the default for inserter bonus size. --Lets see if we can modify this data at runtime.. WE CANNOT
            v.inserter_stack_size_override  =  4 + level --target pick up count is read only... 
        end
    end
end

---@param input_name string 
local function find_all_entity_of_name(input_name)
    local out_entity_table = {}
    local surface_array = game.surfaces
      for k,q in pairs(surface_array) do --names of surfaces are in keys
          local current_surface = game.get_surface(k)
          --pressure-lab
  
          local entity_array = current_surface.find_entities_filtered{name = input_name} --input_name
          if(table_size(entity_array) == 0) then
            out_entity_table[current_surface.name] = {}
            goto continue_loop
          end
          local entity_map = {} --need a map that I can easily find and remove entities from
          for i,e in pairs(entity_array ) do 
            --log("e=")
            --log(serpent.block(e))
            entity_map[e.name..e.gps_tag] = e --Unique ID for each entity.
          end 
          out_entity_table[current_surface.name] = entity_map
          ::continue_loop::
      end
    
    --log(serpent.block(out_entity_table))
  
    
  
    return out_entity_table
end 
  

---@param entity LuaEntity
local function add_to_cache(entity,cache)
    local surface_name = entity.surface.name
    local key = entity.name .. entity.gps_tag
    cache[surface_name][key] = entity
end
  
---@param entity LuaEntity
local function remove_from_cache(entity,cache)
    local surface_name = entity.surface.name
    local key = entity.name .. entity.gps_tag
    cache[surface_name][key] = nil
end



script.on_nth_tick(30,
    function(NthTickEventData)
        if(golden_tech_cache_built == false) then
            golden_tech_cache = prototypes.get_technology_filtered{{filter="research-unit-ingredient",ingredient = "golden-science-pack"}}
            golden_tech_cache_built = true
        end
        if(hyper_inserter_cache_built == false) then
            hyper_inserter_cache = find_all_entity_of_name("hyper-inserter")
            hyper_inserter_cache_built = true
            update_hyper_inserters(hyper_inserter_cache,loaded_level)
        end

    end
)


--Handle cache.
for _, eventType in pairs({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
}) do
	script.on_event(eventType,
		function(event)
			---@cast event EventData.on_built_entity | EventData.on_player_mined_entity | EventData.on_robot_built_entity | EventData.on_robot_mined_entity | EventData.on_entity_died
			local entity = event.entity
			---@cast entity LuaEntity -- Guaranteed to be LuaEntity when read.
			add_to_cache(entity,hyper_inserter_cache)
            update_hyper_inserters({entity})
		end,
		{{ filter = "name", name = "hyper-inserter" }})
end

for _, eventType in pairs({
	defines.events.on_player_mined_entity,
	defines.events.on_robot_mined_entity,
	defines.events.on_entity_died,
}) do
	script.on_event(eventType,
		function(event)
			---@cast event EventData.on_built_entity | EventData.on_player_mined_entity | EventData.on_robot_built_entity | EventData.on_robot_mined_entity | EventData.on_entity_died
			local entity = event.entity
			---@cast entity LuaEntity -- Guaranteed to be LuaEntity when read.
			remove_from_cache(entity,hyper_inserter_cache)
		end,
		{{ filter = "name", name = "hyper-inserter" }})
end


for _, eventType in pairs({
	defines.events.on_research_finished,
}) do
	script.on_event(eventType,
		function(event)
            ---@cast event EventData.on_research_finished
            if(event ~= nil and event.research.name == "hyper-inserter-capacity") then
                golden_tech_cache = prototypes.get_technology_filtered{{filter="research-unit-ingredient",ingredient = "golden-science-pack"}}
                
                for s,inserter_array in pairs(hyper_inserter_cache) do
                    --log("inserter_array=")
                    --log(serpent.block(inserter_array))
                    update_hyper_inserters(inserter_array) --s is the surface.
                end
            end
		end
		)
end

