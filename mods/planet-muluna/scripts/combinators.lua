
-- local function price_combinator() 
--     local combinators=game.get_surface("nauvis").find_entities_filtered{name="price-combinator"}
    
--     if combinators then
--         for i,combinator in ipairs(combinators) do
--             --game.print(i)
--             control=combinator.get_control_behavior()
--             control.enabled=true
--             local j=1
--             control.remove_section(1)
--             control.add_section()
--             for key,item in pairs(storage.prices) do
--                 price=item.current
--                 local signal_type = nil
--                 if prototypes.item[key] then
--                     signal_type="item"
--                 end
--                 if prototypes.fluid[key] then
--                     signal_type="fluid"
--                 end
--                 if prototypes.virtual_signal[key] then
--                     signal_type="virtual"
--                 end
                
--                 if signal_type ~=nil then
--                     local signal={type=signal_type,name=key,quality="normal"}
--                     --print(signal,price)
--                     control.get_section(1).set_slot(j,{value=signal,min=price})
--                 end
                
                
--                 j=j+1
--             end
--             price=storage.prices["iron-plate"].current

            
--                 -- for j in 1,combinator.get_control_behavior().sections_count,1 do
--                 -- 	combinator.remove_section(j)
--                 -- end
            
            
--         end
--     end
-- end

-- -- Planet combinator: Outputs a signal that contains every planet. Useful for checking the status of platforms.
-- local function planet_combinator() 
--     for _,surface in pairs(game.surfaces) do
--         local combinators=game.get_surface("nauvis").find_entities_filtered{name="planet-combinator"}
--         if combinators then
--             for i,combinator in ipairs(combinators) do
--                 control=combinator.get_control_behavior()
--                 control.enabled=true
--                 control.remove_section(1)
--                 control.add_section()
--                 local j=1
--                 for key,item in pairs(prototypes.planet) do
--                     local signal_type="space-location"
                    
        
--                     if signal_type ~=nil then
--                         local signal={type=signal_type,name=key,quality="normal"}
--                         --print(signal,price)
--                         control.get_section(1).set_slot(j,{value=signal,min=1})
--                     end
--                     j=j+1
--                 end
--             end
--     end
-- end
--     local combinators=game.get_surface("nauvis").find_entities_filtered{name="planet-combinator"}

--     if combinators then
--         for i,combinator in ipairs(combinators) do
--             --game.print(i)
--             local control=combinator.get_control_behavior()
--             control.enabled=true
--             local j=1
--             control.remove_section(1)
--             control.add_section()
--             for key,item in pairs(prototypes.planet) do

                
                
                
--                 j=j+1
--             end
--             price=storage.prices["iron-plate"].current

            
--                 -- for j in 1,combinator.get_control_behavior().sections_count,1 do
--                 -- 	combinator.remove_section(j)
--                 -- end
            
            
--         end
--     end
-- end