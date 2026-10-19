-- research_evolution_factor считает подсказку «эволюция +X%» в своём data-final-fixes, до zzz,
-- SpaceModFeorasFork, extendedangels и др., которые потом меняют цену технологий.
-- Здесь подсказка пересчитывается по итоговой цене функцией мода (одно правило с control.lua),
-- получает иконку (иначе игра рисует дефолтный красный "+") и ставится после остальных эффектов.
-- Зависит от research_evolution_factor (см. info.json: "? research_evolution_factor").
if not mods["research_evolution_factor"] then
    return
end

require("__research_evolution_factor__/evolution-label").relabel_all({
    icon = "__zzzparanoidal__/graphics/research-evolution-icon.png",
    icon_size = 64,
    use_icon_overlay_constant = false,
})
