-- Порт Oberhaul scienceoberhaul.lua (1.1): энергия лабов (рецепты пакетов не трогаем).
-- Имена 1.1→2.0: lab-2→bob-lab-2 (lab-module в 2.0 нет). Гарды на наличие.
local lab = data.raw.lab

-- Электрические лабы: только энергопотребление.
if lab["lab"] then lab["lab"].energy_usage = "2500kW" end
if lab["bob-lab-2"] then lab["bob-lab-2"].energy_usage = "5000kW" end
-- big-lab (BigLabFork): 125MW = 1.1-мощность /2 (в 2.0 speed 25 vs 1.1 50).
if lab["big-lab"] then lab["big-lab"].energy_usage = "125MW" end

-- Burner lab (1.1): 1500кВт + effectivity 0.5 + загрязнение 40/м.
local bl = lab["burner-lab"]
if bl then
	bl.energy_usage = "1500kW"
	if bl.energy_source then
		bl.energy_source.effectivity = 0.5
		bl.energy_source.emissions_per_minute = { pollution = 40 }
	end
end
