--[[ Credits:
Darkfrei - https://mods.factorio.com/mod/SmogVisualPollution
Pyro-Fire - https://mods.factorio.com/mod/warptorio2
--]]

--[[
 * 0.1.2 Version comment: Please keep the tabs and spaces between lines, it's easier to read for me. Thank you. / darkfrei
--]]

local function bboxtochunk(v) 
  local ax,ay=v.left_top.x,v.left_top.y
  local bx,by=v.right_bottom.x,v.right_bottom.y
  local x,y=(ax+bx)/2,(ay+by)/2 
  return x/32,y/32 
end

local smog={}

function smog.init() smog.migrate() end

-- end script.on_init(smog.init)
script.on_init(smog.init)

function smog.config(ev) smog.migrate(ev) end

script.on_configuration_changed(smog.config)

function smog.load() end

script.on_load(smog.load)

function smog.migrate() global.smog=global.smog or {} global.smog[1]=global.smog[1] or {} smog.on_surface_created({surface_index=1}) end

function smog.on_chunk_deleted(ev) 
  local t=global.smog[ev.surface_index] 
  if (t) then
    for k,v in pairs(ev.positions) do
      local x,y=v.x,v.y 
      if(t[x] and t[x][y]) then 
        rendering.destroy(t[x][y]) t[x][y]=nil 
      end 
    end 
  end 
end

function smog.pollution_to_color (pollution)
  local mm=settings.global['svp-min-pollution'].value 
  local mx=settings.global['svp-max-pollution'].value
	local v=math.min(pollution,mx) 
  local pct=math.max(0,v-mm)/(mx-mm) -- from 0 to 1
	return {r=pct*0.3,g=pct*0.3,b=pct*0.3,a=pct*0.6} 
end

function smog.on_chunk_generated(ev) 
  local t=global.smog[ev.surface_index] 
  
  if (t) then 
    local surface = game.surfaces[ev.surface_index]
    local x,y=bboxtochunk(ev.area) 
    t[x]=t[x] or {}
    local color = smog.pollution_to_color (surface.get_pollution(ev.area.left_top))
    local rid = rendering.draw_rectangle{color = color, surface=surface,filled=true,visible=true,left_top=ev.area.left_top,right_bottom=ev.area.right_bottom}
    t[x][y] = rid
    
    -- handlers for ticks
    if not global.chunk_handlers then global.chunk_handlers = {} end
    local chunk_handlers = global.chunk_handlers
    table.insert (chunk_handlers, {surface=surface, position = {x=x*32,y=y*32}, rid=rid})
  end 
end

function smog.on_surface_deleted(ev) for x,a in pairs(global.smog[ev.surface_index] or {})do for y,v in pairs(a)do rendering.destroy(v) end end global.smog[ev.surface_index]=nil end

function smog.on_surface_created(ev) 
  if(global.smog[ev.surface_index])then 
    global.smog[ev.surface_index]={}
    local surface = game.surfaces[ev.surface_index]
    if surface then
      -- for chunk in pairs (surface.get_chunks()) do 
      for chunk in surface.get_chunks() do
        smog.on_chunk_generated{surface_index=ev.surface_index,area={left_top={x=chunk.x*32,y=chunk.y*32}, right_bottom={x=chunk.x*32+32,y=chunk.y*32+32}}} 
      end
    end
  end 
end

function smog.tick() -- no arguments in tick
  local chunks_per_tick = settings.global['svp-chunks-per-tick'].value
  local index = global.next_index or 1
  local chunk_handlers = global.chunk_handlers or {}
  if #chunk_handlers>0 then
    local i = index
    while i <= (index + chunks_per_tick) do
      local chunk_handler = chunk_handlers[i]
      if chunk_handler then
        local surface = chunk_handler.surface
        local position = chunk_handler.position
        local rid = chunk_handler.rid -- id of rendering element
        local valid = smog.tick_chunk(surface, position,rid)
        if not valid then
          -- log ('invalid chunk was deleted')
          if i < #chunk_handlers then
            chunk_handlers[i] = chunk_handlers[#chunk_handlers]
          end
          -- delete last one
          chunk_handlers[#chunk_handlers] = nil
        end
      else -- no handler
        global.next_index = 1 
        return
      end
      i=i+1
    end
    global.next_index = index + chunks_per_tick + 1
    return
  end -- return before it
  
  -- then create new handlers
  -- game.print ('SVP: regenerating handlers')
  for k,v in pairs(global.smog)do 
    local surface=game.surfaces[k] 
    if(not surface or not surface.valid)then 
      global.smog[k]=nil 
    else 
      smog.tick_surface(surface) 
    end 
  end 
end

function smog.tick_surface(surface)
  local chunks=global.smog[surface.index] 
  if not global.chunk_handlers then global.chunk_handlers = {} end
  local chunk_handlers = global.chunk_handlers
  if(chunks)then 
    for x,a in pairs(chunks)do 
      for y,rid in pairs(a)do 
        -- smog.tick_chunk(surface,{x=x*32,y=y*32},rid)
        table.insert (chunk_handlers, {surface=surface, position = {x=x*32,y=y*32}, rid=rid})
      end
    end 
  end 
end

function smog.tick_chunk(surface, position,rid)
  if not surface.valid then return false end -- sometimes surfaces are deleted, see https://mods.factorio.com/mod/SmogVisualPollution/discussion/5d4ff40e1d1309000bff3394
  
  local mm=settings.global['svp-min-pollution'].value 
  local mx=settings.global['svp-max-pollution'].value
	local v=math.min(surface.get_pollution(position),mx) 
  local pct=math.max(0,v-mm)/(mx-mm) -- from 0 to 1
	if(pct>0)then
    rendering.set_color(rid, {r=pct*0.3,g=pct*0.3,b=pct*0.3,a=pct*0.6})
    if(not rendering.get_visible(rid))then 
      rendering.set_visible(rid, true) 
    end 
  elseif(rendering.get_visible(rid))then 
    rendering.set_visible(rid, false) 
  end
  return true
end

script.on_event(defines.events.on_chunk_generated, smog.on_chunk_generated)

script.on_event(defines.events.on_chunk_deleted, smog.on_chunk_deleted)

script.on_event(defines.events.on_tick, smog.tick)

function smog.call_whitelist(surface) 
  if(not global.smog[surface.index])then 
    global.smog[surface.index]={} 
    smog.on_surface_created({surface_index=surface.index}) 
  end 
end

function smog.call_blacklist(surface) 
  smog.on_surface_deleted({surface_index=surface.index}) 
  global.smog[surface.index]=false 
end

remote.add_interface("SmogVisualPollution", {
    blacklist=smog.call_blacklist_surface,
    whitelist=smog.call_whitelist_surface,
  })