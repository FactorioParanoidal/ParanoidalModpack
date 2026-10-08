local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local adapter = require("scripts.defects.handcraft")
local eligibility = require("scripts.defects.eligibility")
local catalog = eligibility.catalog({
    lab = {type = "lab", lab_inputs = {"automation-science-pack", "bob-speed-processor"}},
    ore = {type = "resource", mineable_properties = {products = {{type = "item", name = "angels-ore1"}}}},
})
local function near(a,b) assert(math.abs(a-b)<1e-12) end
local function make_stack(payload, reject_swap)
    local stack = {payload = payload}
    setmetatable(stack, {__index = function(self,key)
        local p = rawget(self, "payload")
        if key == "valid_for_read" then return p ~= nil end
        if key == "quality" then return {name=p.quality} end
        if key == "prototype" then return {
            name=p.name, type=p.kind or "item",
            place_result=p.place_result or (p.name=='assembling-machine-1' and {} or nil),
            get_durability=function(q) return q == "normal" and 100 or 100/3 end,
        } end
        if key == "item" then return {grid=p.grid, ammo=p.ammo, durability=p.durability} end
        return p and p[key]
    end})
    stack.set_stack = function(definition)
        local p={}
        for k,v in pairs(definition) do p[k]=v end
        stack.payload=p
        return true
    end
    stack.swap_stack = function(other)
        if reject_swap then return false end
        stack.payload,other.payload=other.payload,stack.payload
        return true
    end
    return stack
end
local function player(level)
    local technologies={}
    for i=1,level do technologies['ic-defect-control-'..i]={researched=true} end
    return {valid=true,force={technologies=technologies}}
end
local destroyed, created = 0, 0
local reject_candidate=false
local function inventory(size)
    assert(size==1)
    created=created+1
    local result={[1]=make_stack(nil)}
    if reject_candidate then result[1].set_stack=function() return false end end
    result.destroy=function() destroyed=destroyed+1 end
    return result
end
local function fresh(extra)
    local p={name='assembling-machine-1',quality='normal',count=7,health=.6,spoil_percent=.2}
    for k,v in pairs(extra or {}) do p[k]=v end
    return p
end
local function handle(stack,level,roll)
    return adapter.handle({item_stack=stack},player(level),inventory,function()return roll or 0 end,catalog)
end
local stack=make_stack(fresh())
assert(handle(stack,0)=='changed')
assert(stack.quality.name=='ic-defect-5' and stack.count==7)
near(stack.health,.6);near(stack.spoil_percent,.2)
assert(handle(stack,10)=='changed' and stack.quality.name=='normal' and stack.count==7)
local before=created
assert(handle(stack,10)=='unchanged' and created==before)

local positive=make_stack(fresh({quality='legendary'}))
assert(handle(positive,0)=='preserved-quality' and positive.quality.name=='legendary')
local protected=make_stack(fresh({kind='item-with-inventory'}))
assert(handle(protected,0)=='unsupported-item' and protected.quality.name=='normal')
local armor=make_stack(fresh({kind='armor',grid={equipment={{name='battery'}}}}))
assert(handle(armor,0)=='occupied-grid' and armor.item.grid.equipment[1].name=='battery')

local ammo=make_stack(fresh({kind='ammo',ammo=3}))
assert(handle(ammo,0)=='changed' and ammo.item.ammo==3)
local tool=make_stack(fresh({name='automation-science-pack',kind='tool',durability=60}))
assert(handle(tool,0)=='changed');near(tool.payload.durability,20)
local failed=make_stack(fresh(),true)
local original=failed.payload
assert(handle(failed,0)=='swap-rejected' and failed.payload==original)
reject_candidate=true
local failed2=make_stack(fresh())
original=failed2.payload
assert(handle(failed2,0)=='candidate-rejected' and failed2.payload==original)
reject_candidate=false

-- Raw materials and intermediates never draw RNG or allocate a candidate at standard quality.
for _,name in ipairs({'wood','coal','stone','angels-ore1','iron-plate','iron-gear-wheel','copper-cable','electronic-circuit'}) do
    local intermediate=make_stack(fresh({name=name}))
    local count=created
    assert(adapter.handle({item_stack=intermediate},player(0),inventory,function() error('Unexpected defect roll') end,catalog)=='excluded-intermediate')
    assert(intermediate.quality.name=='normal' and created==count)
end
local inherited=make_stack(fresh({name='iron-gear-wheel',quality='ic-defect-5'}))
assert(adapter.handle({item_stack=inherited},player(0),inventory,function() error('Unexpected defect roll') end,catalog)=='changed')
assert(inherited.quality.name=='normal' and inherited.count==7)
-- Do not alter native positive quality as a side effect of the negative-quality filter.
assert(handle(make_stack(fresh({name='iron-gear-wheel',quality='legendary'})),0)=='preserved-quality')

-- All temporary inventories are released; no count is removed from player inventory.
assert(destroyed==created)
assert(adapter.handle({item_stack=make_stack(nil)},player(0),inventory,math.random)=='ignored')
print('PASS: real handcraft adapter with mocks: defect at level 0, standard at 10, force research,')
print('count/health/spoilage/ammo/durability preservation, protected-data skip, atomic failure paths.')
print('NOT tested: Factorio load, handcraft queues, machine production or mining.')
