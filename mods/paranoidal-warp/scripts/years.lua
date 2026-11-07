-- Stage 4 (ПР-077: «Годы Варпа» instead of evolution; BnL bills the Comfort™ field subscription per year, paid in goods
-- from the factory, otherwise the field weakens). Years belong to the force: every jump adds them. A ship with a field
-- generator gets a bill for the years of its jump; its bridge (the hub) pays by itself from its inventory; an overdue
-- bill lowers the field's maximum strength. Chronometer over every bridge, letters from home at milestones.
-- storage.warp_years[force index] = years; storage.warp_letters[force index] = last milestone written;
-- storage.bills[platform index] = {list = {{item, count, years, due, overdue}}, chronometer, line, hub}.
local shared = require("shared")

local M = {}

local GRACE = 15 * 60 * 60 -- a bill is due 15 minutes after the jump
local CAP_STEP = 0.3 -- maximum field strength lost per overdue bill
local CAP_MIN = 0.1
local MILESTONES = {40, 100, 200, 300, 500, 700}
local COLOR_BNL = {r = 1, g = 0.85, b = 0.4}
local COLOR_BAD = {r = 1, g = 0.45, b = 0.4}
local COLOR_CLOCK = {r = 0.75, g = 0.9, b = 1}

local function years_table()
	storage.warp_years = storage.warp_years or {}
	return storage.warp_years
end

local function bills_table()
	storage.bills = storage.bills or {}
	return storage.bills
end

local function account(platform)
	local list = bills_table()
	local account = list[platform.index]
	if not account then
		account = {list = {}}
		list[platform.index] = account
	end
	return account
end

function M.force_years(force)
	return years_table()[force.index] or 0
end

local function item_name(name)
	local prototype = prototypes.item[name]
	return prototype and prototype.localised_name or name
end

local function say(force, key, color, ...)
	force.print({"", "[color=acid]", {"paranoidal-warp.auto"}, "[/color] ", {key, ...}}, {color = color or COLOR_BNL})
end

