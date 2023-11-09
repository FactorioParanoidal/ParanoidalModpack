require('basic-technologies')
require('normal-techologies-tree-update')


local function updateTechnologyTree()
	createBasicTechnologyTree()
	updateTechnologyNormalTree()
	linkBasicTechnologiesToNormalTree()
	updateTechnologyEffectsNormalTree()
end

if mods["zzzparanoidal"] then
	updateTechnologyTree()
end