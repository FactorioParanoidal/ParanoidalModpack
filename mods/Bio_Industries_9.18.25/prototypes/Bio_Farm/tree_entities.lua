--[[

Big thanks to OwnlyMe and his "Robot Tree Farm" code!
https://mods.factorio.com/mod/robot_tree_farm
License:  CC BY-SA 4.0

]]

local OPTIMIZED = tonumber(util.split(mods["base"], '.')[2]) > 17

local COLLISION_BOX = {{-0.1, -0.1}, {0.1, 0.1}}
local TREE_LEVELS = 4
local extend = {}

for i = 1, TREE_LEVELS do
  local wooden = table.deepcopy(data.raw[OPTIMIZED and "optimized-particle" or "particle"]["wooden-particle"])

  wooden.name = "bio-" .. wooden.name .. "-" .. i
  for _, pic in pairs(wooden.pictures) do
    pic.scale = (pic.scale or 1)/TREE_LEVELS*i
    pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
  end
  for _, pic in pairs(wooden.shadows) do
    pic.scale = (pic.scale or 1)/TREE_LEVELS*i
    pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
  end
  local branch = table.deepcopy(data.raw[OPTIMIZED and "optimized-particle" or "particle"]["branch-particle"])
  branch.name = "bio-" .. branch.name .. "-" .. i
  for _, pic in pairs(branch.pictures) do
    pic.scale = (pic.scale or 1)/TREE_LEVELS*i
    pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
  end
  for _, pic in pairs(branch.shadows) do
    pic.scale = (pic.scale or 1)/TREE_LEVELS*i
    pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
  end
  local leaf = table.deepcopy(data.raw[OPTIMIZED and "optimized-particle" or "leaf-particle"]["leaf-particle"])
  --local leaf = table.deepcopy(data.raw["leaf-particle"]["leaf-particle"])
  leaf.name = "bio-" .. leaf.name .. "-" .. i
  for _, pic in pairs(leaf.pictures) do
    pic.scale = (pic.scale or 1)/TREE_LEVELS*math.max(2, i)
    --pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
  end
  for _, pic in pairs(leaf.shadows) do
    pic.scale = (pic.scale or 1)/TREE_LEVELS*math.max(2, i)
    --pic.hr_version.scale = (pic.hr_version.scale or 1)/TREE_LEVELS*i
  end
  data:extend({wooden, branch, leaf})
end

--global.bi.trees = {}

