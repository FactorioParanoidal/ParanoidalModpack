local this = {}
local config = require("config")
local prototype = scripts.helpers
local _ = scripts.helpers.on


function prototype:calculateDamage()
    local type = self.get_ammo_type()
    return type and type.action and this.damageFromActions(type.action) or 0
end

function prototype:calculateRadius()
    local type = self.get_ammo_type()
    return type and type.action and this.radiusFromActions(type.action) or 0
end


function this.damageFromActions(actions)
    return _(actions)
            :sum(function(__,action)
                return this.damageFromAction(action) * action.repeat_count
            end)
end

function this.damageFromAction(action)
    if action.action_delivery then
        local multiplier = action.radius and action.radius * action.radius * math.pi or 1

        return _(action.action_delivery)
                :sum(function(__,delivery)
                    return this.deliveryDamage(delivery) * multiplier 
                end)
    end

    return 0
end

function this.deliveryDamage(delivery)
	if delivery.type == 'instant' and delivery.target_effects then
        return _(delivery.target_effects)
                :sum(function(__,effect)
                    return (effect.action                  and this.damageFromActions(effect.action)       or 0) or
                           (effect.type == 'damage'        and effect.damage.amount                        or 0) or
                           (effect.type == 'create-entity' and this.entityAttackDamage(effect.entity_name) or 0)
                end)
        
	elseif delivery.projectile then
        return this.entityAttackDamage(delivery.projectile)
        
	elseif delivery.stream then
		return this.entityAttackDamage(delivery.stream)
    end

    return 0
end

function this.entityAttackDamage(name)
	local entity = game.entity_prototypes[name]
    local damage = 0
    
	if entity then
		if entity.attack_result then
			damage = damage + this.damageFromActions(entity.attack_result)
		end
		if entity.final_attack_result then
			damage = damage + this.damageFromActions(entity.final_attack_result)
		end
    end
    
	return damage
end

function this.radiusFromActions(actions)
    return _(actions)
            :sum(function(__,action)
                return this.radiusFromAction(action)
            end)
end

function this.radiusFromAction(action)
    if action.action_delivery then
        return _(action.action_delivery)
                :sum(function(__,delivery)
                    return this.radiusOfDelivery(delivery)
                end)
                + (action.radius or 0)
    end

    return 0
end

function this.radiusOfDelivery(delivery)
	if delivery.type == 'instant' and delivery.target_effects then
        return _(delivery.target_effects)
                :sum(function(__,effect)
                    if effect.action then
                        return this.radiusFromActions(effect.action) + (effects.action.radius or 0)
                    end
                    return 0
                end)
        
	elseif delivery.projectile then
        return this.radiusFromEntity(delivery.projectile)
        
	elseif delivery.stream then
		return this.radiusFromEntity(delivery.stream)
    end
end

function this.radiusFromEntity(name)
	local entity = game.entity_prototypes[name]
    local radius = 0
    
	if entity then
		if entity.attack_result then
			radius = radius + this.radiusFromActions(entity.attack_result)
		end
		if entity.final_attack_result then
			radius = radius + this.radiusFromActions(entity.final_attack_result)
		end
    end
    
	return radius
end
