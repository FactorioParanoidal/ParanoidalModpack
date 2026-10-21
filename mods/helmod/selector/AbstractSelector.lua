-------------------------------------------------------------------------------
---Classe to build selector dialog
--
---@module AbstractSelector
---@extends #Form
--

AbstractSelector = newclass(FormModel,function(base,classname)
  FormModel.init(base,classname)
  base.auto_clear = false
end)

local limit_display_height = 850

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function AbstractSelector:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    width = 490,
    height = math.max(height_main,800)
  }
  styles.block_info = {
    width = 310,
    height = 50*2+45
  }
end

-------------------------------------------------------------------------------
---Return filter - filtre sur les prototypes
---@return table
function AbstractSelector:getProductFilter()
  local filter_prototype_product = User.getParameter("filter_prototype_product")
  if filter_prototype_product == nil then filter_prototype_product = true end
  return filter_prototype_product
end

-------------------------------------------------------------------------------
---Return filter - filtre sur les prototypes
---@return table
function AbstractSelector:getFilter()
  return User.getParameter("filter_prototype")
end

-------------------------------------------------------------------------------
---Return list prototype
---@return table
function AbstractSelector:getListPrototype()
  if self:getProductFilter() and not(Cache.isEmpty(self.classname, "list_products")) then
    return Cache.getData(self.classname, "list_products") or {}
  end
  return Cache.getData(self.classname, "list_ingredients") or {}
end

-------------------------------------------------------------------------------
---Return list group
---@return table
function AbstractSelector:getListGroup()
  return User.getCache(self.classname, "list_group") or {}
end

-------------------------------------------------------------------------------
---Return list subgroup
---@return table
function AbstractSelector:getListSubGroup()
  return User.getCache(self.classname, "list_subgroup") or {}
end

-------------------------------------------------------------------------------
---Return list item
---@return table
function AbstractSelector:getListItem()
  return User.getCache(self.classname, "list_item") or {}
end

-------------------------------------------------------------------------------
---Return list group elements
---@return table
function AbstractSelector:getListGroupElements()
  return User.getCache(self.classname, "list_group_elements") or {}
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function AbstractSelector:getCaption()
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
---On initialization
function AbstractSelector:onInit()
  self.panelCaption = self:getCaption() ---obligatoire sinon le panneau ne s'affiche pas
  self.sprite_type = "item-group"
  self:afterInit()
  self.parameterTarget = string.format("%s_%s",self.classname,"target")
  self.panel_close_before_main = true
end

-------------------------------------------------------------------------------
---After initialization
function AbstractSelector:afterInit()
  self.rules_filter = false
  self.unlock_recipe = false
  self.disable_option = false
  self.hidden_option = false
  self.product_option = false
end

-------------------------------------------------------------------------------
---Get or create filter panel
---@return LuaGuiElement
function AbstractSelector:getFilterPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["filter-panel"] ~= nil and content_panel["filter-panel"].valid then
    return content_panel["filter-panel"]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV("filter-panel"))
  panel.style.horizontally_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
---Get or create scroll panel
---@return LuaGuiElement
function AbstractSelector:getSrollPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["main_panel"] ~= nil and content_panel["main_panel"].valid then
    return content_panel["main_panel"]["scroll_panel"]
  end
  local main_panel = GuiElement.add(content_panel, GuiFrameV("main_panel"))
  main_panel.style.horizontally_stretchable = true
  local scroll_panel = GuiElement.add(main_panel, GuiScroll("scroll_panel"):style("helmod_scroll_pane"))
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create groups panel
---@return LuaGuiElement
function AbstractSelector:getGroupsPanel()
  local filter_scroll_groups = User.getSetting("filter_scroll_groups")
  if filter_scroll_groups == false then
    --- affichage normal
    local flow_panel, content_panel, menu_panel = self:getPanel()
    --local content_panel = self:getSrollPanel()
    if content_panel["groups_panel"] ~= nil and content_panel["groups_panel"].valid then
      return content_panel["groups_panel"]
    end
    local group_panel = GuiElement.add(content_panel, GuiFrameV("groups_panel"))
    group_panel.style.horizontally_stretchable = true
    return group_panel
  else
    --- affichage full scroll
    local content_panel = self:getSrollPanel()
    if content_panel["groups_panel"] ~= nil and content_panel["groups_panel"].valid then
      return content_panel["groups_panel"]
    end
    return GuiElement.add(content_panel, GuiFlowV("groups_panel"))
  end
end

