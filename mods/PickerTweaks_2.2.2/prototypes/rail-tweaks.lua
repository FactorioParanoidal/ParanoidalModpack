-- "name": "Shinys-fireproof-signals",
-- "title": "Shinys fireproof signals",
-- "author": "ShinyAfro",
-- "description": "Makes train signals fire-proof",
if settings.startup['picker-fireproof-rail-signals'].value then
    for _, t_name in pairs({'rail-signal', 'rail-chain-signal', 'train-stop'}) do
        for _, t in pairs(data.raw[t_name]) do
            t.resistances = t.resistances or {}
            t.resistances[#t.resistances + 1] = {type = 'fire', percent = 100}
        end
    end
end

-- "name": "fireproof-trains",
-- "title": "Fireproof Trains",
-- "author": "Alnet",
-- "description": "Allow trains to drive through fire without taking damage. Should work with modded train types.",
-- "homepage": "http://mods.factorio.com/mods/alnet/fireproof-trains",
-- "date": "2018-05-18",
if settings.startup['picker-fireproof-rolling-stock'].value then
    local rolling_stock = {
        'locomotive',
        'cargo-wagon',
        'fluid-wagon',
        'artillery-wagon'
    }

    for _, stock in pairs(rolling_stock) do
        for _, entity in pairs(data.raw[stock]) do
            local changed = false
            entity.resistances = entity.resistances or {}
            for _, resistance in pairs(entity.resistances) do
                if resistance.type == 'fire' then
                    resistance.percent = 100
                    changed = true
                    break
                end
            end
            if not changed then
                table.insert(entity.resistances, {type = 'fire', percent = 100})
            end
        end
    end
end
