TechnologyTreeCacheUtil = {}

local TECHNOLOGY_TREE_CACHE = {}

TechnologyTreeCacheUtil.init_technology_tree_cache = function(mode)
	TECHNOLOGY_TREE_CACHE[mode] = {}
end

TechnologyTreeCacheUtil.add_technology_to_cache_tree = function(technology_name, technology_tree, mode)
	TECHNOLOGY_TREE_CACHE[mode][technology_name] = technology_tree
end

TechnologyTreeCacheUtil.get_technology_from_cache_tree = function(technology_name, mode)
	return TECHNOLOGY_TREE_CACHE[mode][technology_name]
end

TechnologyTreeCacheUtil.remove_cache_for_technology_tree = function(technology_name, mode)
	TECHNOLOGY_TREE_CACHE[mode][technology_name] = nil
end

TechnologyTreeCacheUtil.cleanup_technology_tree_cache = function(mode)
	if not TECHNOLOGY_TREE_CACHE[mode] then
		return
	end
	_table.each(TECHNOLOGY_TREE_CACHE[mode], function(value, key)
		TechnologyTreeCacheUtil.remove_cache_for_technology_tree(key, mode)
	end)
	TECHNOLOGY_TREE_CACHE[mode] = nil
end