-------------------------------------------------------------------------------
---Get or create groups panel
---@return LuaGuiElement
function AbstractSelector:getFailPanel()
  local scroll_panel = self:getSrollPanel()
  if scroll_panel["groups_panel"] ~= nil and scroll_panel["groups_panel"].valid then
    return scroll_panel["groups_panel"]
  end
  return GuiElement.add(scroll_panel, GuiFlowV("groups_panel"))
end

-------------------------------------------------------------------------------
---Get or create item list panel
---@return LuaGuiElement
function AbstractSelector:getItemListPanel()
  local scroll_panel = self:getSrollPanel()
  if scroll_panel["item_list_panel"] ~= nil and scroll_panel["item_list_panel"].valid then
    return scroll_panel["item_list_panel"]
  end
  return GuiElement.add(scroll_panel, GuiFlowV("item_list_panel"))
end

-------------------------------------------------------------------------------
---On before open
---@param event LuaEvent
function AbstractSelector:onBeforeOpen(event)
  FormModel.onBeforeOpen(self, event)
  if event.action == "OPEN" then
    User.setParameter(self.parameterTarget, event.item1)
  end
  
  if event.item4 ~= nil and event.item4 ~= "" then
    if User.isFilterTranslate()  then
      User.setParameter("filter_prototype", User.getTranslate(event.item4))
    else
      User.setParameter("filter_prototype", event.item4)
    end
    if event.reset ~= true then
      event.reset = true
      self:resetGroups()
    end
  else
    local filter_prototype = self:getFilter()
    -- an empty filter builds the same list as no filter, keep the cached list
    if filter_prototype ~= nil and filter_prototype ~= "" and event.continue ~= true then
      event.reset = true
      self:resetGroups()
    end
    User.setParameter("filter_prototype", nil)
  end

  if event ~= nil and event.button ~= nil and event.button == defines.mouse_button_type.right then
      User.setParameter("filter_prototype_product", false)
  else
    User.setParameter("filter_prototype_product", true)
  end

  if event.item ~= nil then
    User.setParameter("selector_quality_prototype", event.item.quality)
  end
  quality_selector_cell = nil
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function AbstractSelector:onEvent(event)
  local default_settings = User.getDefaultSettings()
  local model, block, recipe = self:getParameterObjects()
  local prototype_type = event.item1
  local prototype_name = event.item2

  if User.isWriter(model) then
    if User.getParameter(self.parameterTarget) == "HMPropertiesPanel" then
      if event.action == "element-select" then
        local prototype_compare = User.getParameter("prototype_compare") or {}
        table.insert(prototype_compare, {type = prototype_type, name = prototype_name })
        User.setParameter("prototype_compare", prototype_compare)
        self:close()
        Controller:send("on_gui_refresh", event)
      end
    elseif User.getParameter(self.parameterTarget) == "HMRecipeExplorer" then
      if event.action == "element-select" then
        Controller:send("on_gui_event", event, "HMRecipeExplorer")
        self:close()
      end
    elseif User.getParameter(self.parameterTarget) == "HMCreatedOrWhereUsedPanel" then
      if event.action == "element-select" then
        Controller:send("on_gui_event", event, "HMCreatedOrWhereUsedPanel")
        self:close()
      end
    else
      ---classic selector
      if event.action == "element-select" and prototype_type ~= "container" then
        local index = nil
        if self:getProductFilter() == false then index = 0 end
        local new_block, new_recipe = ModelBuilder.addRecipeIntoProductionBlock(model, block, prototype_name, prototype_type, index)
        local selector_quality_prototype = User.getParameter("selector_quality_prototype")
        if selector_quality_prototype ~= nil then
          new_recipe.quality = selector_quality_prototype
        end
        ModelCompute.update(model)
        User.setParameter("scroll_element", new_recipe.id)
        User.setActiveForm("HMProductionPanel")
        User.setParameterObjects("HMProductionPanel", model.id, new_block.id, new_recipe.id)
        User.setParameterObjects(self.classname, model.id, new_block.id)
        Controller:send("on_gui_refresh", event)

        if User.getPreferenceSetting("close_after_selection") == true then
          if User.getPreferenceSetting("close_after_selection", self.classname) == true then
              self:close()
          end
      end
      end
      ---container selector
      if event.action == "element-select" and prototype_type == "container" then
        local type = EntityPrototype(prototype_name):getType()
        if type == "container" or type == "logistic-container" then
          User.setParameter("container_solid", prototype_name)
        end
        if type == "storage-tank" then
          User.setParameter("container_fluid", prototype_name)
        end
        if type == "car" or type == "cargo-wagon" or type == "item-with-entity-data"  or type == "logistic-robot" or type == "transport-belt" then
          User.setParameter("vehicle_solid", prototype_name)
        end
        if type == "fluid-wagon" then
          User.setParameter("vehicle_fluid", prototype_name)
        end
        Controller:send("on_gui_refresh", event)
      end
    end
  end

  if event.action == "recipe-group" then
    User.setParameter("recipe_group_selected",event.item1)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "quality-select" then
    User.setParameter("selector_quality_prototype",event.item1)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "change-options-visibility" then
    local options_visible_name = "filter_options_visible"
    local filter_options_visible = User.getSetting(options_visible_name)
    if filter_options_visible == nil then filter_options_visible = true end
    
    local panel = self:getFilterPanel()
    panel["filter-options"].visible = not(filter_options_visible)
    User.setSetting(options_visible_name, not(filter_options_visible))

    self:updateFilter(event)
  end

  if event.action == "change-sroll-groups" then
    User.setSetting("filter_scroll_groups", event.item1 == "true")
    local flow_panel, content_panel, menu_panel = self:getPanel()
    content_panel.clear()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "change-boolean-settings" then
    if User.getSetting(event.item1) == nil then User.setSetting(event.item1, default_settings[event.item]) end
    User.setSetting(event.item1, not(User.getSetting(event.item1)))
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "recipe-filter-switch" then
    local switch_by_product = event.element.switch_state == "left"
    User.setParameter("filter_prototype_product", switch_by_product)
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "filter-language-switch" then
    User.setParameter("filter-language", event.element.switch_state)
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "filter-contain-switch" then
    User.setParameter("filter-contain", event.element.switch_state)
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "recipe-filter" then
    if User.getModGlobalSetting("filter_on_text_changed") then
      User.setParameter("filter_prototype", event.element.text)
      self:resetGroups()
      Controller:send("on_gui_update", event, self.classname)
    else
      if event.element.parent ~= nil and event.element.parent[self.classname.."=recipe-filter=filter-text"] ~= nil then
        User.setParameter("filter_prototype", event.element.parent[self.classname.."=recipe-filter=filter-text"].text)
      end
      self:resetGroups()
      Controller:send("on_gui_update", event, self.classname)
    end
  end
