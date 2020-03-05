-------------------------------------------------------------------------------
--[[Pipe Cleaner]] --
-------------------------------------------------------------------------------
--Loosley based on pipe manager by KeyboardHack
local Event = require('__stdlib__/stdlib/event/event')
local table = require('__stdlib__/stdlib/utils/table')

--Start at a drain and clear fluidboxes out that match. find drain connections not cleaned and repeat
local function call_a_plumber(event)
    local plumber = game.players[event.player_index]
    local clean = event.input_name == 'picker-pipe-cleaner'
    local filter = event.input_name == 'picker-filter-cleaner'
    if plumber.admin or not settings.global['picker-tool-admin-only'].value then
        local toilet = plumber.selected
        if toilet then
            local ptrap = toilet.fluidbox
            local clog = ptrap and #ptrap > 0 and ptrap[1] and ptrap[1].name
            if clog or filter then
                local toilets = {}
                local rootered = {}
                local amount = 0
                local function rooter_it(v)
                    if not rootered[v.owner.unit_number] then
                        toilets[v.owner.unit_number] = v
                    end
                end
                toilets[toilet.unit_number] = ptrap
                repeat
                    local index, drain = next(toilets)
                    if index then
                        rootered[index] = drain
                        for i = 1, #drain do
                            if clean then
                                if drain[i] and drain[i].name and drain[i].name == clog then
                                    amount = amount + drain[i].amount
                                    drain[i] = nil
                                    table.each(drain.get_connections(i), rooter_it)
                                end
                            else
                                drain.set_filter(i, nil)
                                table.each(drain.get_connections(i), rooter_it)
                            end
                        end

                        toilets[index] = nil
                        drain.owner.last_user = plumber
                    end
                until not index
                if clean then
                    plumber.print({'pipe-cleaner.cleaning-clogs', amount, game.fluid_prototypes[clog].localised_name})
                else
                    plumber.print({'pipe-cleaner.remove-all-filters'})
                end
            else
                plumber.print({'pipe-cleaner.no-clogs-found'})
            end
        end
    else
        plumber.print({'picker.must-be-admin'})
    end
end
Event.register({'picker-pipe-cleaner', 'picker-filter-cleaner'}, call_a_plumber)
