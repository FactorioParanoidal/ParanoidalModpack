require("util.class")
require("util.table")
require("util.help")
require('util.tech')
require("classes.config")

local stat = 10000

function commandHandler(event)
    local parameter = event.parameter
    if parameter ~= nil then
        if parameter == "kills" then
            game.print{"Pollution-kills"}
            if tlen(storage.kills) > 0 then
                for player, kills in pairs(storage.kills) do
                    game.print(player .. " - " .. kills)
                end
            else
                game.print{"Zero-players"}
            end
        end
    end
end

conf = Config()

Toxic = class(function(self)
    self.name = "Toxic Pollution"
    self.inventory = {
        defines.inventory.character_main,
        defines.inventory.character_trash
    }
    self.Signals = {
        ["yellow-gas-mask"] =   {type="virtual", name="signal-yellow-gas-mask"},
        ["red-gas-mask"] =      {type="virtual", name="signal-red-gas-mask"},
        ["red-armor"] =         {type="virtual", name="signal-red-armor"},
        ["yellow-more-toxin"] = {type="virtual", name="signal-yellow-more-toxin"}
    }
    self.multiplier = {
        time = 5 * Minute,
        max = 60
    }
end)

function Toxic:init()
    self:initGlobals()
    if (game) then
        -- 2.0: durability is no longer on LuaItemPrototype. Read max-durability per armor
        -- from the mod-data prototype we built in data-final-fixes.lua.
        local dur_data = prototypes.mod_data["toxicPollution2-armor-durability"]
        storage.armorDurability = (dur_data and dur_data.data) or {}
        for name, durability in pairs(storage.armorDurability) do
            if (storage.MaxDurability < durability) then
                storage.MaxDurability = durability
            end
            local item = prototypes.item[name]
            local toxin = item and item.resistances and item.resistances.toxin
            if toxin then
                storage.armors[name] = {
                    base = conf:AbsorbMultiplier() * math.min(tonumber(string.format("%.2f", toxin.percent)), 0.9),
                    resist = toxin.percent
                }
            else
                storage.armors[name] = {
                    base = 0,
                    resist = 0
                }
            end
            storage.armors[name].current = storage.armors[name].base
        end
        for _, force in pairs(game.forces) do
            storage.TechBonus[force.name] = conf:ForceBaseValue()
            for i = 1, TechLevels do
                local tech = force.technologies[TechName.."-"..i]
                if tech then
                    if tech.researched == true then self:UpdateTech(tech.name, force) end
                end
            end
        end
        self:initForce()
        self:initKillerFish()
        self:initDataPlayers()
    end
end

function Toxic:initGlobals()
    if (storage.MaxDurability == nil) then storage.MaxDurability = 0 end
    if (storage.armors == nil) then storage.armors = {} end
    if (storage.TechBonus == nil) then storage.TechBonus = {} end
    if (storage.PlayersData == nil) then storage.PlayersData = {} end
    if (storage.kills == nil) then
        storage.kills = {}
    else
        if type(storage.kills) == "number" then storage.kills = {} end
    end
end

function Toxic:initForce()
    if not game.forces.pollution then
        game.create_force("pollution")
    end
end

function Toxic:initDataPlayers()
    for _, player in pairs(game.players) do
        self:initDataPlayer(player.name)
    end
end

function Toxic:initDataPlayer(player)
    local data = storage.PlayersData[player]
    if data == nil then
        data = { ticks = 0, multiplier = 0, pollution = 0 }
    else
        if data.ticks == nil then data.ticks = 0 end
        if data.multiplier == nil then data.multiplier = 0 end
        if data.pollution == nil then data.pollution = 0 end
    end
    storage.PlayersData[player] = data
end

function Toxic:initCommands()
    commands.add_command("pollution", "toxic pollution commands", commandHandler)
end

function Toxic:initKillerFish()
    if storage.killer == nil or (storage.killer ~= nil and storage.killer.valid == false) then
        storage.killer = game.surfaces[1].create_entity{name = "pollution", position = {x = 1, y = 1}, force = game.forces.pollution }
        storage.killer.active = false
    end
end

function Toxic:migrate(version)
    local Major, Minor, Patch = string.match(version, "(%d)%.(%d)%.(%d)")
    Major = tonumber(Major)
    Minor = tonumber(Minor)
    Patch = tonumber(Patch)
    if (Major == 0 and Minor >= 2 and Patch >= 7) then
        if (storage.armorMaxDurability ~= nil) then
            storage.armorMaxDurability = nil
        end
        if (storage.armorsAbsorb ~= nil) then
            storage.armorsAbsorb = nil
        end
        if (storage.techAbsorb ~= nil) then
            storage.techAbsorb = nil
        end
    end
end

function Toxic:AddAlert(player, signal, message)
    if player.character then
        local alerts = player.get_alerts{entity = player.character, type = defines.alert_type.custom, surface = player.surface }
        for _, alert in pairs(alerts) do
            if alert.icon == self.Signals[signal] then
                return
            end
        end
        player.add_custom_alert(player.character, self.Signals[signal], message, false)
    end
