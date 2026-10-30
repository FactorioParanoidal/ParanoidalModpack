-- Machines this mod must leave alone. Other mods add names from their data-updates stage:
-- appmod.blacklist['entity-name'] = true
local blacklist = appmod.blacklist

-- The settings only cover the vanilla machines; machines of other mods are always processed.
-- A disabled setting adds the names, an enabled one never removes a name another mod has added.
local function skip_when_disabled(setting, names)
  if not settings.startup[setting].value then
    for _, name in ipairs(names) do
      blacklist[name] = true
    end
  end
end

skip_when_disabled('app_assembling_machines', { 'assembling-machine', 'assembling-machine-2', 'assembling-machine-3' })
skip_when_disabled('app_oil_refineries', { 'oil-refinery' })
skip_when_disabled('app_chemical_plants', { 'chemical-plant' })

if mods['bobassembly'] then
  blacklist['bob-steam-assembling-machine'] = true
end

-- Yuoki Industries engines: 1x2 machine with a calculated collision box of 2x2
if mods['Yuoki'] then
  blacklist['y-emotor-s'] = true
end

-- Factorissimo 3, thanks aerospacesmith
if mods['factorissimo-2-notnotmelon'] then
  blacklist['borehole-pump'] = true
end
