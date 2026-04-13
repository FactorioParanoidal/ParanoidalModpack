local active_mods
if script then
    active_mods = script.active_mods
else
    active_mods = mods
end
if not active_mods['Krastorio2'] then
    return
end

for technology_name, technology in pairs(data.raw.technology) do
    if technology_name:match('^qol%-') or technology_name:match('^qolinternal%-') then
        technology.check_science_packs_incompatibilities = false
    end
end