end

-------------------------------------------------------------------------------
---Reset groups
function AbstractSelector:resetGroups()
  User.resetCache(self.classname, "list_group")
  User.resetCache(self.classname, "list_subgroup")
  User.resetCache(self.classname, "list_group_elements")
end

-------------------------------------------------------------------------------
---Update groups
---@param event LuaEvent
---@return table, table, table --list_group, list_subgroup, list_prototype
function AbstractSelector:updateGroups(event)
  return {},{},{}
end

-------------------------------------------------------------------------------
---Prepare
---@param event LuaEvent
function AbstractSelector:prepare(event)
  ---recuperation recipes
  if Cache.isEmpty(self.classname, "list_ingredients") then
    local list_products = {}
    local list_ingredients = {}
    local list_translate = {}

    self:updateGroups(list_products, list_ingredients, list_translate)

    Cache.setData(self.classname, "list_products", list_products)
    Cache.setData(self.classname, "list_ingredients", list_ingredients)

    if User.getModGlobalSetting("filter_translated_string_active") then
      Cache.setData(self.classname, "list_translate", list_translate)
    end
  end
end

-------------------------------------------------------------------------------
---Translate
---@param event LuaEvent
function AbstractSelector:translate(event)
  ---List du cache non vide
  if not(Cache.isEmpty(self.classname, "list_translate")) then
    ---bluid table translate
    if event.continue ~= true and User.getModGlobalSetting("filter_translated_string_active") and not(User.isTranslate()) then
      local list_translate = Cache.getData(self.classname, "list_translate")
      local table_translate = {}
      local step_translate = User.getModGlobalSetting("user_cache_step") or 100
      local index = 0
      event.continue = true
      local query_translate
      for item_name,localised_name in pairs(list_translate) do
        if index % step_translate == 0 then
          query_translate = {index=index,list_translate={}}
          table.insert(table_translate, query_translate)
        end
        table.insert(query_translate.list_translate, localised_name)
        index = index + 1
      end
      event.table_translate = table_translate
      return User.createNextEvent(event, self.classname, "translate")
    end
    ---execute loop
    if event.continue and event.method == "translate" then
      local query_translate = table.remove(event.table_translate)
      self:updateWaitMessage(string.format("Wait translate: %s", query_translate.index or 0))
      for _,localised_name in pairs(query_translate.list_translate) do
        User.queryTranslate(localised_name)
      end
      if #event.table_translate > 0 then
        return User.createNextEvent(event, self.classname, "translate")
      else
        event.continue = false
      end
    end
  end
  return User.createNextEvent(nil, self.classname, "translate")
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function AbstractSelector:onUpdate(event)
  ---the filter panel is already built when continuing a step-by-step build,
  ---unless the form was closed and reopened by the next step
  local filter_panel = self:getFilterPanel()
  if event.continue ~= true or filter_panel["filter-options"] == nil then
    self:updateFilter(event)
  end

  local response = {wait=false, method="none"}
  
  response = self:translate(event)
  
  if response.wait == true then 
    return
  end
  
  response = self:createElementLists(event)

  if response.wait == true then 
    return
  end
  self:updateGroupSelector(event)

  self:updateItemList(event)
  
  end

