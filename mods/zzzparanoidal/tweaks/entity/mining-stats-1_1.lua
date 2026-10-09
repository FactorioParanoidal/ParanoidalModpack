-- Oberhaul 1.1: area drills emitted 10 pollution/min and the player mined at speed 1.
-- Final 1.1 coal prototype: minable.mining_time = 1; override AAI's 0.9.
data.raw.resource.coal.minable.mining_time = 1

for name, entity in pairs(data.raw["mining-drill"] or {}) do
    local base = name:match("^(.-)___") or name
    if base:match("^bob%-area%-mining%-drill%-%d+$") and entity.energy_source then
        entity.energy_source.emissions_per_minute = {pollution = 10}
    end
end

for name, character in pairs(data.raw.character or {}) do
    -- MiniMe's unplayable dummy also had speed 0.5 in the final 1.1 dump.
    if name ~= "minime_character_dummy" then character.mining_speed = 1 end
end
