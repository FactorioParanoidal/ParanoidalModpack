require "common"

function InitLab(force)
    labName = LabName(force)
    if game.surfaces[labName] then
        return
    end

    --game.print "creating lab"

    local surface = game.create_surface(labName, {width = 2*LabRadius*32, height = 2*LabRadius*32})
    --surface.daytime = .5
    surface.always_day = true

    ChunkLab(surface)
    TileLab(surface)
    EquipLab(surface, force)

    --game.print "lab created"
end

function ChunkLab(surface)
    for i = -LabRadius, LabRadius do
        for j = -LabRadius, LabRadius do
            surface.set_chunk_generated_status({i, j}, defines.chunk_generated_status.entities)
        end
    end
end

function TileLab(surface)
    tiles = {}
    for i = -LabRadius*32, LabRadius*32 - 1 do
        for j = -LabRadius*32, LabRadius*32 - 1 do
            if (i + j) % 2 == 0 then
                table.insert(tiles, {name = "lab-dark-1", position = {i, j}})
            else
                table.insert(tiles, {name = "lab-dark-2", position = {i, j}})
            end
        end
    end
    surface.set_tiles(tiles)
end

function EquipLab(surface, force)
    electricInterface = surface.create_entity {name = "electric-energy-interface", position = {0, 0}, force = force}
    electricInterface.minable = true

    infinityChest = surface.create_entity {name = "infinity-chest", position = {0, 1}, force = force}
    infinityChest.minable = true
	
	infinityPipe = surface.create_entity {name = "infinity-pipe", position = {-1, 1}, force = force}
    infinityPipe.minable = true

    mediumPole = surface.create_entity {name = "big-electric-pole", position = {0, -2}, force = force}
    mediumPole.minable = true
end
