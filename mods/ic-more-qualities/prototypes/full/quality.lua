-- nahradi puvodni kvality

local color_uncomon = ic.quality_uncommon.color
local color_rare = ic.quality_rare.color
local color_epic = ic.quality_epic.color
local color_legendary = ic.quality_legendary.color

ic.quality_normal.icon = "__ic-more-qualities__/graphics/icons/quality-normal.png"

ic.quality_uncommon.icon = "__ic-more-qualities__/graphics/icons/quality-uncommon-t1.png"

ic.quality_rare.icon = "__ic-more-qualities__/graphics/icons/quality-uncommon-t2.png"
ic.quality_rare.color = color_uncomon

ic.quality_epic.icon = "__ic-more-qualities__/graphics/icons/quality-uncommon-t3.png"
ic.quality_epic.color = color_uncomon

ic.quality_legendary.icon = "__ic-more-qualities__/graphics/icons/quality-uncommon-t4.png"
ic.quality_legendary.level = math.floor(5 * ic.conf.level_multiplier)
ic.quality_legendary.color = color_uncomon
ic.quality_legendary.next = "uncommon-t5"

-- prida nove kvality

data:extend({
  ic.create_quality("uncommon-t5", nil, 6, "q-ae", "rare-t1", 0.65, 0.65, 0.95, color_uncomon),
  -- rare +1
  ic.create_quality("rare-t1", nil, 8, "q-ba", "rare-t2", 0.63, 0.63, 0.94, color_rare),
  ic.create_quality("rare-t2", nil, 9, "q-bb", "rare-t3", 0.61, 0.61, 0.93, color_rare),
  ic.create_quality("rare-t3", nil, 10, "q-bc", "rare-t4", 0.59, 0.59, 0.92, color_rare),
  ic.create_quality("rare-t4", nil, 11, "q-bd", "rare-t5", 0.57, 0.57, 0.91, color_rare),
  ic.create_quality("rare-t5", nil, 12, "q-be", "epic-t1", 0.55, 0.55, 0.90, color_rare),
  -- epic +1
  ic.create_quality("epic-t1", nil, 14, "q-ca", "epic-t2", 0.53, 0.53, 0.89, color_epic),
  ic.create_quality("epic-t2", nil, 15, "q-cb", "epic-t3", 0.51, 0.51, 0.88, color_epic),
  ic.create_quality("epic-t3", nil, 16, "q-cc", "epic-t4", 0.49, 0.49, 0.87, color_epic),
  ic.create_quality("epic-t4", nil, 17, "q-cd", "epic-t5", 0.47, 0.47, 0.86, color_epic),
  ic.create_quality("epic-t5", nil, 18, "q-ce", "legendary-t1", 0.45, 0.45, 0.85, color_epic),
  -- legendary +1
  ic.create_quality("legendary-t1", nil, 20, "q-da", "legendary-t2", 0.43, 0.43, 0.84, color_legendary),
  ic.create_quality("legendary-t2", nil, 21, "q-db", "legendary-t3", 0.41, 0.41, 0.83, color_legendary),
  ic.create_quality("legendary-t3", nil, 22, "q-dc", "legendary-t4", 0.39, 0.39, 0.82, color_legendary),
  ic.create_quality("legendary-t4", nil, 23, "q-dd", "legendary-t5", 0.37, 0.37, 0.81, color_legendary),
  ic.create_quality("legendary-t5", nil, 24, "q-de", "unique-t1", 0.35, 0.35, 0.80, color_legendary),
  -- unique +2
  ic.create_quality("unique-t1", nil, 26, "q-ea", "unique-t2", 0.33, 0.33, 0.79, { 235, 45, 121 }),
  ic.create_quality("unique-t2", nil, 28, "q-eb", "unique-t3", 0.31, 0.31, 0.78, { 235, 45, 121 }),
  ic.create_quality("unique-t3", nil, 30, "q-ec", "unique-t4", 0.29, 0.29, 0.77, { 235, 45, 121 }),
  ic.create_quality("unique-t4", nil, 32, "q-ed", "unique-t5", 0.27, 0.27, 0.76, { 235, 45, 121 }),
  ic.create_quality("unique-t5", nil, 34, "q-ee", "astral-t1", 0.25, 0.25, 0.75, { 235, 45, 121 }),
  -- astral +3
  ic.create_quality("astral-t1", nil, 37, "q-fa", "astral-t2", 0.23, 0.23, 0.74, { 119, 225, 20 }),
  ic.create_quality("astral-t2", nil, 40, "q-fb", "astral-t3", 0.21, 0.21, 0.73, { 20, 119, 225 }),
  ic.create_quality("astral-t3", nil, 43, "q-fc", "astral-t4", 0.19, 0.19, 0.72, { 191, 20, 225 }),
  ic.create_quality("astral-t4", nil, 46, "q-fd", "astral-t5", 0.17, 0.17, 0.71, { 225, 191, 20 }),
  ic.create_quality("astral-t5", nil, 49, "q-fe", "quantum-t1", 0.15, 0.15, 0.70, { 225, 20, 119 }),
  -- quantum +4
  ic.create_quality("quantum-t1", nil, 53, "q-ga", "quantum-t2", 0.13, 0.13, 0.69, { 73, 186, 107 }),
  ic.create_quality("quantum-t2", nil, 57, "q-gb", "quantum-t3", 0.11, 0.11, 0.68, { 73, 167, 186 }),
  ic.create_quality("quantum-t3", nil, 61, "q-gc", "quantum-t4", 0.09, 0.09, 0.67, { 143, 73, 186 }),
  ic.create_quality("quantum-t4", nil, 65, "q-gd", "quantum-t5", 0.07, 0.07, 0.66, { 186, 158, 73 }),
  ic.create_quality("quantum-t5", nil, 69, "q-ge", "infernal-t1", 0.05, 0.05, 0.65, { 186, 73, 120 }),
  -- infernal +8
  ic.create_quality("infernal-t1", nil, 77, "q-ha", "infernal-t2", 0.03, 0.03, 0.60, { 222, 83, 55 }),
  ic.create_quality("infernal-t2", "infernal-t2-v1", 85, "q-hb", "unbreakable", 0.01, 0.01, 0.55, { 222, 35, 35 }),
  -- godly +12
  ic.create_quality("unbreakable", "circle-t1", 97, "q-ia", "godly", 0.005, 0.005, 0.50, { 55, 222, 175 }),
  ic.create_quality("godly", "spiral-t2", 109, "q-ib", "extreme", 0.001, 0.001, 0.45, { 252, 3, 211 }),
  -- extreme +24
  ic.create_quality("extreme", nil, 133, "q-ja", nil, 0.0005, 0.0005, 0.35, { 255, 251, 21 })
})

