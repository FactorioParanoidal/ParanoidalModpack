-- nahradi puvodni kvality

ic.quality_normal.icon = "__ic-more-qualities__/graphics/icons/quality-normal.png"

ic.quality_uncommon.icon = "__ic-more-qualities__/graphics/icons/quality-uncommon-t2.png"
ic.update_quality_name(ic.quality_uncommon, { "default-quality-name.uncommon" })

ic.quality_rare.icon = "__ic-more-qualities__/graphics/icons/quality-rare-t3.png"
ic.update_quality_name(ic.quality_rare, { "default-quality-name.rare" })

ic.quality_epic.icon = "__ic-more-qualities__/graphics/icons/quality-epic-t4.png"
ic.update_quality_name(ic.quality_epic, { "default-quality-name.epic" })

ic.quality_legendary.icon = "__ic-more-qualities__/graphics/icons/quality-legendary-t5.png"
ic.quality_legendary.color = { 235, 152, 45 }
ic.quality_legendary.next = "unique"
ic.update_quality_name(ic.quality_legendary, { "default-quality-name.legendary" })

-- prida nove kvality

data:extend({
  ic.create_quality("unique", "unique-t5", 8, "q-ae", "quantum", 0.60, 0.60, 0.93, { 235, 45, 121 }),
  ic.create_quality("quantum", "quantum-t5", 10, "q-af", "infernal", 0.55, 0.55, 0.90, { 55, 222, 175 }),
  ic.create_quality("infernal", "infernal-t1", 13, "q-ag", "demonic", 0.50, 0.50, 0.85, { 222, 83, 55 }),
  ic.create_quality("demonic", "infernal-t2-v1", 16, "q-ah", "godly", 0.45, 0.45, 0.80, { 222, 35, 35 }),
  ic.create_quality("godly", "spiral-t2", 19, "q-ai", nil, 0.40, 0.40, 0.75, { 252, 3, 211 })
})

-- upravi technologie

-- module 1
ic.unlock_quality(ic.quality_module_1, "epic")
-- module 2
ic.unlock_quality(ic.quality_module_2, "legendary")
ic.unlock_quality(ic.quality_module_2, "unique")
ic.unlock_quality(ic.quality_module_2, "quantum")
-- module 3
ic.unlock_quality(ic.quality_module_3, "infernal")
ic.unlock_quality(ic.quality_module_3, "demonic")
ic.unlock_quality(ic.quality_module_3, "godly")
