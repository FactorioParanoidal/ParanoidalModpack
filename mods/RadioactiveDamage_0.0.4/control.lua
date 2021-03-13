function UraniumDamage()
    for n, p in pairs(game.connected_players) do
        if not p.character then 
        return
        end
            if p.surface.count_entities_filtered{name="uranium-ore", area={{p.position.x-10, p.position.y-10}, {p.position.x+10, p.position.y+10}}} > 1 then
            p.surface.create_entity{name="uranium-damage", target=p.character, source_position=p.character.position, position=p.character.position, duration=5}
			-- p.print("DANGER!! Radiation Damage from Uranium Ore.")
			else
			
                  if p.get_main_inventory().get_item_count("uranium-ore") > 0 then
                  p.surface.create_entity{name="uranium-damage", target=p.character, source_position=p.character.position, position=p.character.position, duration=5}
				  --p.print("DANGER!! Radiation Damage from Uranium Ore in your inventory.")
                  end
				  
			      if p.get_main_inventory().get_item_count("uranium-fuel-cell") > 0 then
                  p.surface.create_entity{name="uranium-damage", target=p.character, source_position=p.character.position, position=p.character.position, duration=5}
				  --p.print("DANGER!! Radiation Damage from Uranium Fuel Cell in your inventory.")
				  end
				  
			      if p.get_main_inventory().get_item_count("used-up-uranium-fuel-cell") > 0 then
                  p.surface.create_entity{name="uranium-damage", target=p.character, source_position=p.character.position, position=p.character.position, duration=5}
				  --p.print("DANGER!! Radiation Damage from Uranium Fuel Cell in your inventory.")
				  end
				  
		          if p.get_main_inventory().get_item_count("uranium-235") > 0 then
                  p.surface.create_entity{name="uranium-damage", target=p.character, source_position=p.character.position, position=p.character.position, duration=5}
				  --p.print("DANGER!! Radiation Damage from Uranium 235 in your inventory.")
                  end
				  
				  if p.get_main_inventory().get_item_count("uranium-238") > 0 then
                  p.surface.create_entity{name="uranium-damage", target=p.character, source_position=p.character.position, position=p.character.position, duration=5}
				  --p.print("DANGER!! Radiation Damage from Uranium 238 in your inventory.")
                  end
            end
       end
end
script.on_nth_tick(10, function() UraniumDamage() end)