-- upravi technologie

-- module 1
ic.unlock_quality(ic.quality_module_1, "epic")        -- uncommon-t3
ic.unlock_quality(ic.quality_module_1, "legendary")   -- uncommon-t4
ic.unlock_quality(ic.quality_module_1, "uncommon-t5")
ic.unlock_quality(ic.quality_module_1, "rare-t1")
ic.unlock_quality(ic.quality_module_1, "rare-t2")
ic.unlock_quality(ic.quality_module_1, "rare-t3")
ic.unlock_quality(ic.quality_module_1, "rare-t4")
ic.unlock_quality(ic.quality_module_1, "rare-t5")
-- module 2
ic.unlock_quality(ic.quality_module_2, "epic-t1")
ic.unlock_quality(ic.quality_module_2, "epic-t2")
ic.unlock_quality(ic.quality_module_2, "epic-t3")
ic.unlock_quality(ic.quality_module_2, "epic-t4")
ic.unlock_quality(ic.quality_module_2, "epic-t5")
ic.unlock_quality(ic.quality_module_2, "legendary-t1")
ic.unlock_quality(ic.quality_module_2, "legendary-t2")
ic.unlock_quality(ic.quality_module_2, "legendary-t3")
ic.unlock_quality(ic.quality_module_2, "legendary-t4")
ic.unlock_quality(ic.quality_module_2, "legendary-t5")
ic.unlock_quality(ic.quality_module_2, "unique-t1")
ic.unlock_quality(ic.quality_module_2, "unique-t2")
ic.unlock_quality(ic.quality_module_2, "unique-t3")
ic.unlock_quality(ic.quality_module_2, "unique-t4")
ic.unlock_quality(ic.quality_module_2, "unique-t5")
-- module 3
ic.unlock_quality(ic.quality_module_3, "astral-t1")
ic.unlock_quality(ic.quality_module_3, "astral-t2")
ic.unlock_quality(ic.quality_module_3, "astral-t3")
ic.unlock_quality(ic.quality_module_3, "astral-t4")
ic.unlock_quality(ic.quality_module_3, "astral-t5")
ic.unlock_quality(ic.quality_module_3, "quantum-t1")
ic.unlock_quality(ic.quality_module_3, "quantum-t2")
ic.unlock_quality(ic.quality_module_3, "quantum-t3")
ic.unlock_quality(ic.quality_module_3, "quantum-t4")
ic.unlock_quality(ic.quality_module_3, "quantum-t5")
ic.unlock_quality(ic.quality_module_3, "infernal-t1")
ic.unlock_quality(ic.quality_module_3, "infernal-t2")
ic.unlock_quality(ic.quality_module_3, "unbreakable")
ic.unlock_quality(ic.quality_module_3, "godly")
ic.unlock_quality(ic.quality_module_3, "extreme")