end

function Toxic:RemoveAlert(player, signal)
    if player.character then
        player.remove_alert{entity = player.character, surface = player.surface, icon = self.Signals[signal] }
    end
end

function Toxic:GetPollution(player)
    return math.floor(player.surface.get_pollution({player.position.x, player.position.y}))
end

function Toxic:GetPlayerArmor(player)
    local inv = player.get_inventory(defines.inventory.character_armor)
    if not inv then return 0, nil end
    local count = inv.get_item_count()
    if count > 0 then
        return count, inv[1]
    else
        return count, nil
    end
end

function Toxic:GetArmorAbsorb(armor)
    local a = storage.armors[armor]
    if a ~= nil then
        return a.current
    end
    return 0
end

function Toxic:UpdateTech(tech, force)
    local n = string.match(tech, "armor%-absorb%-(%d+)")
    if n ~= nil then
        local bonus = conf:ForceBaseValue() + tonumber(n) * conf:TechBonus()
        storage.TechBonus[force.name] = bonus
        self:ReCalculateAbsorb(force.name)
        return true
    else
        return false
    end
end

function Toxic:ReCalculateAbsorb(force)
    for _, armor in pairs(storage.armors) do
        armor.current = armor.base * storage.TechBonus[force]
    end
end

function Toxic:IncKills(player)
    local kills = storage.kills[player] or 0
    kills = kills + 1
    storage.kills[player] = kills
end

function Toxic:CalculateDamage(player, pollution, armor)
    local m = self:GetTimeMultiplier(player)
    local damage = 0
    if armor ~= nil then
        damage = pollution/stat
        damage = (damage - damage * storage.armors[armor.name].resist) * m
    else
        damage = pollution/conf:MinPollution() * m
    end
    return damage
end

function Toxic:IsActiveAirFiltering()
    return script.active_mods["air-filtering-patched"] ~= nil
end

function Toxic:EquipArmorFromInventory(player, armor)
    if (armor.is_armor == false and conf:IsAutoEquip(player)) then
        local durability = storage.MaxDurability
        local newArmor = {id = 0, index = 0 }
        for id, inventoryType in pairs(self.inventory) do
            local inventory = player.get_inventory(inventoryType)
            if inventory ~= nil then
                for i = 1, #inventory do
                    local item = inventory[i]
                    if (item.is_armor and item.durability <= durability) then
                        durability = item.durability
                        newArmor = {id = id, index = i }
                    end
                end
            end
        end
        if newArmor.id > 0 then
            armor.transfer_stack(player.get_inventory(self.inventory[newArmor.id])[newArmor.index])
        end
        if armor.is_armor then
            player.print{"Destroyed-armor-replaced", {"item-name." .. armor.name} }
        else
            player.print{"Armor-destroyed" }
        end
    end
end

function Toxic:IncTimeMultiplier(player, ticks)
    local data = storage.PlayersData[player]
    if data == nil then return end
    if data.ticks < self.multiplier.time then
        data.ticks = data.ticks + ticks
        data = self:UpdateTimeMultiplier(data)
    end
    storage.PlayersData[player] = data
end

function Toxic:DecTimeMultiplier(player, ticks)
    local data = storage.PlayersData[player]
    if data ~= nil then
        data.ticks = data.ticks - ticks
        if data.ticks < 0 then data.ticks = 0 end
        data = self:UpdateTimeMultiplier(data)
        storage.PlayersData[player] = data
    end
end

function Toxic:GetTimeMultiplier(player)
    local data = storage.PlayersData[player]
    if data ~= nil then
        return data.multiplier
    end
    return 0
end

function Toxic:UpdateTimeMultiplier(data)
    local m = data.ticks / self.multiplier.time
    m = self.multiplier.max * m
    if m % 1 == 0 then data.multiplier = m end
    return data
end

function Toxic:ClearTimeMultiplier(player)
    local data = storage.PlayersData[player]
    if data == nil then return end
    data.multiplier = 0
    data.pollution = 0
    data.ticks = 0
    storage.PlayersData[player] = data
end

