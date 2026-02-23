--ANGELS PETROCHEM

data.raw["storage-tank"]["angels-storage-tank-1"].fluid_box.base_area = 1250 --DrD 2000
data.raw["storage-tank"]["angels-storage-tank-2"].fluid_box.base_area = 800 --DrD 1500

if mods["Bio_Industries_2"] and data.raw["tile"]["bi-solar-mat"] then
	data.raw["tile"]["bi-solar-mat"].absorptions_per_second = { pollution = 0.0006 } --Bio-Industries
end
