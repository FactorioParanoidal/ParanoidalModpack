TechnologyTreeCacheUtil = {}

local TECHNOLOGY_TREE_CACHE = {}

TechnologyTreeCacheUtil.initTechnologyTreeCache = function(mode)
	TECHNOLOGY_TREE_CACHE[mode] = {}
end

TechnologyTreeCacheUtil.addTechnologyToCacheTree = function(technology_name, technology_tree, mode)
	TECHNOLOGY_TREE_CACHE[mode][technology_name] = technology_tree
end

TechnologyTreeCacheUtil.getTechnologyFromCacheTree = function(technology_name, mode)
	return TECHNOLOGY_TREE_CACHE[mode][technology_name]
end

TechnologyTreeCacheUtil.removeCacheForTechnologyTree = function(technology_name, mode)
	TECHNOLOGY_TREE_CACHE[mode][technology_name] = nil
end

TechnologyTreeCacheUtil.cleanupTechnologyTreeCache = function(mode)
	if not TECHNOLOGY_TREE_CACHE[mode] then
		return
	end
	_table.each(TECHNOLOGY_TREE_CACHE[mode], function(value, key)
		TechnologyTreeCacheUtil.removeCacheForTechnologyTree(key, mode)
	end)
	TECHNOLOGY_TREE_CACHE[mode] = nil
end
