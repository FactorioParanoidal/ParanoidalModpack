-- nahradi puvodni kvality

ic.quality_normal.icon = "__ic-more-qualities__/graphics/icons/quality-rect-normal.png"

ic.quality_uncommon.icon = "__ic-more-qualities__/graphics/icons/quality-rect-t1.png"
ic.update_quality_name(ic.quality_uncommon, { "default-quality-name.uncommon" })

ic.quality_rare.icon = "__ic-more-qualities__/graphics/icons/quality-rect-t2.png"
ic.update_quality_name(ic.quality_rare, { "default-quality-name.rare" })

ic.quality_epic.icon = "__ic-more-qualities__/graphics/icons/quality-rect-t3.png"
ic.update_quality_name(ic.quality_epic, { "default-quality-name.epic" })

ic.quality_legendary.icon = "__ic-more-qualities__/graphics/icons/quality-rect-t4.png"
ic.quality_legendary.color = { 235, 235, 45 }
ic.quality_legendary.next = "unique"
ic.update_quality_name(ic.quality_legendary, { "default-quality-name.legendary" })

-- prida nove kvality

data:extend({
  ic.create_quality("unique", "rect-t5", 9, "q-ae", "mystic", 0.60, 0.60, 0.93, { 235, 152, 45 }),
  ic.create_quality("mystic", "rect-t6", 13, "q-af", "unbreakable", 0.55, 0.55, 0.90, { 235, 45, 121 }),
  ic.create_quality("unbreakable", "circle-t1", 18, "q-ag", "infernal", 0.50, 0.50, 0.85, { 55, 222, 175 }),
  ic.create_quality("infernal", "infernal-t1", 24, "q-ah", "demonic", 0.45, 0.45, 0.80, { 222, 83, 55 }),
  ic.create_quality("demonic", "infernal-t2-v1", 31, "q-ai", "godly", 0.40, 0.40, 0.75, { 222, 35, 35 }),
  ic.create_quality("godly", "spiral-t2", 39, "q-aj", nil, 0.35, 0.35, 0.70, { 252, 3, 211 })
})

-- upravi technologie

-- module 1
ic.unlock_quality(ic.quality_module_1, "epic")
-- module 2
ic.unlock_quality(ic.quality_module_2, "legendary")
ic.unlock_quality(ic.quality_module_2, "unique")
ic.unlock_quality(ic.quality_module_2, "mystic")
-- module 3
ic.unlock_quality(ic.quality_module_3, "unbreakable")
ic.unlock_quality(ic.quality_module_3, "infernal")
ic.unlock_quality(ic.quality_module_3, "demonic")
ic.unlock_quality(ic.quality_module_3, "godly")
