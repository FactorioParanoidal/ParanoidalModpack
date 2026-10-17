-- Платиновая руда → проволока → продвинутый процессор → оба открытия платы III.
-- Добавляем связи без замены остальных предков и без отложенной очереди OV.
local tech = paralib.bobmods.lib.tech

tech.add_prerequisite("angels-platinum-smelting-1", "platinum-ore-refining")
tech.add_prerequisite("bob-advanced-processing-unit", "angels-platinum-smelting-1")
