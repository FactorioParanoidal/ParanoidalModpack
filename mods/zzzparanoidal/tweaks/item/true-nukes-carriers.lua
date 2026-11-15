-- Носители paranoidal-true-nukes (ракеты, артснаряды, мины) копируются из прототипов сборки в data-updates
-- мода, до правок data-final-fixes. Правки Beta 8 для исходных носителей переносятся на копии:
-- ускорение ракет и выключенное открытие карты артснарядом (tweaks/item/ammo-stats-1_1), флаги мины из
-- Kao Extended (tweaks/entity/warfare). Множители мода (дальность, перезарядка, стопка) не меняются.
if not mods["paranoidal-true-nukes"] then return end

local function delivery_projectile(ammo)
	local action = ammo.ammo_type and ammo.ammo_type.action
	if action and action[1] then action = action[1] end
	local delivery = action and action.action_delivery
	if delivery and delivery[1] then delivery = delivery[1] end
	return delivery and delivery.projectile
end

local function is_carrier(name, carrier)
	return string.match(name, "^" .. carrier .. "%-atomic%-") or string.match(name, "^" .. carrier .. "%-thermobaric%-")
end

-- Ракеты: прототип мода «atomic-bomb» — ракета 20 т (warheadWeaponNameMap), остальные по имени носителя.
local base_rocket = data.raw.projectile["bob-rocket"] or data.raw.projectile["rocket"]
local base_shell = data.raw["artillery-projectile"]["artillery-projectile"]
for name, ammo in pairs(data.raw.ammo) do
	local projectile_name = delivery_projectile(ammo)
	if base_rocket and (name == "atomic-bomb" or is_carrier(name, "small%-rocket") or is_carrier(name, "big%-rocket")) then
		local projectile = projectile_name and data.raw.projectile[projectile_name]
		if projectile then
			projectile.acceleration = base_rocket.acceleration
		end
	elseif base_shell and is_carrier(name, "artillery%-shell") then
		local projectile = projectile_name and data.raw["artillery-projectile"][projectile_name]
		if projectile then
			projectile.reveal_map = base_shell.reveal_map
		end
	end
end

local base_mine = data.raw["land-mine"]["land-mine"]
if base_mine then
	for name, mine in pairs(data.raw["land-mine"]) do
		if is_carrier(name, "land%-mine") then
			mine.flags = table.deepcopy(base_mine.flags)
		end
	end
end
