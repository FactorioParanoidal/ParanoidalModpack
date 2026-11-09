if mods["solar-productivity"] then
    table.insert(_G.SP_BLACKLIST,"muluna-satellite-radar") --Solar productivity targets all accumulator prototypes, we want the nav-beacon excluded from these changes.
end