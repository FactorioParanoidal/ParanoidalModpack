-- Beta 8 normal: доказанные RCU-потребители, без изменения механик/характеристик.
local patch = {
	-- Beta 8: два этих предка. Extended Angels 2.0 добавил отключённый bob-zinc-processing,
	-- заперев биокристаллы и модуль IV. Сам цинк/модули и прочие поля не меняются.
	["angels-bio-refugium-butchery-2"] = {
		prerequisites = { "angels-bio-refugium-butchery-1", "angels-bio-refugium-hatchery" },
	},

}
for name, fields in pairs(patch) do
	local prototype = data.raw.technology[name]
	if prototype then for field, value in pairs(fields) do prototype[field] = value end end
end