-------------------------------------------------------------------------------
---UTF-8 aware lower case (Lua string.lower is ASCII only)
local utf8_lower_map = nil

local function utf8_encode(code)
  if code < 0x80 then
    return string.char(code)
  elseif code < 0x800 then
    return string.char(0xC0 + math.floor(code / 0x40), 0x80 + code % 0x40)
  end
  return string.char(0xE0 + math.floor(code / 0x1000), 0x80 + math.floor(code / 0x40) % 0x40, 0x80 + code % 0x40)
end

local function build_utf8_lower_map()
  local map = {}
  local function add(upper, lower)
    map[utf8_encode(upper)] = utf8_encode(lower)
  end
  -- Latin-1: À-Þ except ×
  for code = 0xC0, 0xDE do
    if code ~= 0xD7 then add(code, code + 0x20) end
  end
  -- Latin Extended-A
  for code = 0x100, 0x137, 2 do add(code, code + 1) end
  for code = 0x139, 0x147, 2 do add(code, code + 1) end
  for code = 0x14A, 0x177, 2 do add(code, code + 1) end
  add(0x178, 0xFF)
  for code = 0x179, 0x17D, 2 do add(code, code + 1) end
  -- Greek
  for code = 0x391, 0x3AB do
    if code ~= 0x3A2 then add(code, code + 0x20) end
  end
  -- Cyrillic: Ѐ-Џ, А-Я, Ѡ-ӿ pairs
  for code = 0x400, 0x40F do add(code, code + 0x50) end
  for code = 0x410, 0x42F do add(code, code + 0x20) end
  for code = 0x460, 0x481, 2 do add(code, code + 1) end
  for code = 0x48A, 0x4BF, 2 do add(code, code + 1) end
  add(0x4C0, 0x4CF)
  for code = 0x4C1, 0x4CD, 2 do add(code, code + 1) end
  for code = 0x4D0, 0x52F, 2 do add(code, code + 1) end
  return map
end

local function utf8_lower(text)
  if utf8_lower_map == nil then
    utf8_lower_map = build_utf8_lower_map()
  end
  text = string.lower(text)
  return (string.gsub(text, "[\xC3-\xD4][\x80-\xBF]", utf8_lower_map))
end

-------------------------------------------------------------------------------
---Return a function checking a name against the current filter, nil if there is no filter.
---Settings, translations and the lower-cased filter are read once instead of once per name.
---@return function | nil
function AbstractSelector:getFilterMatcher()
  local filter_prototype = self:getFilter()
  if filter_prototype == nil or filter_prototype == "" then
    return nil
  end
  local filter_lower = utf8_lower(filter_prototype)
  local translated = nil
  if User.isFilterTranslate() then
    translated = User.get("translated")
  end
  local find = string.find
  if User.isFilterContain() then
    return function(search)
      if translated ~= nil and translated[search] ~= nil then search = translated[search] end
      return find(utf8_lower(search), filter_lower, 1, true) ~= nil
    end
  end
  return function(search)
    if translated ~= nil and translated[search] ~= nil then search = translated[search] end
    return utf8_lower(search) == filter_lower
  end
end

-------------------------------------------------------------------------------
---Check filter
---@param search string
---@return boolean
function AbstractSelector:checkFilter(search)
  local matcher = self:getFilterMatcher()
  if matcher == nil then
    return true
  end
  return matcher(search)
end

local quality_selector_cell = nil