-- A good for the bill: from the list, its tier reached, the item present and not hidden.
local function pick_good(years)
	local choice = {}
	for _, good in ipairs(shared.bill_goods) do
		local prototype = prototypes.item[good.name]
		if years >= good.from and prototype and not prototype.hidden then choice[#choice + 1] = good end
	end
	if #choice == 0 then return nil end
	return choice[math.random(#choice)]
end

local function letters(force, years)
	local written = storage.warp_letters or {}
	storage.warp_letters = written
	local last = written[force.index] or 0
	for _, milestone in ipairs(MILESTONES) do
		if milestone > last and years >= milestone then
			force.print({"paranoidal-warp.letter-" .. milestone}, {color = COLOR_BNL})
			last = milestone
		end
	end
	written[force.index] = last
end

-- After a successful jump of a platform to target (a gate or home): years for the force, a bill for the ship.
function M.on_jump(platform, target)
	local range = shared.home_years
	local sector = shared.sector_of(target)
	if sector then range = sector.years end
	local added = math.random(range[1], range[2])
	local force = platform.force
	local total = M.force_years(force) + added
	years_table()[force.index] = total
	say(force, "paranoidal-warp.years-jump", COLOR_BNL, platform.name, added, total)
	if platform.surface.count_entities_filtered({name = shared.field, limit = 1}) > 0 then
		local good = pick_good(total)
		if good then
			local count = math.ceil(added * good.per_year)
			table.insert(account(platform).list, {item = good.name, count = count, years = added,
				due = game.tick + GRACE})
			say(force, "paranoidal-warp.bill", COLOR_BNL, platform.name, added, count,
				"[item=" .. good.name .. "]", item_name(good.name), GRACE / 3600)
		end
	end
	letters(force, total)
end

-- Worst quality first (defects by name: ic-defect-5 is the worst; all of them have level 0 like normal).
local function quality_key(name)
	local grade = name:match("^ic%-defect%-(%d+)$")
	if grade then return -tonumber(grade) end
	local quality = prototypes.quality[name]
	return quality and quality.level or 0
end

local function pay(platform, bill)
	local hub = platform.hub
	local inventory = hub and hub.valid and hub.get_inventory(defines.inventory.hub_main)
	if not inventory then return end
	local stacks = {}
	for _, content in pairs(inventory.get_contents()) do
		if content.name == bill.item then stacks[#stacks + 1] = content end
	end
	table.sort(stacks, function(a, b) return quality_key(a.quality) < quality_key(b.quality) end)
	for _, content in ipairs(stacks) do
		if bill.count <= 0 then return end
		local removed = inventory.remove({name = content.name, quality = content.quality,
			count = math.min(content.count, bill.count)})
		bill.count = bill.count - removed
	end
end

local function overdue_count(account_)
	local n = 0
	for _, bill in ipairs(account_.list) do
		if bill.due <= game.tick then n = n + 1 end
	end
	return n
end

-- Maximum field strength of a platform (1 without overdue bills).
function M.cap(platform)
	local account_ = bills_table()[platform.index]
	if not account_ then return 1 end
	local overdue = overdue_count(account_)
	if overdue == 0 then return 1 end
	return math.max(CAP_MIN, 1 - CAP_STEP * overdue)
end

local function destroy(object)
	if object and object.valid then object.destroy() end
end

-- Chronometer and the open bill over the bridge.
local function draw(platform, account_)
	local hub = platform.hub
	local years = M.force_years(platform.force)
	if not (hub and hub.valid) or years <= 0 then
		destroy(account_.chronometer)
		destroy(account_.line)
		account_.chronometer, account_.line = nil, nil
		return
	end
	if account_.hub ~= hub.unit_number then
		destroy(account_.chronometer)
		destroy(account_.line)
		account_.chronometer, account_.line, account_.hub = nil, nil, hub.unit_number
	end
	if not (account_.chronometer and account_.chronometer.valid) then
		account_.chronometer = rendering.draw_text({text = "", surface = platform.surface,
			target = {entity = hub, offset = {0, -5}}, color = COLOR_CLOCK, scale = 1.6, alignment = "center",
			vertical_alignment = "middle", use_rich_text = true})
	end
	account_.chronometer.text = {"paranoidal-warp.chronometer", years}
	local bill = account_.list[1]
	if not bill then
		destroy(account_.line)
		account_.line = nil
		return
	end
	if not (account_.line and account_.line.valid) then
		account_.line = rendering.draw_text({text = "", surface = platform.surface,
			target = {entity = hub, offset = {0, -4}}, color = COLOR_BNL, scale = 1.2, alignment = "center",
			vertical_alignment = "middle", use_rich_text = true})
	end
	local left = bill.due - game.tick
	if left > 0 then
		account_.line.text = {"paranoidal-warp.bill-line", bill.count, "[item=" .. bill.item .. "]",
			math.ceil(left / 3600), #account_.list}
		account_.line.color = COLOR_BNL
	else
		account_.line.text = {"paranoidal-warp.bill-line-overdue", bill.count, "[item=" .. bill.item .. "]",
			math.floor(M.cap(platform) * 100), #account_.list}
		account_.line.color = COLOR_BAD
	end
end

-- Every second, for every platform with a hub (from ship.update).
function M.update(platform)
	local account_ = bills_table()[platform.index]
	if not account_ then
		if M.force_years(platform.force) <= 0 then return end
		account_ = account(platform)
	end
	local force = platform.force
	local before = overdue_count(account_)
	for i = #account_.list, 1, -1 do
		local bill = account_.list[i]
		pay(platform, bill)
		if bill.count <= 0 then
			table.remove(account_.list, i)
			say(force, "paranoidal-warp.bill-paid", COLOR_BNL, platform.name, "[item=" .. bill.item .. "]", bill.years)
		end
	end
	for _, bill in ipairs(account_.list) do
		if bill.due <= game.tick and not bill.overdue then
			bill.overdue = true
			say(force, "paranoidal-warp.bill-overdue", COLOR_BAD, platform.name, bill.count, "[item=" .. bill.item .. "]",
				item_name(bill.item), math.floor(M.cap(platform) * 100))
		end
	end
	if before > 0 and overdue_count(account_) == 0 then
		say(force, "paranoidal-warp.subscription-restored", COLOR_BNL, platform.name)
	end
	draw(platform, account_)
end

-- A platform that no longer exists: its render objects and account go.
function M.forget(index)
	local account_ = bills_table()[index]
	if not account_ then return end
	destroy(account_.chronometer)
	destroy(account_.line)
	bills_table()[index] = nil
end

-- For the drive window: years and the first open bill (localised strings).
function M.window_lines(platform)
	local years = M.force_years(platform.force)
	local account_ = bills_table()[platform.index]
	local bill = account_ and account_.list[1]
	local bill_line
	if bill then
		local left = bill.due - game.tick
		bill_line = left > 0
			and {"paranoidal-warp.bill-line", bill.count, "[item=" .. bill.item .. "]", math.ceil(left / 3600), #account_.list}
			or {"paranoidal-warp.bill-line-overdue", bill.count, "[item=" .. bill.item .. "]", math.floor(M.cap(platform) * 100),
				#account_.list}
	end
	return {"paranoidal-warp.chronometer", years}, bill_line, bill and bill.due <= game.tick
end

-- For automated tests (remote interface).
function M.status(platform)
	local account_ = bills_table()[platform.index]
	local list = {}
	for _, bill in ipairs(account_ and account_.list or {}) do
		list[#list + 1] = {item = bill.item, count = bill.count, years = bill.years, due = bill.due, overdue = bill.overdue}
	end
	return {years = M.force_years(platform.force), bills = list, cap = M.cap(platform),
		letters = storage.warp_letters and storage.warp_letters[platform.force.index] or 0,
		chronometer = account_ and account_.chronometer and account_.chronometer.valid or false,
		line = account_ and account_.line and account_.line.valid or false}
end

-- For automated tests: every open bill of the platform is due now.
function M.expire(platform)
	local account_ = bills_table()[platform.index]
	for _, bill in ipairs(account_ and account_.list or {}) do bill.due = game.tick end
end

return M
