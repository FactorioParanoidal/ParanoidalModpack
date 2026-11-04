-- Private QA-mod fixture; pair with a private JunkTrain3 control.lua observer.
-- The observer only reports registry presence; production contains no test interface.
script.on_nth_tick(1,function(e)
 local station=assert(storage.qa_rigs and storage.qa_rigs[1],"Missing saved station fixture")
 local pipeline=storage.qa_rigs[10]
 station.pump.energy=1000000;pipeline.pump.energy=1000000
 if not script.test_arg then
  if storage.registry_saved then return end
  storage.registry_save_start=storage.registry_save_start or e.tick
  if e.tick-storage.registry_save_start==20 then
   assert(not remote.call("mk0-registry-observer","present"),"Legacy fixture unexpectedly has registry")
   storage.registry_saved=true;game.server_save("legacy-missing-registry")
   log("LEGACY_REGISTRY_SAVED version2.0.1 registry absent")
  end
  return
 end
 if script.test_arg~="legacy-registry" then return end
 if not storage.registry_test_start then
  storage.registry_test_start=e.tick;station.wagon.clear_fluid(1)
  local largest=-1
  for _,tank in pairs(pipeline.pipes) do
   local amount=tank.get_fluid_count("water")
   if amount>largest then largest=amount;storage.registry_source=tank end
  end
  storage.registry_source_before=largest
 end
 if e.tick-storage.registry_test_start==200 then
  local amount=station.wagon.get_fluid_count("water")
  local before=storage.registry_source_before;local after=storage.registry_source.get_fluid_count("water")
  local registry=remote.call("mk0-registry-observer","present")
  local registered_station=remote.call("mk0-registry-observer","registered",station.pump.unit_number)
  local registered_pipeline=remote.call("mk0-registry-observer","registered",pipeline.pump.unit_number)
  local pass=registry and registered_station and registered_pipeline and amount>0 and pipeline.pump.disabled_by_script and math.abs(before-after)<0.0001
  local result={passed=pass,registry=registry,registered_station=registered_station,registered_pipeline=registered_pipeline,station_amount=amount,pipeline_disabled=pipeline.pump.disabled_by_script,source_before=before,source_after=after}
  helpers.write_file("station-pumps-registry.json",helpers.table_to_json(result),false)
  log("REGISTRY_REGRESSION "..helpers.table_to_json(result));script.finish_test(pass)
 end
end)