-------------------------------------------------------------------------------
---Update filter
---@param event LuaEvent
function AbstractSelector:updateFilter(event)
  local panel = self:getFilterPanel()
  local filter_prototype = self:getFilter()
  local filter_options_visible = User.getSetting("filter_options_visible")
  local filter_scroll_groups = User.getSetting("filter_scroll_groups")

  if panel["options-menu"] == nil then
    local options_menu = GuiElement.add(panel, GuiFlowH("options-menu"))
    local options_left = GuiElement.add(options_menu, GuiFlowH("options-left"))
    GuiElement.add(options_left, GuiLabel("frame_title"):caption({"helmod_button.options"}):style("helmod_label_title_frame"))
    
    local options_right = GuiElement.add(options_menu, GuiFlowH("options-right"))
    options_right.style.horizontal_align = "right"
    options_right.style.horizontally_stretchable = true
    options_right.style.horizontal_spacing = 5
  end

  if panel["options-menu"] ~= nil then
    local options_right = panel["options-menu"]["options-right"]
    options_right.clear()

    local group_sroll = GuiElement.add(options_right, GuiFlowH("group_sroll"))
    group_sroll.style.horizontal_spacing = 2
    if filter_scroll_groups ~= false then
      GuiElement.add(group_sroll, GuiButton(self.classname, "change-sroll-groups", "true"):sprite("menu", defines.sprites.two_rows.black, defines.sprites.two_rows.black):style("helmod_button_menu_sm_selected"))
      GuiElement.add(group_sroll, GuiButton(self.classname, "change-sroll-groups", "false"):sprite("menu", defines.sprites.three_rows.black, defines.sprites.three_rows.black):style("helmod_button_menu_sm"))
    else
      GuiElement.add(group_sroll, GuiButton(self.classname, "change-sroll-groups", "true"):sprite("menu", defines.sprites.two_rows.black, defines.sprites.two_rows.black):style("helmod_button_menu_sm"))
      GuiElement.add(group_sroll, GuiButton(self.classname, "change-sroll-groups", "false"):sprite("menu", defines.sprites.three_rows.black, defines.sprites.three_rows.black):style("helmod_button_menu_sm_selected"))
    end
    
    local group_visible = GuiElement.add(options_right, GuiFlowH("group_visible"))
    group_visible.style.horizontal_spacing = 2
    if filter_options_visible ~= false then
      GuiElement.add(options_right, GuiButton(self.classname, "change-options-visibility"):sprite("menu", defines.sprites.arrow_top.black, defines.sprites.arrow_top.black):style("helmod_button_menu_sm"))
    else
      GuiElement.add(options_right, GuiButton(self.classname, "change-options-visibility"):sprite("menu", defines.sprites.arrow_bottom.black, defines.sprites.arrow_bottom.black):style("helmod_button_menu_sm"))
    end
  end

  if panel["filter-options"] == nil then
    local options_panel = GuiElement.add(panel, GuiFlowV("filter-options"))
    options_panel.visible = filter_options_visible ~= false

    if self.product_option then
      GuiElement.add(options_panel, GuiSwitch(self.classname, "recipe-filter-switch"):state("left"):leftLabel({"helmod_recipe-edition-panel.filter-by-product"}):rightLabel({"helmod_recipe-edition-panel.filter-by-ingredient"}))
    end

    ---switch language
    local switch_position = "left"
    if User.getModGlobalSetting("filter_translated_string_active") and User.getParameter("filter-language") ~= nil then
      switch_position = User.getParameter("filter-language")
    end
    local filter_switch = GuiElement.add(options_panel, GuiSwitch(self.classname, "filter-language-switch"):state(switch_position):rightLabel({"helmod_recipe-edition-panel.filter-language-switch-left"}, {"tooltip.filter-language-switch-left"}):leftLabel({"helmod_recipe-edition-panel.filter-language-switch-right"}, {"tooltip.filter-language-switch-right"}):tooltip({"helmod_recipe-edition-panel.filter-language-switch"}))
    if not(User.getModGlobalSetting("filter_translated_string_active")) then
      filter_switch.enabled = false
      filter_switch.switch_state = "right"
    end
    ---switch contain
    local contain_position = "left"
    if User.getParameter("filter-contain") ~= nil then
      contain_position = User.getParameter("filter-contain")
    end
    GuiElement.add(options_panel, GuiSwitch(self.classname, "filter-contain-switch"):state(contain_position):rightLabel({"helmod_recipe-edition-panel.filter-contain-switch-left"}, {"tooltip.filter-contain-switch-left"}):leftLabel({"helmod_recipe-edition-panel.filter-contain-switch-right"}, {"tooltip.filter-contain-switch-right"}):tooltip({"helmod_recipe-edition-panel.filter-contain-switch"}))

    ---filter table
    local filter_table = GuiElement.add(options_panel, GuiTable("filter"):column(2))
    filter_table.vertical_centering = true

    if self.disable_option then
      local filter_show_disable = User.getSetting("filter_show_disable")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_disable"):state(filter_show_disable))
      GuiElement.add(filter_table, GuiLabel("filter_show_disable"):caption({"helmod_recipe-edition-panel.filter-show-disable"}))
    end

    if self.hidden_option then
      local filter_show_hidden = User.getSetting("filter_show_hidden")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_hidden"):state(filter_show_hidden))
      GuiElement.add(filter_table, GuiLabel("filter_show_hidden"):caption({"helmod_recipe-edition-panel.filter-show-hidden"}))
    end

    if self.hidden_player_crafting then
      local filter_show_hidden_player_crafting = User.getSetting("filter_show_hidden_player_crafting")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_hidden_player_crafting"):state(filter_show_hidden_player_crafting))
      GuiElement.add(filter_table, GuiLabel("filter_show_hidden_player_crafting"):caption({"helmod_recipe-edition-panel.filter-show-hidden-player-crafting"}))
    end

    if self.unlock_recipe then
      local filter_show_lock_recipes = User.getSetting("filter_show_lock_recipes")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_lock_recipes"):state(filter_show_lock_recipes))
      GuiElement.add(filter_table, GuiLabel("filter_show_lock_recipes"):caption({"helmod_recipe-edition-panel.filter-show-lock-recipes"}))
    end

    if self.rules_filter then
      local filter_show_excludes_by_rules = User.getSetting("filter_show_excludes_by_rules")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_excludes_by_rules"):state(filter_show_excludes_by_rules))
      GuiElement.add(filter_table, GuiLabel("filter_show_excludes_by_rules"):caption({"helmod_recipe-edition-panel.filter-show-excludes-by-rules"}))
    end

    if Player.hasFeatureQuality() and self.is_support_quality then
      GuiElement.add(filter_table, GuiLabel("label-quality"):caption({ "helmod_label.quality" }))
      quality_selector_cell = GuiElement.add(filter_table, GuiFlowH("selector-quality"))
    end
    ---filter
    local filter_box_panel = GuiElement.add(panel, GuiFlowH("filter-box-panel"))

    local label_filter_value = GuiElement.add(filter_box_panel, GuiLabel("filter-value"):caption({"helmod_common.filter"}))
    label_filter_value.style.margin = {5,5,0,0}
    if User.getModGlobalSetting("filter_on_text_changed") then
      local text_filter = GuiElement.add(filter_box_panel, GuiTextField(self.classname, "recipe-filter", "filter-value=onchange"):text(filter_prototype):style("helmod_textfield_filter"))
      text_filter.lose_focus_on_confirm = false
      text_filter.focus()
    else
      GuiElement.add(filter_box_panel, GuiTextField(self.classname, "recipe-filter", "filter-text"):text(filter_prototype):style("helmod_textfield_filter"))
      GuiElement.add(filter_box_panel, GuiButton(self.classname, "recipe-filter", "filter-button"):caption({"helmod_button.apply"}))
    end

  end
  if self.product_option then
      local switch_by_product = "right"
      if self:getProductFilter() == true then switch_by_product = "left" end
      panel["filter-options"][self.classname.."=recipe-filter-switch"].switch_state = switch_by_product
      if filter_prototype ~= nil then
        if User.getModGlobalSetting("filter_on_text_changed") then
          panel["filter-box-panel"][self.classname.."=recipe-filter=filter-value=onchange"].text = filter_prototype
        else
          panel["filter-box-panel"][self.classname.."=recipe-filter=filter-text"].text = filter_prototype
        end
      end
  end
  ---the cell is shared by all selectors and players: use it only if it is alive and belongs to this player
  if Player.hasFeatureQuality() and self.is_support_quality and quality_selector_cell ~= nil
    and quality_selector_cell.valid and quality_selector_cell.player_index == Player.native().index then
    quality_selector_cell.clear()
    local current_quality = "normal"
    local selector_quality_prototype = User.getParameter("selector_quality_prototype")
    if selector_quality_prototype ~= nil then
      current_quality = selector_quality_prototype
    end
    GuiElement.addQualitySelector(quality_selector_cell, current_quality, self.classname, "quality-select")
  end