for id, prototype in pairs(data.raw.tree) do

  if prototype.variations then
    for i = 1, TREE_LEVELS do
      local tree = table.deepcopy(prototype)
      tree.name = "bio-tree-" .. tree.name .. "-" .. i
      if i < (TREE_LEVELS-1) then
        --~ tree.localised_name = "Sapling"
        tree.localised_name = {"bi-misc.growing-tree"}
        tree.localised_description = {"bi-misc.growing-tree-desc"}
      else
        --~ tree.localised_name = "Young Tree"
        tree.localised_name = {"bi-misc.young-tree"}
        tree.localised_description = {"bi-misc.young-tree-desc"}
      end
      tree.max_health = math.floor(50*i/TREE_LEVELS)
      tree.flags = {"placeable-neutral", "breaths-air"}
      tree.collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "layer-13"}
      tree.autoplace = nil
      tree.selection_box = {{-0.9/TREE_LEVELS*i, -2.2/TREE_LEVELS*i}, {0.9/TREE_LEVELS*i, 0.6/TREE_LEVELS*i}}
      if BI.Settings.BI_Game_Tweaks_Small_Tree_Collisionbox then
        tree.collision_box = COLLISION_BOX
      end
      tree.minable.mining_particle = "bio-wooden-particle-" .. i
      tree.minable.mining_time = 0.25
      --~ tree.minable.count = nil
      tree.minable.results = {}

      if i < (TREE_LEVELS) then
        table.insert(tree.minable.results, {
          name = "seedling",
          probability = i/4,
          amount = 1,
        })
      else
        table.insert(tree.minable.results, {
          name = "wood",
          amount = 1,
          probability = 1
        })
      end


      for var_id, variation in pairs(tree.variations) do
          variation.trunk.scale = (variation.trunk.scale or 1) * i / TREE_LEVELS
          if variation.trunk.shift then
            variation.trunk.shift[1] = variation.trunk.shift[1]/TREE_LEVELS*i
            variation.trunk.shift[2] = variation.trunk.shift[2]/TREE_LEVELS*i
          end

          if variation.trunk.hr_version then
            variation.trunk.hr_version.scale = (variation.trunk.hr_version.scale or 1) * i / TREE_LEVELS

            if variation.trunk.hr_version.shift then
              variation.trunk.hr_version.shift[1] = (variation.trunk.hr_version.shift[1] or 0)/TREE_LEVELS*i
              variation.trunk.hr_version.shift[2] = (variation.trunk.hr_version.shift[2] or 0)/TREE_LEVELS*i

            end
          end

          if i <= TREE_LEVELS /10 then
            variation.trunk = {layers = {{
              filename = "__Bio_Industries__/graphics/icons/Seedling_a.png",
              priority = "extra-high",
              width = 64,
              height = 64,
              scale = 0.5,
              frame_count = (variation.trunk.frame_count or 1),
              tint= {
                r = 0.7-0.5*i/(TREE_LEVELS/10),
                g = 0.7-0.5*i/(TREE_LEVELS/10),
                b = 0.7-0.5*i/(TREE_LEVELS/10),
                a = 0.7-0.5*i/(TREE_LEVELS/10)
              },
            }, variation.trunk}}
          end

          variation.leaves.scale = (variation.leaves.scale or 1) * i / TREE_LEVELS
          if variation.leaves.shift then
            variation.leaves.shift[1] = (variation.leaves.shift[1] or 0)/TREE_LEVELS*i
            variation.leaves.shift[2] = (variation.leaves.shift[2] or 0)/TREE_LEVELS*i
          end

          if variation.leaves.hr_version then
            variation.leaves.hr_version.scale = (variation.leaves.hr_version.scale or 1) * i / TREE_LEVELS
            if variation.leaves.hr_version.shift then
              variation.leaves.hr_version.shift[1] = (variation.leaves.hr_version.shift[1] or 0)/TREE_LEVELS*i
              variation.leaves.hr_version.shift[2] = (variation.leaves.hr_version.shift[2] or 0)/TREE_LEVELS*i
            end
          end

          variation.leaf_generation.scale = (variation.leaf_generation.scale or 1) * i / TREE_LEVELS
          variation.leaf_generation.offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}}
          variation.leaf_generation.initial_height = 2/TREE_LEVELS*i
          variation.leaf_generation.initial_height_deviation = 1/TREE_LEVELS*i
          variation.leaf_generation.entity_name = "bio-leaf-particle-" .. i
          variation.branch_generation.scale = (variation.branch_generation.scale or 1) * i / TREE_LEVELS
          variation.branch_generation.offset_deviation = {
            {0.5*i/TREE_LEVELS, 0.5*i/TREE_LEVELS},
            {0.5*i/TREE_LEVELS, 0.5*i/TREE_LEVELS}
          }
          variation.branch_generation.initial_height = 2/TREE_LEVELS*i
          variation.branch_generation.initial_height_deviation = 2/TREE_LEVELS*i
          variation.branch_generation.entity_name = "bio-branch-particle-" .. i
          variation.shadow.scale = (variation.shadow.scale or 1) * i / TREE_LEVELS

          if variation.shadow.shift then
            variation.shadow.shift[1] = (variation.shadow.shift[1] or 0)/TREE_LEVELS*i
            variation.shadow.shift[2] = (variation.shadow.shift[2] or 0)/TREE_LEVELS*i
          end

          if variation.shadow.hr_version then
            variation.shadow.hr_version.scale = (variation.shadow.hr_version.scale or 1) * i / TREE_LEVELS
            if variation.shadow.hr_version.shift then
              variation.shadow.hr_version.shift[1] = (variation.shadow.hr_version.shift[1] or 0)/TREE_LEVELS*i
              variation.shadow.hr_version.shift[2] = (variation.shadow.hr_version.shift[2] or 0)/TREE_LEVELS*i
            end
          end
      end


      local stump = table.deepcopy(data.raw.corpse[tree.remains_when_mined])

      if stump then
        stump.name = "bio-tree-" .. stump.name .. "-" .. i
        stump.time_before_removed = 60*5

        tree.remains_when_mined = stump.name
        tree.corpse = stump.name
        table.insert(extend, tree)

        for _, variation in pairs(stump.animation) do
          variation.scale = (variation.scale or 1) * i / TREE_LEVELS
          variation.hr_version = nil
          variation.shift[1] = variation.shift[1]/TREE_LEVELS*i
          variation.shift[2] = variation.shift[2]/TREE_LEVELS*i

        end

        table.insert(extend, stump)

      end
    end
  end
end

data:extend(extend)
