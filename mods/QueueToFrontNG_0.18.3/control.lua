require "globals"


script.on_event
('queue-to-front',
 function(event)
    local plr = game.players[event.player_index]
    if not global.queue_to_front then
       global.queue_to_front = {}
    end
    if not global.queue_to_front[event.player_index] then
       global.queue_to_front[event.player_index] = true
       plr.print({'qtf-message.queue-to-front'})
    else
       global.queue_to_front[event.player_index] = not global.queue_to_front[event.player_index]
       plr.print({'qtf-message.queue-to-back'})
    end
 end
)


script.on_event
(defines.events.on_pre_player_crafted_item,
 function(event)

    -- prevent stack overflow
    if global.busy_queueing then return nil end

    local plr = game.players[event.player_index]
    local save_queue = {}
    local front_craft  = nil
    if not global.queue_to_front then
       global.queue_to_front = {}
    end
    if global.queue_to_front[event.player_index] then

       -- temporarily increase inventory size to prevent dumping
       local old_size = plr.character_inventory_slots_bonus
       plr.character_inventory_slots_bonus = 10*old_size+5000 -- pretty arbitrary expansion but will work 99% of the time
       
       -- remove everything from queue
       local first = true
       while plr.crafting_queue do
	  local ind = plr.crafting_queue[#plr.crafting_queue].index
	  local rec = plr.crafting_queue[#plr.crafting_queue].recipe
	  local cou = plr.crafting_queue[#plr.crafting_queue].count

	  -- errout if queue is too large (we have to do this because the API restricts index to 65535)
	  if ind > 65535 or cou > 65535 then
	     plr.print({'qtf-message.queue-too-large'}, {r = 1, g = .1, b = .1})
	     plr.character_inventory_slots_bonus = old_size
	     return
	  end
       
	  if first then
	     first = false
	     front_craft = {recipe=rec, count=cou}
	  else
	     table.insert(save_queue, {recipe=rec, count=cou})
	  end
	  plr.cancel_crafting({index=ind, count=cou})
       end

       global.busy_queueing = true

       -- add new item
       plr.begin_crafting{count=front_craft.count, recipe=front_craft.recipe, silent=true}

       -- add rest of queue
       for i = #save_queue,1,-1  do
	  v = save_queue[i]
	  plr.begin_crafting{count = v.count, recipe = v.recipe}
       end

       -- revert inventory size
       plr.character_inventory_slots_bonus = old_size

       global.busy_queueing = false
    end

    -- if queue to front not enabled, do nothing

 end
)

