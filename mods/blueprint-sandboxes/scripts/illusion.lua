-- Illusion magic for swapping real/complex entities with fake/simple variants
local Illusion = {}

Illusion.pfx = BPSB.pfx .. "ils-"
local pfxLength = string.len(Illusion.pfx)

-- Full list of Entities that require Illusions
Illusion.mappings = {
    -- { "type", "entity-name", "item-name" },
    { "ammo-turret", "se-meteor-defence-container", "se-meteor-defence" },
    { "ammo-turret", "se-meteor-point-defence-container", "se-meteor-point-defence" },
    { "assembling-machine", "se-delivery-cannon", "se-delivery-cannon" },
    { "assembling-machine", "se-delivery-cannon-weapon", "se-delivery-cannon-weapon" },
    { "assembling-machine", "se-energy-transmitter-injector", "se-energy-transmitter-injector" },
    { "assembling-machine", "se-energy-transmitter-emitter", "se-energy-transmitter-emitter" },
    { "assembling-machine", "se-space-elevator", "se-space-elevator" },
    { "boiler", "se-energy-transmitter-chamber", "se-energy-transmitter-chamber" },
    { "container", "se-rocket-launch-pad", "se-rocket-launch-pad" },
    { "container", "se-rocket-landing-pad", "se-rocket-landing-pad" },
    { "electric-energy-interface", "se-energy-beam-defence", "se-energy-beam-defence" },
    { "mining-drill", "se-core-miner-drill", "se-core-miner" },
}

Illusion.realToIllusionMap = {}
for _, mapping in ipairs(Illusion.mappings) do
    Illusion.realToIllusionMap[mapping[2]] = Illusion.pfx .. mapping[2]
end

Illusion.realNameFilters = {}
for realEntityName, illusionName in pairs(Illusion.realToIllusionMap) do
    table.insert(Illusion.realNameFilters, realEntityName)
end

-- Whether the Thing is an Illusion
function Illusion.IsIllusion(name)
    return string.sub(name, 1, pfxLength) == Illusion.pfx
end

-- Extract the Name from an Illusion
function Illusion.GetActualName(name)
    return string.sub(name, pfxLength + 1)
end

-- Extract the Name from an Entity
function Illusion.GhostOrRealName(entity)
    local realName = entity.name
    if entity.type == "entity-ghost" then
        realName = entity.ghost_name
    end
    return realName
end

-- Convert a built Entity into an Illusion (if possible)
function Illusion.ReplaceIfNecessary(entity)
    if not entity.valid then
        return
    end

    local realName = Illusion.GhostOrRealName(entity)
    local illusionName = Illusion.realToIllusionMap[realName]
    if illusionName == nil then
        return
    end

    local options = {
        name = illusionName,
        position = entity.position,
        direction = entity.direction,
        force = entity.force,
        fast_replace = true,
        spill = false,
        raise_built = true,
    }

    local result = entity.surface.create_entity(options)

    if result == nil then
        log("Could not replace " .. realName .. " with " .. illusionName)
    else
        log("Replaced " .. realName .. " with " .. illusionName)
    end
end


