-- Beta 8 normal: две ступени кристаллизации и обработка самоцветов.
-- Старые gem-processing I/II соответствуют нынешним II/III по операциям, не по номеру.
-- После OV.execute; категории, машины и внешние модульные технологии не меняются.
if not mods["bobplates"] or not mods["angelsrefining"] then return end
local technologies = data.raw.technology
local first = technologies["angels-geode-crystallization-1"]
local grinding = technologies["bob-grinding"]
local cutting = technologies["bob-gem-processing-2"]
local obsolete = technologies["bob-gem-processing-1"]
if not first or not grinding or not cutting or not obsolete then return end

-- Оформление — существующей технологии Angels 2.0; второе исследование потеряно при объединении.
if not technologies["angels-geode-crystallization-2"] then
	local second = table.deepcopy(first)
	second.name = "angels-geode-crystallization-2"
	second.prerequisites = { "angels-geode-crystallization-1" }
	second.unit = {
		count = 50, time = 30,
		ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
	}
	second.effects = {}
	data:extend({ second })
end

grinding.prerequisites = { "bob-silicon-processing", "steel-processing" }
cutting.prerequisites = { "bob-grinding", "automation-2", "angels-geode-crystallization-2" }

local moves = {}
for _, gem in ipairs({ "ruby", "sapphire", "emerald", "amethyst", "topaz", "diamond" }) do
	moves[#moves + 1] = { "bob-" .. gem .. "-3", "bob-grinding" }
end
for _, index in ipairs({ 2, 5, 6 }) do
	moves[#moves + 1] = { "angels-ore7-crystallization-" .. index, "angels-geode-crystallization-2" }
end
for _, move in ipairs(moves) do
	local recipe, target = move[1], technologies[move[2]]
	if data.raw.recipe[recipe] and target then
		for _, technology in pairs(technologies) do
			if technology.max_level ~= "infinite" then
				for index = #(technology.effects or {}), 1, -1 do
					local effect = technology.effects[index]
					if effect.type == "unlock-recipe" and effect.recipe == recipe then
						table.remove(technology.effects, index)
					end
				end
			end
		end
		target.effects = target.effects or {}
		table.insert(target.effects, { type = "unlock-recipe", recipe = recipe })
	end
end
-- Единственный действующий потребитель прежних ворот — cutting — исправлен выше.
-- Прототип и non-unlock эффекты сохраняем; старые сейвы вне текущего переноса.
obsolete.enabled = false
obsolete.hidden = true
