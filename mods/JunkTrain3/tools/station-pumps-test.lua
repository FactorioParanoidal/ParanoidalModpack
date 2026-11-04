-- Native fixture for a temporary QA mod (dependencies: base, JunkTrain3).
-- Run on a COPY of a save with --test-arg station --test-ticks 3500.
-- For persistence, run the same fixture on a private no-client server, then
-- load saves/mk0-station-pumps-lifecycle.zip with --test-arg station-reload --test-ticks 400.
-- The fixture reports fluid deltas; pumped_last_tick may remain stale on disabled pumps.
local rigs={}
local specs={
 {"vertical-left-fill","v","left","fill"},{"vertical-right-fill","v","right","fill"},
 {"horizontal-top-fill","h","top","fill"},{"horizontal-bottom-fill","h","bottom","fill"},
 {"vertical-left-drain","v","left","drain"},{"vertical-right-drain","v","right","drain"},
 {"horizontal-top-drain","h","top","drain"},{"horizontal-bottom-drain","h","bottom","drain"},
}
local function check(label, ok, actual)
 storage.qa_checks=storage.qa_checks or {}
 storage.qa_checks[#storage.qa_checks+1]={name=label,passed=ok,actual=actual}
 helpers.write_file("station-pumps-checkpoint.json",helpers.table_to_json(storage.qa_checks),false)
end
local function finish()
 local pass=true
 for _,c in ipairs(storage.qa_checks) do if not c.passed then pass=false end end
 local out={passed=pass,checks=storage.qa_checks}
 helpers.write_file("station-pumps-lifecycle.json",helpers.table_to_json(out),false)
 log("STATION_LIFECYCLE "..helpers.table_to_json(out))
 if script.test_arg then script.finish_test(pass) else storage.qa_finished=true;game.server_save("mk0-station-pumps-lifecycle") end
end
local function ground(p, tank)
 local result={}
 for _,c in pairs(p.get_fluid_box_pipe_connections(1)) do
  local pos=c.target_position
  if tank then
   local dx,dy=c.position.x-pos.x,c.position.y-pos.y
   local cx,cy=dx>0.5 and 1 or -1,dy>0.5 and 1 or -1
   if math.abs(dx)>math.abs(dy) then cy=cx else cx=cy end
   pos={pos.x-cx,pos.y-cy}
  end
  local q=assert(p.surface.create_entity{name=tank and "storage-tank" or "infinity-pipe",position=pos,force="player",raise_built=true})
  if tank then
   if c.flow_direction=="input" then q.set_fluid(1,{name="water",amount=25000}) end
  else
   q.set_infinity_pipe_filter{name="water",percentage=c.flow_direction=="input" and 1 or 0,mode=c.flow_direction=="input" and "at-least" or "at-most"}
  end
  result[#result+1]=q
 end
 return result
end
local function blueprint_pump(p)
 local pos,dir,s=p.position,p.direction,p.surface;p.destroy()
 local inv=game.create_inventory(1);local stack=inv[1];stack.set_stack{name="blueprint"}
 local offset=(dir==0 or dir==8) and {x=0.5,y=0} or {x=0,y=0.5}
 stack.set_blueprint_entities({{entity_number=1,name="scrap-fluid-pump",position=offset,direction=dir}},false)
 local ghosts=stack.build_blueprint{surface=s,force="player",position={pos.x-offset.x,pos.y-offset.y},raise_built=true,skip_fog_of_war=false}
 local revived
 for _,g in pairs(ghosts) do local _,entity=g.revive{raise_revive=true};revived=entity or revived end
 inv.destroy();assert(revived,"Blueprint pump could not revive");revived.destructible=false
 check("blueprint position",revived.position.x==pos.x and revived.position.y==pos.y,{expected=pos,actual=revived.position})
 return revived
end
local function build(e)
 local s=game.surfaces.nauvis
 for i,d in ipairs(specs) do
  local bx=10001+(i-1)*24;local by=10001
  for _,q in pairs(s.find_entities_filtered{area={{bx-10,by-16},{bx+10,by+16}}}) do if q.type~="character" then q.destroy() end end
  local tiles={};for x=bx-10,bx+10 do for y=by-16,by+16 do tiles[#tiles+1]={name="landfill",position={x,y}} end end;s.set_tiles(tiles)
  if d[2]=="v" then
   for y=by-16,by+16,2 do s.create_entity{name="straight-rail",position={bx-1,y},direction=defines.direction.north,force="player"} end
  else
   for x=bx-16,bx+16,2 do s.create_entity{name="straight-rail",position={x,by-1},direction=defines.direction.east,force="player"} end
  end
  local w=assert(s.create_entity{name="yir_us_fluid",position={bx,by},direction=d[2]=="v" and defines.direction.north or defines.direction.east,force="player"})
  local pos,dir
  if d[3]=="left" then pos={bx-2,by-0.5};dir=defines.direction.east
  elseif d[3]=="right" then pos={bx+2,by-0.5};dir=defines.direction.west
  elseif d[3]=="top" then pos={bx-0.5,by-2};dir=defines.direction.south
  else pos={bx-0.5,by+2};dir=defines.direction.north end
  if d[4]=="drain" then dir=(dir+8)%16 end
  local p=assert(s.create_entity{name="scrap-fluid-pump",raise_built=true,position=pos,direction=dir,force="player"})
  local flow=d[4]=="fill" and "input" or "output";local pipe
  for _,conn in pairs(p.get_fluid_box_pipe_connections(1)) do if conn.flow_direction==flow then pipe=s.create_entity{name="infinity-pipe",position=conn.target_position,force="player"} end end
  assert(pipe,d[1].." missing pipe")
  pipe.set_infinity_pipe_filter{name="water",percentage=d[4]=="fill" and 1 or 0,mode=d[4]=="fill" and "at-least" or "at-most"}
  local initial=d[4]=="fill" and w.get_fluid_count("water") or w.set_fluid(1,{name="water",amount=5000})
  local target=d[4]=="fill" and p.pump_output_rail_targets or p.pump_input_rail_targets
  rigs[#rigs+1]={name=d[1],axis=d[2],side=d[3],mode=d[4],wagon=w,pump=p,pipe=pipe,wagon_position=w.position,pump_position=p.position,rail_targets=#target,initial=initial}
 end

 for i=0,7 do
  for _,tank in ipairs({false,true}) do
   local p=assert(s.create_entity{name="scrap-fluid-pump",raise_built=true,position={10002+i*24,tank and 10050 or 10024},direction=i*2,force="player"})
   local fixtures=ground(p,tank)
   local connected=0;for _,c in pairs(p.get_fluid_box_pipe_connections(1)) do if c.target then connected=connected+1 end end
   check((tank and "tank" or "pipe").." connections "..i*2,connected==2,connected)
   rigs[#rigs+1]={name=(tank and "tank-direction-" or "pipe-direction-")..i*2,pump=p,pipes=fixtures,tank=tank,blocked=true,total=0}
  end
 end
 for _,entity in pairs(s.find_entities_filtered{area={{9980,9960},{10240,10070}}}) do entity.destructible=false end
 storage.qa_rigs=rigs;storage.qa_start=e.tick
end
script.on_nth_tick(1,function(e)
 if storage.qa_finished and not script.test_arg then return end
 if script.test_arg=="station-clone" then
  if not storage.clone_rig then
   local source=storage.qa_rigs[1].pump;local surface=source.surface
   check("clone source enabled",not source.disabled_by_script,source.disabled_by_script)
   local pos={source.position.x+240,source.position.y+80}
   surface.request_to_generate_chunks(pos,1);surface.force_generate_chunk_requests()
   for _,entity in pairs(surface.find_entities_filtered{area={{pos[1]-6,pos[2]-6},{pos[1]+6,pos[2]+6}}}) do entity.destroy() end
   local stencil=assert(surface.create_entity{name="pump",position=pos,direction=source.direction,force="player"})
   local tanks=ground(stencil,true);stencil.destroy()
   local before={};for i,tank in ipairs(tanks) do before[i]=tank.get_fluid_count("water");tank.destructible=false end
   local clone=assert(source.clone{position=pos,surface=surface,force="player"});clone.destructible=false
   check("clone immediate restriction",clone.disabled_by_script,clone.disabled_by_script)
   storage.clone_rig={pump=clone,tanks=tanks,before=before,start=e.tick,initial_pump_fluid=clone.get_fluid_count("water")}
  end
  local rig=storage.clone_rig;rig.pump.energy=1000000
  if e.tick-rig.start==100 then
   local before_total,after_total=rig.initial_pump_fluid,rig.pump.get_fluid_count("water")
   for i,tank in ipairs(rig.tanks) do
    local amount=tank.get_fluid_count("water");before_total=before_total+rig.before[i];after_total=after_total+amount
    if rig.before[i]>0 then check("clone pipeline source unchanged",amount==rig.before[i],{before=rig.before[i],after=amount}) end
   end
   check("clone copied buffer accounted",math.abs(before_total-after_total)<0.0001,{before=before_total,after=after_total,copied_buffer=rig.initial_pump_fluid})
   check("clone remains disabled",rig.pump.disabled_by_script);finish()
  end
  return
 end
 if script.test_arg=="station-reload" then
  assert(storage.qa_rigs,"Lifecycle fixture was not saved")
  storage.reload_start=storage.reload_start or e.tick
  for _,r in ipairs(storage.qa_rigs) do r.pump.energy=1000000 end
  local dt=e.tick-storage.reload_start
  if dt==1 then
   for _,r in ipairs(storage.qa_rigs) do
    if r.blocked then r.total=0 elseif r.mode=="fill" then r.wagon.clear_fluid(1) else r.wagon.set_fluid(1,{name="water",amount=5000}) end
   end
  end
  if dt>1 then for _,r in ipairs(storage.qa_rigs) do if r.blocked then r.total=r.total+r.pump.pumped_last_tick end end end
  if dt==300 then
   for _,r in ipairs(storage.qa_rigs) do
    if r.blocked then check("reload "..r.name,r.pump.disabled_by_script and r.total==0,r.total)
    else local amount=r.wagon.get_fluid_count("water");check("reload "..r.name,not r.pump.disabled_by_script and (r.mode=="fill" and amount>0 or r.mode=="drain" and amount<5000),amount) end
   end
   finish()
  end
  return
 end
 if script.test_arg and script.test_arg~="station" then return end
 if not storage.qa_generated then
  if not script.test_arg then game.speed=4 end
  local s=game.surfaces.nauvis;s.request_to_generate_chunks({10100,10000},5);s.force_generate_chunk_requests()
  for _,pl in pairs(game.players) do pl.teleport({10100,10030},s) end
  game.forces.player.chart(s,{{9980,9960},{10240,10070}});storage.qa_generated=e.tick;return
 end
 if e.tick-storage.qa_generated<100 then return end
 if not storage.qa_rigs then build(e) end
 local elapsed=e.tick-storage.qa_start
 for _,r in ipairs(storage.qa_rigs) do
  r.pump.energy=1000000
  if r.blocked then r.total=r.total+r.pump.pumped_last_tick end
  if r.bypass and elapsed>1300 then r.bypass_total=r.bypass_total+r.pump.pumped_last_tick end
 end
 if elapsed==1300 or elapsed==2750 then
  for _,r in ipairs(storage.qa_rigs) do
   if r.blocked then
    local status=r.pump.custom_status
    check("status "..r.name,status and status.label[1]=="junktrain-status.wagon-only",status and status.label)
    check(elapsed.." "..r.name,r.total==0 and r.pump.disabled_by_script,r.total)
   else
    check("active status "..r.name,r.pump.custom_status==nil)
    local amount=r.wagon.get_fluid_count("water")
    check(elapsed.." "..r.name,not r.pump.disabled_by_script and amount==(r.mode=="fill" and 5000 or 0),amount)
   end
  end
 end
 if elapsed==1300 then
  for _,r in ipairs(storage.qa_rigs) do if not r.blocked then
   r.pump.clear_fluids()
   for _,c in pairs(r.pump.get_fluid_box_pipe_connections(1)) do if not c.target then
    r.bypass=assert(r.pump.surface.create_entity{name="pipe",position=c.target_position,force="player",raise_built=true})
    r.bypass_expected=c.flow_direction=="input" and 100 or 0
    if r.bypass_expected>0 then r.bypass.set_fluid_segment_fluid(1,{name="water",amount=r.bypass_expected}) end
   end end
   r.bypass_total=0
  end end
 end
 if elapsed==1400 then
  for _,r in ipairs(storage.qa_rigs) do if not r.blocked then
   local fluid=r.bypass.get_fluid_segment_fluid(1);local amount=fluid and fluid.amount or 0
   check("pipeline beside wagon "..r.name,r.bypass and r.pump.disabled_by_script and amount==r.bypass_expected,{amount=amount,expected=r.bypass_expected,disabled=r.pump.disabled_by_script})
   r.bypass.destroy();r.bypass=nil;r.wagon.train.speed=0.2
  end end
 end
 if elapsed==1420 then
  for _,r in ipairs(storage.qa_rigs) do if not r.blocked then check("wagon departed "..r.name,r.pump.disabled_by_script,{disabled=r.pump.disabled_by_script,last_tick=r.pump.pumped_last_tick});r.wagon.destroy() end end
 end
 if elapsed==1450 then
  for _,r in ipairs(storage.qa_rigs) do if not r.blocked then
   r.wagon=assert(r.pump.surface.create_entity{name="yir_us_fluid",position=r.wagon_position,direction=r.axis=="v" and defines.direction.north or defines.direction.east,force="player",raise_built=true})
   r.wagon.destructible=false
   if r.mode=="drain" then r.wagon.set_fluid(1,{name="water",amount=5000}) end
  end end
 end
 if elapsed==2800 then
  for _,r in ipairs(storage.qa_rigs) do
   if r.blocked then
    for _,q in pairs(r.pipes) do q.destroy() end
    check("rotate "..r.name,r.pump.rotate{by_player=1},r.pump.direction)
    local flipped=r.pump.flip{horizontal=true,by_player=1}
    check("flip restriction "..r.name,r.pump.disabled_by_script,{flipped=flipped,mirroring=r.pump.mirroring})
    r.pipes=ground(r.pump,r.tank)
   end
  end
 end
 if elapsed==2900 then
  for _,r in ipairs(storage.qa_rigs) do
   if r.blocked then check("rotated restriction "..r.name,r.pump.disabled_by_script and r.total==0,r.total) end
   if not r.tank then r.pump=blueprint_pump(r.pump) end
   if not r.blocked then if r.mode=="fill" then r.wagon.clear_fluid(1) else r.wagon.set_fluid(1,{name="water",amount=5000}) end end
  end
 end
 if elapsed==3200 then
  for _,r in ipairs(storage.qa_rigs) do
   if r.blocked then check("blueprint restriction "..r.name,r.pump.disabled_by_script and r.total==0,r.total)
   else local amount=r.wagon.get_fluid_count("water");check("blueprint station "..r.name,not r.pump.disabled_by_script and (r.mode=="fill" and amount>0 or r.mode=="drain" and amount<5000),amount) end
  end
  storage.qa_save_scheduled=true;game.auto_save("mk0-station-pumps")
 end
 if elapsed==3220 then finish() end
end)
