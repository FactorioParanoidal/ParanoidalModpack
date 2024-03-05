--if data.raw["item"]["bi-woodpulp"] then 
--	data.raw["item"]["wood"].stack_size = 400
--	else
--	data.raw["item"]["wood"].stack_size = 200
--end
if data.raw["item"]["slag"] then
  data.raw["item"]["slag"].stack_size = 400
  data.raw["item"]["stone-crushed"].stack_size = 400
  data.raw["item"]["stone-brick"].stack_size = 400
  data.raw["item"]["iron-gear-wheel"].stack_size = 200
end