end

function AbstractSelector:rulesFilter(prototype, rules_excluded)
  if rules_excluded == nil then
    local rules_included
    rules_included, rules_excluded = Player.getRules("selector-filter")
  end
  local show = true
  ---resolve rule excluded
  show = Player.checkRules(show, rules_excluded, self.rule_category, prototype, false)
  return show
end

-------------------------------------------------------------------------------
---Create element lists
---@param event LuaEvent
---@return table
function AbstractSelector:createElementLists(event)
  local list_group_elements = self:getListGroupElements()
  local list_group = self:getListGroup()
  local list_subgroup = self:getListSubGroup()

  if table.size(list_group) == 0 and event.continue ~= true then
    local list = self:getListPrototype()
    local step_list = User.getModGlobalSetting("user_cache_step") or 100
    local index = 0
    local table_element = {}
    local query_list = {}
    event.continue = true
    ---list_products[element.name][type - lua_recipe.name]
    ---the name filter is cheap, apply it here so only matching keys are processed over the next ticks
    local matcher = self:getFilterMatcher()
    for key, element in pairs(list) do
      if matcher == nil or matcher(key) then
        if index % step_list == 0 then
          query_list = {index=index,list={}}
          table.insert(table_element, query_list)
        end
        query_list.list[key] = element
        index = index + 1
      end
    end
    event.table_element = table_element
    return User.createNextEvent(event, self.classname, "list")
  end
  ---execute loop
  if event.continue and event.method == "list" then
    if event.table_element ~= nil and #event.table_element > 0 then
      local filter_show_lock_recipes = User.getSetting("filter_show_lock_recipes")
      local filter_show_disable = User.getSetting("filter_show_disable")
      local filter_show_hidden = User.getSetting("filter_show_hidden")
      local filter_show_hidden_player_crafting = User.getSetting("filter_show_hidden_player_crafting")
      local filter_show_excludes_by_rules = User.getSetting("filter_show_excludes_by_rules")
      local query_list = table.remove(event.table_element)
      if query_list ~= nil then
        self:updateWaitMessage(string.format("Wait list build: %s", query_list.index or 0))

        ---rules are resolved once per step, not per element
        local rules_excluded = nil
        if self.rules_filter and filter_show_excludes_by_rules ~= true then
          local rules_included
          rules_included, rules_excluded = Player.getRules("selector-filter")
        end

        for key, element in pairs(query_list.list) do
          ---filter sur le nom element (product ou ingredient) deja applique lors du decoupage
          do
            for element_name, element in pairs(element) do
              local prototype = self:getPrototype(element)
              if (not(self.rules_filter) or (filter_show_excludes_by_rules == true or self:rulesFilter(prototype:native(), rules_excluded) == true)) and
                (not(self.unlock_recipe) or (filter_show_lock_recipes == true or prototype:getUnlock() == true)) and 
                (not(self.disable_option) or (filter_show_disable == true or prototype:getEnabled() == true)) and 
                (not(self.hidden_option) or (filter_show_hidden == true or prototype:getHidden() == false)) and
                (not(self.hidden_player_crafting) or (filter_show_hidden_player_crafting == true or prototype:getHiddenPlayerCrafting() == false)) then

                if list_group_elements[element.group] == nil then list_group_elements[element.group] = {} end
                if list_group_elements[element.group][element.subgroup] == nil then list_group_elements[element.group][element.subgroup] = {} end
                list_group_elements[element.group][element.subgroup][element_name] = element

                if list_group[element.group] == nil then list_group[element.group] = prototype:getGroup() end
                if list_subgroup[element.subgroup] == nil then list_subgroup[element.subgroup] = prototype:getSubgroup() end
              end
            end
          end
        end
        User.setCache(self.classname, "list_group", list_group)
        User.setCache(self.classname, "list_subgroup", list_subgroup)
        User.setCache(self.classname, "list_group_elements", list_group_elements)
      end
    end
    if event.table_element ~= nil and #event.table_element > 0 then
      return User.createNextEvent(event, self.classname, "list")
    else
      event.continue = false
    end
  end
  
  local list_item = self:getListItem()
  local group_selected = User.getParameter("recipe_group_selected")
  local list_group = self:getListGroup()

  if list_group_elements[group_selected] then
    list_item = list_group_elements[group_selected]
  else
    local group_selected,_ = next(list_group)
    User.setParameter("recipe_group_selected", group_selected)
    list_item = list_group_elements[group_selected]
  end
  User.setCache(self.classname, "list_item", list_item or {})
  event.continue = false

  return User.createNextEvent(nil, self.classname, "list")
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function AbstractSelector:getPrototype(element, type)
end