function Toxic:DamageForPlayer(player)
    -- Defensive: storage.PlayersData[name] may be missing if init handlers didn't
    -- fire reliably (e.g. mod added mid-game without `on_configuration_changed`,
    -- or `on_player_joined_game` skipped). Lazy-init here so OnTick can't crash.
    storage.PlayersData = storage.PlayersData or {}
    if storage.PlayersData[player.name] == nil then
        self:initDataPlayer(player.name)
    end
    local alert = 0
    local pollution = self:GetPollution(player)
    local newPollution = 0
    local damage = 0
    local absorb = conf:MinPollution()
    local armorCount, armor = self:GetPlayerArmor(player)
    local data = storage.PlayersData[player.name]

    if armorCount > 0 then absorb = absorb + self:GetArmorAbsorb(armor.name) end
    if (pollution > absorb) then
        newPollution = pollution - absorb
    end
    if newPollution > 0 then
        self:IncTimeMultiplier(player.name, conf:TickInterval())
        data.pollution = newPollution
        damage = self:CalculateDamage(player.name, newPollution, armor)
        if damage > 20 then
            alert = 2
        else
            alert = 1
        end
    else
        self:DecTimeMultiplier(player.name, conf:TickInterval())
        damage = self:CalculateDamage(player.name, data.pollution, armor)
        if damage > 0 and alert == 0 then
            alert = 4
        end
    end
    if damage > 0 then
        if armor then
            local max_dur = storage.armorDurability[armor.name] or 1
            if (armor.durability / max_dur < 0.25 and armorCount == 1) then
                alert = 3
            end
            armor.drain_durability(damage)
            self:EquipArmorFromInventory(player, armor)
        else
            if (player.character.health > damage) then
                player.character.damage(damage, game.forces.pollution, "toxin")
            else
                self:initKillerFish()
                player.character.die(game.forces.pollution, storage.killer)
            end
        end
    end
    if alert == 1 then
        self:AddAlert(player, "yellow-gas-mask", {"High-pollution", pollution, string.format("%.2f", damage), data.multiplier})
    elseif alert == 2 then
        self:AddAlert(player, "red-gas-mask", {"Very-high-pollution", pollution, string.format("%.2f", damage), data.multiplier})
    elseif alert == 3 then
        self:AddAlert(player, "red-armor", {"Armor-worn-out", pollution, string.format("%.2f", damage), data.multiplier})
    elseif alert == 4 then
        self:AddAlert(player, "yellow-more-toxin", {"Accumulated-toxins", string.format("%.2f", damage), data.multiplier})
    else
        self:RemoveAlert(player, "yellow-gas-mask")
        self:RemoveAlert(player, "red-gas-mask")
        self:RemoveAlert(player, "red-armor")
    end
end

function Toxic:OnTick()
    for _, player in pairs(game.players) do
        if (player.connected == true and player.character ~= nil) then
            self:DamageForPlayer(player)
            --local alert = 0
            --local pollution = self:GetPollution(player)
            --local newPollution = 0
            --local absorb = conf:MinPollution()
            --local armorCount, armor = self:GetPlayerArmor(player)
            --if armorCount > 0 then absorb = absorb + self:GetArmorAbsorb(armor.name) end
            --if (pollution > absorb) then
            --    newPollution = pollution - absorb
            --end
            --if (newPollution > 0) then
            --    self:IncTimeMultiplier(player.name, conf:TickInterval())
            --else
            --    self:DecTimeMultiplier(player.name, conf:TickInterval())
            --end


            --local damage = self:CalculateDamage(player.name, newPollution, armor)
            --if damage > 20 then
            --    alert = 2
            --else
            --    alert = 1
            --end
            --if damage > 0 then
            --    if armor then
            --        if (armor.durability / prototypes.armor[armor.name].durability < 0.25 and armorCount == 1) then
            --            alert = 3
            --        end
            --        armor.drain_durability(damage)
            --        self:EquipArmorFromInventory(player, armor)
            --    else
            --        alert = 2
            --        damage = math.floor(newPollution / absorb)
            --        if (player.character.health > damage) then
            --            player.character.damage(damage, game.forces.pollution, "toxin")
            --        else
            --            player.character.die(game.forces.pollution, storage.killer)
            --            self:IncKills(player.name)
            --        end
            --    end
            --end
            --if alert == 1 then
            --    self:AddAlert(player, "yellow-gas-mask", {"High-pollution", pollution, string.format("%.2f", damage)})
            --elseif alert == 2 then
            --    self:AddAlert(player, "red-gas-mask", {"Very-high-pollution", pollution, string.format("%.2f", damage)})
            --elseif alert == 3 then
            --    self:AddAlert(player, "red-armor", {"Armor-worn-out", pollution, string.format("%.2f", damage)})
            --else
            --    self:RemoveAlert(player, "yellow-gas-mask")
            --    self:RemoveAlert(player, "red-gas-mask")
            --    self:RemoveAlert(player, "red-armor")
            --end
        end
    end
end

function Toxic:OnPlayerDied(event)
    local player = game.players[event.player_index]
    local entity = event.cause
    if (entity ~= nil and entity.name == "pollution") then
        self:IncKills(player.name)
        self:ClearTimeMultiplier(player.name)
    end
end

function Toxic:OnPlayerRespawned(event)
    local player = game.players[event.player_index]
    if not conf:IsEquipRespiratorWhenRespawn(player) then return end
    -- 1.1 source used character_ammo (which silently rejects non-ammo items)
    -- and ignored the per-user setting. Equip into the armor slot so the
    -- respirator actually protects; fall back to main inventory if occupied.
    local armor_inv = player.get_inventory(defines.inventory.character_armor)
    if armor_inv and armor_inv.is_empty() then
        armor_inv.insert({name="respirator", count=1})
        return
    end
    local main = player.get_inventory(defines.inventory.character_main)
    if main then main.insert({name="respirator", count=1}) end
end