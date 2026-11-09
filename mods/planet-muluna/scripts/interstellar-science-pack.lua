--- Interstellar science pack
--
-- @module scripts.interstellar-science-pack.lua
-- @pragma nostrip

local Public = {}
local interstellar_pack_name = "interstellar-science-pack"

-- script.on_event(defines.events.on_research_queued,function(event) 
--     local force = event.force
--     if not storage.research_queued then storage.research_queued = {} end --Storage array to track whether a research_queue trigger was triggered by this script or not. Important to avoid recursion
       
--     if storage.research_queued[force.name] == true then storage.research_queued[force.name] = false return end


    
--     game.print(serpent.block(force.research_queue))
--     --local research = force.research_queue[#force.research_queue]
--     local research_queue = table.deepcopy(force.research_queue)
--     local new_research_queue = {}
--     for i,research in ipairs(research_queue) do
--         local research_name = research and type(research) == "string" or research.name

--         if research_name == interstellar_pack_name then
--             force.print({"console.can-not-be-researched-in-lab",research.name})
--             --research_queue[i] = nil
--         else
--             new_research_queue[i] = research
--         end 
--     end
--     storage.research_queued[force.name] = true
--     force.research_queue = new_research_queue
    
    


-- end)

local function pack_is_researched(technologies, pack)
    for _, technology_name in ipairs(pack.technologies or {}) do
        local technology = technologies[technology_name]
        if technology and technology.researched == true then
            return true
        end
    end
    return false
end

--- Checks whether a force meets the conditions to unlock the interstellar science pack.
--- @param force LuaForce
--- @param display_notification boolean
function Public.update_interstellar_pack(force,display_notification)
    if display_notification == nil then display_notification = true end
    --local force = event.research.force
    local technologies = force.technologies
    local data = prototypes.mod_data["muluna-interstellar-science-pack-conditions"].data
    local interstellar_pack_name = data.gated_technology
    local gated_technology = technologies[interstellar_pack_name]
    if not gated_technology then return end
    if gated_technology.researched == true then return end

    local max_count = data.required_science_packs or 0
    if max_count <= 0 then return end

    --local tech = event.research
    
    if gated_technology.researched == false then
        local count = 0
        if data.packs then
            for _, pack in ipairs(data.packs) do
                if pack_is_researched(technologies, pack) then
                    count = count + 1
                end
                if count >= max_count then break end
            end
        else
            -- Compatibility with data written before packs existed.
            for _, pack in pairs(data.science_packs or {}) do
                local technology = technologies[pack]
                if technology and technology.researched == true then
                    count = count + 1
                end
                if count >= max_count then break end
            end
        end
        if count >= max_count then

            if display_notification then
                force.print({"technology-researched","[technology="..interstellar_pack_name.."]"}, {sound_path = "utility/research_completed"})
            end
            
            gated_technology.researched = true

            -- if technologies[interstellar_pack_name].researched == false then
            --     technologies[interstellar_pack_name].saved_progress = 0
            -- end
            
            
            
            
        
        else 
            local progress = gated_technology.saved_progress
            if display_notification and progress < count / max_count then
                force.print({"console.interstellar-science-pack-progress",tostring(count),tostring(max_count),"[technology=".. interstellar_pack_name .. "]"})
            end
            gated_technology.saved_progress = count / max_count
        end
    end


end

---Unlock the gated technology directly, as cheat mode should.
---@param force LuaForce
function Public.set_cheat_mode(force)
    local data = prototypes.mod_data["muluna-interstellar-science-pack-conditions"].data
    local technology = force.technologies[data.gated_technology]
    if technology then
        technology.researched = true
    end
end

script.on_event(defines.events.on_player_cheat_mode_enabled,function(event)

    local player = game.players[event.player_index]
    if player then
        Public.set_cheat_mode(player.force)
    end

end)

if script.active_mods["funit"] then
    Muluna.funit.set_cheat_mode = Public.set_cheat_mode
end




return Public