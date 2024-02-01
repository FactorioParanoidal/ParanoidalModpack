for _,f in pairs(game.forces) do 
  f.reset_recipes()
  f.recipes['nixie-tube-alpha'].enabled = f.technologies['cathodes'].researched 
end