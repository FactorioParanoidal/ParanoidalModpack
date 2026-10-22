local oresGrade = { "crushed", "chunk", "crystal", "pure" }

function get_grade_set(recipe)
	if recipe then
		local firstIng = recipe.ingredients[2]
		for _,oreGrade in pairs(oresGrade) do
			if firstIng.name:find(oreGrade) then
				return oreGrade
			end
		end
	end
end
function get_ore_ic_size(metal_ore)
	local ic_sz=64
	if data.raw.item[metal_ore].icon_size then
		ic_sz=data.raw.item[metal_ore].icon_size
	elseif data.raw.item[metal_ore].icons and data.raw.item[metal_ore].icons[1].icon_size then
		ic_sz=data.raw.item[metal_ore].icons[1].icon_size
	end
	return ic_sz
end