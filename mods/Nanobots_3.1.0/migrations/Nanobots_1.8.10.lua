--Migrate offset interface-cc's to center position, Nullify orphans

for _, surface in pairs(game.surfaces) do
    for _, interface in pairs(surface.find_entities_filtered{name = "roboport-interface-main"}) do
        for _, cc in pairs(surface.find_entities_filtered{name = "roboport-interface-cc", area = interface.bounding_box, limit = 1}) do
            cc.teleport(interface.position)
            cc.direction = defines.direction.north
        end
        for _, ra in pairs(surface.find_entities_filtered{name = "roboport-interface-radar", area = interface.bounding_box, limit = 1}) do
            ra.teleport(interface.position)
        end
    end
    for _, orphan_cc in pairs(surface.find_entities_filtered{name = "roboport-interface-cc"}) do
        if not surface.find_entities_filtered{name = "roboport-interface-main", position = orphan_cc.position} then
            orphan_cc.destroy()
        end
    end
    for _, orphan_ra in pairs(surface.find_entities_filtered{name = "roboport-interface-radar"}) do
        if not surface.find_entities_filtered{name = "roboport-interface-main", position = orphan_ra.position} then
            orphan_ra.destroy()
        end
    end
end
