
data:extend({
  {
    name = "tiny-warheads",
    type = "item-subgroup",
    group = "intermediate-products",
    order = "y1[tiny-warheads]"
  },
  {
    name = "small-warheads",
    type = "item-subgroup",
    group = "intermediate-products",
    order = "y2[small-warheads]"
  },
  {
    name = "medium-warheads",
    type = "item-subgroup",
    group = "intermediate-products",
    order = "y3[medium-warheads]"
  },
  {
    name = "large-warheads",
    type = "item-subgroup",
    group = "intermediate-products",
    order = "y4[large-warheads]"
  },
  {
    name = "huge-warheads",
    type = "item-subgroup",
    group = "intermediate-products",
    order = "y5[huge-warheads]"
  }
})

--all these work in generated names...
if not warheads then
  warheads = {}
end
if not weaponTypes then
  weaponTypes = {}
end
if not generateWarheadAnyway then
  generateWarheadAnyway = {} -- names of warheads to generate even if they aren't launched by anything, mapped to true
end
if not specialTechForWarheadWeapon then
  specialTechForWarheadWeapon = {} -- names of warhead-weapons not to generate automatic tech for, mapped to the name of the tech (0 or false for no tech)
end
if not weaponNoTech then
  weaponNoTech = {} -- names of weapons not to generate tech for, overrides the default, but not special techs, mapped to true
end
if not warheadOverrides then
  warheadOverrides = {} -- functions taking the combined result, and changing things - very free form
end
if not warheadWeaponIgnore then
  warheadWeaponIgnore = {} -- names of things to ignore, mapped to true
end
if not warheadWeaponDoAnyway then
  warheadWeaponDoAnyway = {} -- names of things to do anyway, mapped to true - override to sizes
end
if not warheadWeaponNameMap then
  warheadWeaponNameMap= {} -- map of generated name to use name
end


local sizes = {
  none = 0,
  tiny = 10,
  small = 20,
  medium = 30,
  large = 40,
  huge = 50,
  all = 100
}

local function addOverride(name, override)
  if not warheadOverrides[name] then
    warheadOverrides[name] = {}
  end
  table.insert(warheadOverrides[name], override)
end

return {sizes = sizes, addOverride = addOverride}

