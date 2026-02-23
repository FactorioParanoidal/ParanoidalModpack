---------------------------------------------------------------------------------------------------
--- Design rules:
--- * Only IonCannonStorage should have direct access to storage.forces_ion_cannon_table
--- * IonCannonStorage must not contain any game logic
---------------------------------------------------------------------------------------------------
if mod.modules.IonCannonStorage then return mod.modules.IonCannonStorage end

---@class IonCannonStorage
IonCannonStorage = {}
mod.modules.IonCannonStorage = IonCannonStorage

---@class IonCannonData
---@field [1] any
---@field [2] integer
---@field [3] string surface name

function IonCannonStorage.initialize()
	if not storage.forces_ion_cannon_table then
		storage.forces_ion_cannon_table = {}
		storage.forces_ion_cannon_table["player"] = {}
	else
		--print("OrbitalIonCannon:OnInit")
		-- MIGRATION: add 3rd columnr "surface"
		for fn,f in pairs(storage.forces_ion_cannon_table) do
			if fn == "Queue" then goto next_force end
			--print("Update cannon force ''"..fn.."'' "..serpent.line(f))
			for i,c in ipairs(f) do
				if #c==2 then
					--"Update cannon #"..tostring(i).." surface to 'nauvis'")
					table.insert(c, "nauvis")
				end
			end
			::next_force::
		end
	end
	storage.forces_ion_cannon_table["Queue"] = storage.forces_ion_cannon_table["Queue"] or {}
	for _, force in pairs(game.forces) do
		storage.forces_ion_cannon_table[force.name] = storage.forces_ion_cannon_table[force.name] or {}
	end
end

---@return IonCannonData[]
---@nodiscard
function IonCannonStorage.getQueue()
	return storage.forces_ion_cannon_table["Queue"] or error("No data for 'Queue'")
end

---@return integer
---@nodiscard
function IonCannonStorage.countQueue()
	return #(storage.forces_ion_cannon_table["Queue"] or {})
end

---@param force string|integer|LuaForce
---@return IonCannonData[]
---@nodiscard
function IonCannonStorage.fromForce(force)
	if type(force) == "number" then force = game.forces[force]
	elseif type(force) ~= "string" then force = force.name end
    return storage.forces_ion_cannon_table[force] or error("No data for force '" .. force.."'")
end

---@param force string|integer|LuaForce
---@return IonCannonData[]
---@nodiscard
function IonCannonStorage.fromForceOrEmpty(force)
	if type(force) == "number" then force = game.forces[force]
	elseif type(force) ~= "string" then force = force.name end
    return storage.forces_ion_cannon_table[force] or {}
end

---@param force string|integer|LuaForce
function IonCannonStorage.newForce(force)
	if type(force) == "number" then force = game.forces[force]
	elseif type(force) ~= "string" then force = force.name end
    storage.forces_ion_cannon_table[force] = {}
end

---@param force string|integer|LuaForce
---@return integer
---@nodiscard
function IonCannonStorage.count(force)
	return #IonCannonStorage.fromForceOrEmpty(force)
end

---@param force string|integer|LuaForce
---@return {[string]: integer} #{[surface name]: count}
function IonCannonStorage.countBySurface(force)
	local t = IonCannonStorage.fromForce(force); if not t then return {} end
	local surfaceCounts = {}
	for _, entry in ipairs(t) do
		local surfaceName = entry[3]
		if not surfaceCounts[surfaceName] then surfaceCounts[surfaceName] = 1
		else surfaceCounts[surfaceName] = surfaceCounts[surfaceName] + 1 end
	end

	return surfaceCounts
end

---@return integer
---@nodiscard
function IonCannonStorage.countAll()
	local count = 0
	for force, cannons in pairs(storage.forces_ion_cannon_table) do
		if force ~= "Queue" then count = count + #cannons end
	end
	return count
end

---@param force integer|string|LuaForce
---@param surface string|LuaSurface
---@return number
---@nodiscard
function IonCannonStorage.countIonCannonsReady(force, surface) -- TODO check all callers
	local surfaceName = nil
	if type(surface) == "string" then surfaceName = surface else surfaceName = surface.name end

	local cannons = IonCannonStorage.fromForce(force)
	if not cannons then return 0 end
	local ionCannonsReady = 0
	for i, cooldown in pairs(cannons) do
		if cooldown[2] == 1 and cooldown[3] == surfaceName then
			ionCannonsReady = ionCannonsReady + 1
		end
	end
	return ionCannonsReady
end

---------------------------------------------------------------------------------------------------
return IonCannonStorage