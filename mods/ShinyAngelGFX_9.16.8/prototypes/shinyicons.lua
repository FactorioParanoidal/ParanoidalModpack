-- modded for reskins-bobs mod
function iconset(name,suf,tier)

if settings.startup["usecoloricons"].value == true then
	if settings.startup["usecolorbars"].value == true then
	data.raw["item"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["item"][name..suf].icon_size = 32
	data.raw["item"][name..suf].icon_mipmaps = 1
	-- data.raw["recipe"][name..suf].icons = {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		-- },
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		-- }
	-- }
	data.raw["assembling-machine"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["assembling-machine"][name..suf].icon_size = 32
	data.raw["assembling-machine"][name..suf].icon_mipmaps = 1
	else
	data.raw["item"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		}
	}
	data.raw["item"][name..suf].icon_size = 32
	data.raw["item"][name..suf].icon_mipmaps = 1
	-- data.raw["recipe"][name..suf].icons = {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		-- }
	-- }
	data.raw["assembling-machine"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		}
	}
	data.raw["assembling-machine"][name..suf].icon_size = 32
	data.raw["assembling-machine"][name..suf].icon_mipmaps = 1
	end
else
if settings.startup["usecolorbars"].value == true then
	data.raw["item"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["item"][name..suf].icon_size = 32
	data.raw["item"][name..suf].icon_mipmaps = 1
	-- data.raw["recipe"][name..suf].icons = {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/"..name..".png",
		-- },
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		-- }
	-- }
	data.raw["assembling-machine"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["assembling-machine"][name..suf].icon_size = 32
	data.raw["assembling-machine"][name..suf].icon_mipmaps = 1
else

end
end	
end

function iconsetspec(name,suf,tier)

if settings.startup["usecoloricons"].value == true then
	if settings.startup["usecolorbars"].value == true then
	data.raw["item"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["item"][name..suf].icon_size = 32
	data.raw["item"][name..suf].icon_mipmaps = 1
	-- data.raw["recipe"][name..suf].icons = {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		-- },
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		-- }
	-- }
	data.raw["assembling-machine"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["assembling-machine"][name..suf].icon_size = 32
	data.raw["assembling-machine"][name..suf].icon_mipmaps = 1
	else
	data.raw["item"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		}
	}
	data.raw["item"][name..suf].icon_size = 32
	data.raw["item"][name..suf].icon_mipmaps = 1
	-- data.raw["recipe"][name..suf].icons = {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		-- }
	-- }
	data.raw["assembling-machine"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		}
	}
	data.raw["assembling-machine"][name..suf].icon_size = 32
	data.raw["assembling-machine"][name..suf].icon_mipmaps = 1
	end
else
if settings.startup["usecolorbars"].value == true then
	data.raw["item"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["item"][name..suf].icon_size = 32
	data.raw["item"][name..suf].icon_mipmaps = 1
	-- data.raw["recipe"][name..suf].icons = {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		-- },
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		-- }
	-- }
	data.raw["assembling-machine"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["assembling-machine"][name..suf].icon_size = 32
	data.raw["assembling-machine"][name..suf].icon_mipmaps = 1
	else
	data.raw["item"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		}
	}
	data.raw["item"][name..suf].icon_size = 32
	data.raw["item"][name..suf].icon_mipmaps = 1
	-- data.raw["recipe"][name..suf].icons = {
		-- {
			-- icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		-- }
	-- }
	data.raw["assembling-machine"][name..suf].icons = {
		{
			icon = "__ShinyAngelGFX__/graphics/icons/"..name..tier..".png",
		}
	}
	data.raw["assembling-machine"][name..suf].icon_size = 32
	data.raw["assembling-machine"][name..suf].icon_mipmaps = 1
	end

end
end