-------------------------------------------------------------------------------
---Append groups
---@param element string
---@param type string
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function AbstractSelector:appendGroups(element, type, list_products, list_ingredients, list_translate)
  local prototype = self:getPrototype(element)
  local lua_prototype = prototype:native()

  if list_ingredients[lua_prototype.name] == nil then list_ingredients[lua_prototype.name] = {} end
  list_ingredients[lua_prototype.name][lua_prototype.name] = {name=lua_prototype.name, group=prototype:getGroup().name, subgroup=prototype:getSubgroup().name, type=type, order=lua_prototype.order}

  if lua_prototype.localised_name ~= nil then
    list_translate[element.name] = lua_prototype.localised_name
  end

end

-------------------------------------------------------------------------------
---Update wait message
---@param message string
function AbstractSelector:updateWaitMessage(message)
  local panel = self:getGroupsPanel()
  local item_list_panel = self:getItemListPanel()
  ---called on every build step: update the existing label instead of recreating it
  local wait_label = item_list_panel["wait-step-message"]
  if wait_label ~= nil and wait_label.valid and #item_list_panel.children_names == 1 then
    wait_label.caption = message
    return
  end
  item_list_panel.clear()
  GuiElement.add(item_list_panel, GuiLabel("wait-step-message"):caption(message))
