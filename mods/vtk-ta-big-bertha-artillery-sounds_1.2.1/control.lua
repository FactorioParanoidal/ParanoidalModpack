
function dist_a_b(PositionA, PositionB)
    return math.sqrt((PositionB.x - PositionA.x)^2+(PositionB.y-PositionA.y)^2) 
end

script.on_event(defines.events.on_trigger_created_entity, function(event)
  local ent = event.entity
  
--  local character = game.characters[1]
--  character.print("VTK-BERTHA-DEBUG")
--  character.print(serpent.block(ent))
--  character.print(serpent.block(ent.name))

  
  if ent.name == "vtk-artillery-at-distance-sound-trigger-shooting" or ent.name == "vtk-artillery-at-distance-sound-trigger-explosion" then
    local dist = 0
    for i, character in pairs(game.connected_characters) do
      dist = dist_a_b(character.position, ent.position)
--  character.print(serpent.block(dist))
      if dist > 20 and dist < 250 then
        if ent.name == "vtk-artillery-at-distance-sound-trigger-shooting" then
          character.surface.play_sound{path = "vtk-artillery-at-distance-sound-shooting-close", position = character.position}
        elseif ent.name == "vtk-artillery-at-distance-sound-trigger-explosion" then
          character.surface.play_sound{path = "vtk-artillery-at-distance-sound-explosion-close", position = character.position}
        end
      elseif dist < 500 then
        if ent.name == "vtk-artillery-at-distance-sound-trigger-shooting" then
          character.surface.play_sound{path = "vtk-artillery-at-distance-sound-shooting-far", position = character.position}
        elseif ent.name == "vtk-artillery-at-distance-sound-trigger-explosion" then
          character.surface.play_sound{path = "vtk-artillery-at-distance-sound-explosion-far", position = character.position}
        end
      elseif dist < 750 then
        if ent.name == "vtk-artillery-at-distance-sound-trigger-shooting" then
          character.surface.play_sound{path = "vtk-artillery-at-distance-sound-shooting-horizon", position = character.position}
        elseif ent.name == "vtk-artillery-at-distance-sound-trigger-explosion" then
          character.surface.play_sound{path = "vtk-artillery-at-distance-sound-explosion-horizon", position = character.position}
        end
      elseif dist < 1000 then
        if ent.name == "vtk-artillery-at-distance-sound-trigger-shooting" then
          character.surface.play_sound{path = "vtk-artillery-at-distance-sound-shooting-horizon++", position = character.position}
        elseif ent.name == "vtk-artillery-at-distance-sound-trigger-explosion" then
          character.surface.play_sound{path = "vtk-artillery-at-distance-sound-explosion-horizon++", position = character.position}
        end
      end
    end
  end
end)