--[[
Holy shit, this is perhaps __the__ most gross portion of the Modding API.
on_player_setup_blueprint _should_ be the primary and only method for handling
Blueprints, but it is not. It is only _correctly_ called when the Blueprint
is first created. If a Blueprint has its contents reselected, then it is still
called, but the event data is entirely useless. Allegedly, you'd have to find
the Blueprint in the Player's inventory - but it might not always be there either!
It seems most in the community went for on_gui_closed which _probably_ has the
Blueprint, however it will occur after selection so I imagine there's potential
for it to _appear_ wrong before saving. on_gui_opened would work the same,
but of course it would not catch any updates, so it's useless in this case.
Worse still, this _only_ works for Blueprints in your Inventory - not from
the Library! For that situation, we'll warn the Player.

See:

[kovarex] [1.0.0] Updated blueprint has no entities during on_player_setup_blueprint
https://forums.factorio.com/viewtopic.php?f=48&t=88100

[kovarex] [1.1.36] Blueprints missing entity list when reused
https://forums.factorio.com/viewtopic.php?f=7&t=99323

[kovarex] [1.0.0] New contents for blueprint broken vs. new blueprint
https://forums.factorio.com/viewtopic.php?f=29&t=88793

Copying (Ctrl+C):
- on_blueprint_setup is called
- blueprint_to_setup NOT valid_for_read
- cursor_stack valid_for_read
- cursor_stack is setup, has entity mapping, and entities

Copying into new Blueprint (Shift+Ctrl+C):
Empty Blueprint in cursor, from Inventory or Book in Inventory, selecting new area (Alt+B):
- on_blueprint_setup is called
- blueprint_to_setup valid_for_read
- blueprint_to_setup is setup, has entity mapping, and entities
- cursor_stack NOT valid_for_read

Selecting new contents, from Inventory or Book in Inventory:
Selecting new contents, from Library or Book in Library:
- on_blueprint_setup is called
- blueprint_to_setup NOT valid_for_read
- cursor_stack valid_for_read
- cursor_stack NOT setup, NO entity mapping, NO entities

Closing/Confirming Blueprint GUI, from Inventory or Book in Inventory:
- on_gui_closed is called
- item valid_for_read
- item NOT setup, NO entity mapping, but has entities

Closing/Confirming Blueprint GUI, from Library or Book in Library:
- on_gui_closed is called
- item valid_for_read
- item NOT setup, NO entity mapping, NO entities

]]

-- Convert an entire Blueprint's contents from Illusions (if possible)
function Illusion.HandleBlueprintEvent(player, potentialItemStacks)
    if not Sandbox.IsPlayerInsideSandbox(player) then
        return
    end

    local blueprint = nil
    for _, itemStack in pairs(potentialItemStacks) do
        if itemStack and itemStack.valid_for_read and itemStack.is_blueprint then
            blueprint = itemStack
            break
        end
    end

    -- We must catch more events than we need, so this is expected
    if not blueprint then
        return
    end

    -- Some events won't have a functional Blueprint, so we're screwed!
    local entities = blueprint.get_blueprint_entities()
    if not entities then
        log("Cannot handle Blueprint update: no entities in Blueprint (caused by selecting new contents)")
        local playerData = global.players[player.index]
        local lastWarningForNewContents = playerData.lastWarningForNewContents or 0
        if game.tick - lastWarningForNewContents > (216000) then -- 1 hour
            player.print("WARNING: Known issues in Factorio prevent mods from seeing or updating Blueprints when using 'Select new contents'.")
            player.print("This mod requires that ability to swap the Fake Illusions for their Real Entities in your Blueprints.")
            player.print("If you are including any Fake Illusions in this Blueprint, they likely will NOT be replaced, especially if the source Blueprint is within the Library instead of your Inventory.")
            player.print("This message will only appear periodically. See the mod's page for more details.")
            playerData.lastWarningForNewContents = game.tick
        end
        return
    end

    local replaced = 0
    for _, entity in pairs(entities) do
        if Illusion.IsIllusion(entity.name) then
            entity.name = Illusion.GetActualName(entity.name)
            replaced = replaced + 1
        end
    end
    if replaced > 0 then
        blueprint.set_blueprint_entities(entities)
    end
    log("Replaced " .. replaced .. " entities in Sandbox Blueprint")
end

-- A Player is creating a new Blueprint from a selection
function Illusion.OnBlueprintSetup(event)
    local player = game.players[event.player_index]
    Illusion.HandleBlueprintEvent(player, {
        player.blueprint_to_setup,
        player.cursor_stack,
    })
end

-- A Player might be updating an existing Blueprint (only works in the Inventory!)
function Illusion.OnBlueprintGUIClosed(event)
    if not event.item then
        return
    end
    Illusion.HandleBlueprintEvent(game.players[event.player_index], {
        event.item,
    })
end

return Illusion