end

-------------------------------------------------------------------------------
---Update fail message
---@param message string
function AbstractSelector:updateFailMessage(message)
  local panel = self:getGroupsPanel()
  local item_list_panel = self:getItemListPanel()
  item_list_panel.clear()
  GuiElement.add(item_list_panel, GuiLabel("wait message"):caption(message):fail())
end

-------------------------------------------------------------------------------
---Update item list
---@param event LuaEvent
function AbstractSelector:updateItemList(event)
  local item_list_panel = self:getItemListPanel()
  item_list_panel.clear()
  local list_subgroup = self:getListSubGroup()
  local list_item = self:getListItem()
  
  ---recuperation recipes et subgroupes
  local recipe_selector_list = GuiElement.add(item_list_panel, GuiFlowV("recipe_list"))
  if table.size(list_item) > 0 then
    ---read the subgroup orders once instead of in every sort comparison (game objects)
    local subgroup_orders = {}
    for subgroup, _ in pairs(list_item) do
      local lua_subgroup = list_subgroup[subgroup]
      subgroup_orders[subgroup] = lua_subgroup and lua_subgroup["order"]
    end
    for subgroup, list in spairs(list_item, function(t,a,b) return subgroup_orders[b] > subgroup_orders[a] end) do
      ---boucle subgroup
      local guiRecipeSubgroup = GuiElement.add(recipe_selector_list, GuiTable("recipe-table-", subgroup):column(10):style("helmod_table_recipe_selector"))
      for key, prototype in spairs(list,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
        local tooltip = self:buildPrototypeTooltip(prototype)
        self:buildPrototypeIcon(guiRecipeSubgroup, prototype, tooltip)
      end
    end
  else
    event.message = "Empty list"
    Dispatcher:send("on_gui_message", event, self.classname)
  end

end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function AbstractSelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local tooltip = ""
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function AbstractSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "recipe-select"):sprite(prototype.type, prototype.name):tooltip(tooltip))
end

-------------------------------------------------------------------------------
---Update group selector
---@param event LuaEvent
function AbstractSelector.updateGroupSelector(self, event)
  local panel = self:getGroupsPanel()

  panel.clear()
  local list_group = self:getListGroup()

  ---ajouter de la table des groupes de recipe
  local gui_group_panel = GuiElement.add(panel, GuiTable("recipe-groups"):column(6):style("helmod_table_recipe_selector"))

  ---read the group orders once instead of in every sort comparison (game objects)
  local group_orders = {}
  for key, group in pairs(list_group) do
    group_orders[key] = group["order"]
  end
  local group_selected = User.getParameter("recipe_group_selected")
  for _, group in spairs(list_group,function(t,a,b) return group_orders[b] > group_orders[a] end) do
    local group_name = group.name
    ---set le groupe
    if group_selected == nil then
      group_selected = group_name
      User.setParameter("recipe_group_selected", group_name)
    end
    local color = nil
    if group_selected == group_name then
      color = "yellow"
    end
    local tooltip
    if group_name == "helmod" then
      tooltip = "Helmod"
    else
      tooltip = group.localised_name
    end

    ---ajoute les icons de groupe
    local action = GuiElement.add(gui_group_panel, GuiButtonSelectSpriteXxl(self.classname, "recipe-group"):sprite(self.sprite_type, group_name):tooltip(tooltip):color(color))
  end

end
