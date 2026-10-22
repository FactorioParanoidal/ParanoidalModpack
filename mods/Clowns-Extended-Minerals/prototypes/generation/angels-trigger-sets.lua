local temp_triggers = {}
local trigger_tab = {"phosphorus","osmium","magnesium","limestone","sand","calcium-sulfate","sodium-carbonate","uranium","fluorite","platinum"} 
if not special_vanilla then 
  table.insert(trigger_tab,"solid-lithium")
end
if mods["pycoalprocessing"] then
  table.insert(trigger_tab,"raw-borax")
  table.insert(trigger_tab,"nexelit-ore")
  table.insert(trigger_tab,"niobium-ore")
  table.insert(trigger_tab,"rare-earth-dust")
  if mods["pyfusionenergy"] then --at this point it may be wise to force activate angels-overhaul
    table.insert(trigger_tab,"molybdenum-ore") --molybdemum ore
    table.insert(trigger_tab,"regolite-rock") --regolite mine
    table.insert(trigger_tab,"kimberlite-rock") --volcanic-pipe mine
  end
end

clowns.functions.triggers_on = function()
 -- log(serpent.block(angelsmods.trigger.ores))
  for _,trig in pairs(trigger_tab) do
    --check they exist already first
    if angelsmods.trigger.ores[trig] then
      temp_triggers[trig] = table.deepcopy(angelsmods.trigger.ores[trig])
    end
    angelsmods.trigger.ores[trig] = true
  end
 -- log(serpent.block(temp_triggers))
 -- log(serpent.block(angelsmods.trigger.ores))
end

clowns.functions.triggers_off = function()
  for _,trig in pairs(trigger_tab) do
    angelsmods.trigger.ores[trig] = temp_triggers[trig] or nil
  end
 -- log(serpent.block(angelsmods.trigger.ores))
end
