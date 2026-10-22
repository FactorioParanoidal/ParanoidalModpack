-------------------------------------------------------------------------------
---Class to build quality dialog
---@class QualityPanel
QualityPanel = newclass(Form)

-------------------------------------------------------------------------------
---On initialization
function QualityPanel:onInit()
    self.panelCaption = {"helmod_quality-panel.title"}
    self.otherClose = false
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function QualityPanel:onStyle(styles, width_main, height_main)
    -- Paranoidal: fixed-size window; the probability list scrolls vertically only.
    local width = math.min(480, math.floor(width_main * 0.9))
    local height = math.min(820, math.floor(height_main * 0.85))
    styles.flow_panel = {
        width = width,
        minimal_width = width,
        maximal_width = width,
        height = height,
        minimal_height = height,
        maximal_height = height
    }
end

------------------------------------------------------------------------------
---Get Button Sprites
---@return string, string
function QualityPanel:getButtonSprites()
    return defines.sprites.jewel.white, defines.sprites.jewel.black
end

-------------------------------------------------------------------------------
---Is tool
---@return boolean
function QualityPanel:isTool()
    return Player.hasFeatureQuality()
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function QualityPanel:onUpdate(event)
    self:updateQualityModules(event)
    self:updateQualityCalculation(event)
end

-------------------------------------------------------------------------------
---Update input
---@param event LuaEvent
function QualityPanel:updateQualityModules(event)
    local modules_panel = self:getFramePanel("modules-panel")
    modules_panel.clear()

    local analyze_module_quality = User.getParameter("analyze_module_quality") or "normal"
    local quality_panel = GuiElement.addQualitySelector(modules_panel, analyze_module_quality, self.classname, "module-quality-select")
    quality_panel.style.bottom_margin = 5

    local analyze_module_name = QualityPanel.getModuleName()
    local table_panel = GuiElement.add(modules_panel, GuiTable("table_panel"):column(10))
    for _, lua_module in pairs(QualityPanel.getQualityModules()) do
        local style = defines.styles.button.select_icon
        if lua_module.name == analyze_module_name then
            style = defines.styles.button.select_icon_green
        end
        local button = GuiElement.add(table_panel, GuiButtonSelectSprite(self.classname, "module-select"):choose_with_quality("item", lua_module.name, analyze_module_quality):style(style))
        button.locked = true
    end

    local table_input = GuiElement.add(modules_panel, GuiTable("table-input"):column(2))

    local analyze_module_amount = User.getParameter("analyze_module_amount") or 4
    GuiElement.add(table_input, GuiLabel("label-module-amount"):caption({"helmod_quality-panel.module-amount"}))
    GuiElement.add(table_input, GuiTextField(self.classname, "change-module-amount"):text(analyze_module_amount):style("helmod_textfield"))

    local analyze_bonus_probability = User.getParameter("analyze_bonus_probability") or 0
    GuiElement.add(table_input, GuiLabel("label-bonus-probability"):caption({"helmod_quality-panel.bonus-probability"}))
    GuiElement.add(table_input, GuiTextField(self.classname, "change-bonus-probability"):text(analyze_bonus_probability):style("helmod_textfield"))

    if QualityPanel.hasMachineModes() then
        local items = {}
        local selected_index = 1
        local current = QualityPanel.getMachineMode()
        for index, mode in ipairs(QualityPanel.machine_modes) do
            items[index] = {"", mode.roman, ". ", {"ic-quality.mode-" .. mode.name}}
            if mode.name == current.name then selected_index = index end
        end
        GuiElement.add(table_input, GuiLabel("label-machine-mode"):caption({"helmod_quality-panel.machine-mode"}):tooltip({"helmod_quality-panel.machine-mode-tooltip"}))
        local selector = GuiElement.add(table_input, GuiDropDown(self.classname, "change-machine-mode"):items(items))
        selector.selected_index = selected_index
    end
end

-------------------------------------------------------------------------------
---Paranoidal: production modes of ic-more-qualities (scripts/expansion/rules.lua M.modes):
---the quality-module roll counts as `boost` independent rolls, 1 - (1 - p)^boost.
QualityPanel.machine_modes = {
    {name = "normal", roman = "I", boost = 1},
    {name = "careful", roman = "II", boost = 3},
    {name = "precise", roman = "III", boost = 10},
}

---@return boolean
function QualityPanel.hasMachineModes()
    if not (script.active_mods["ic-more-qualities"] and prototypes.mod_data) then return false end
    local ok, data = pcall(function() return prototypes.mod_data["ic-quality-expansion"] end)
    return ok and data ~= nil
end

---@return table
function QualityPanel.getMachineMode()
    local name = User.getParameter("analyze_machine_mode")
    if QualityPanel.hasMachineModes() then
        for _, mode in ipairs(QualityPanel.machine_modes) do
            if mode.name == name then return mode end
        end
    end
    return QualityPanel.machine_modes[1]
end

-------------------------------------------------------------------------------
---Paranoidal: modules with a positive quality effect, without god modules
---@return table
function QualityPanel.getQualityModules()
    local modules = {}
    for _, lua_module in pairs(Player.getModules()) do
        local name = lua_module.name
        local is_god = string.find(name, "god-module", 1, true) ~= nil
        local effects = lua_module.get_module_effects("normal") or {}
        if not is_god and (effects.quality or 0) > 0 then
            table.insert(modules, lua_module)
        end
    end
    return modules
end

-------------------------------------------------------------------------------
---Paranoidal: selected module, falls back to the first allowed one
---@return string|nil
function QualityPanel.getModuleName()
    local modules = QualityPanel.getQualityModules()
    local selected = User.getParameter("analyze_module_name")
    for _, lua_module in pairs(modules) do
        if lua_module.name == selected then return selected end
    end
    return modules[1] and modules[1].name or nil
end

-------------------------------------------------------------------------------
---Paranoidal: percent text, 4 decimals max, tiny values as "<0.0001%"
---@param value number --probability 0..1
---@return string
function QualityPanel.formatPercent(value)
    if value <= 0 then return "0%" end
    local percent = value * 100
    if percent < 0.0001 then return "<0.0001%" end
    local text = string.format("%.4f", percent):gsub("0+$", ""):gsub("%.$", "")
    return text .. "%"
end

-------------------------------------------------------------------------------
---Paranoidal: output distribution for one input quality, as the engine rolls it:
---first upgrade = quality effect x next_probability of the input quality,
---every further tier = next_probability of the tier reached.
---@param lua_quality LuaQualityPrototype
---@param quality_effect number --raw effect (tooltip % / 10)
---@param boost number|nil --equivalent independent rolls of the machine mode (default 1)
---@return table --{[0]=stay, [1]=+1, [2]=+2, [3]=+3 and above}
function QualityPanel.computeDistribution(lua_quality, quality_effect, boost)
    local reach = {}
    local next_quality = lua_quality.next
    local chance = 0
    if next_quality ~= nil and (lua_quality.next_probability or 0) > 0 then
        chance = math.max(0, math.min(1, quality_effect * lua_quality.next_probability))
        if boost ~= nil and boost > 1 and chance < 1 then
            chance = 1 - (1 - chance) ^ boost
        end
    end
    reach[1] = chance
    local current = next_quality
    for step = 2, 3 do
        if current ~= nil and current.next ~= nil and (current.next_probability or 0) > 0 then
            reach[step] = reach[step - 1] * current.next_probability
            current = current.next
        else
            reach[step] = 0
            current = nil
        end
    end
    return {
        [0] = 1 - reach[1],
        [1] = reach[1] - reach[2],
        [2] = reach[2] - reach[3],
        [3] = reach[3],
    }
end

-------------------------------------------------------------------------------
---Update calculation
---@param event LuaEvent
function QualityPanel:updateQualityCalculation(event)
    -- Paranoidal: one row per positive input quality (defects excluded), vertical scroll only.
    local calculation_panel = self:getFramePanel("calculation-panel")
    calculation_panel.style.vertically_stretchable = true
    calculation_panel.clear()

    local analyze_module_name = QualityPanel.getModuleName()
    if analyze_module_name == nil then return end
    local analyze_module_quality = User.getParameter("analyze_module_quality") or "normal"
    if Player.getQualityPrototype(analyze_module_quality) == nil or Player.isDefectQuality(analyze_module_quality) then
        analyze_module_quality = "normal"
    end
    local analyze_module_amount = tonumber(User.getParameter("analyze_module_amount")) or 4
    local analyze_bonus_probability = tonumber(User.getParameter("analyze_bonus_probability")) or 0

    local module_effects = prototypes.item[analyze_module_name].get_module_effects(analyze_module_quality) or {}
    -- Raw engine value: the tooltip shows it x10 as "%" (raw 0.5 = "+5%").
    local quality_effect = (module_effects.quality or 0) * analyze_module_amount + analyze_bonus_probability / 10
    if quality_effect < 0 then quality_effect = 0 end

    local machine_mode = QualityPanel.getMachineMode()
    local mode_note = {"helmod_quality-panel.mode-none"}
    if QualityPanel.hasMachineModes() then
        mode_note = {"helmod_quality-panel.mode-note", {"", machine_mode.roman, ". ", {"ic-quality.mode-" .. machine_mode.name}}}
    end
    local header = GuiElement.add(calculation_panel, GuiLabel("label-module"):caption({"helmod_quality-panel.chance-header", QualityPanel.formatPercent(quality_effect / 10), mode_note}))
    header.style.single_line = false
    header.style.bottom_margin = 4

    local scroll_panel = calculation_panel.add({type = "scroll-pane", name = "scroll-panel", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto-and-reserve-space"})
    scroll_panel.style.horizontally_stretchable = true
    scroll_panel.style.vertically_stretchable = true

    local style = defines.styles.button.select_icon_flat
    local table_list = GuiElement.add(scroll_panel, GuiTable("table-list"):column(5):style("helmod_table_border"))
    GuiElement.add(table_list, GuiLabel("col-input"):caption({"helmod_quality-panel.col-input"}))
    GuiElement.add(table_list, GuiLabel("col-stay"):caption({"helmod_quality-panel.col-stay"}))
    GuiElement.add(table_list, GuiLabel("col-plus1"):caption({"helmod_quality-panel.col-plus1"}))
    GuiElement.add(table_list, GuiLabel("col-plus2"):caption({"helmod_quality-panel.col-plus2"}))
    GuiElement.add(table_list, GuiLabel("col-plus3"):caption({"helmod_quality-panel.col-plus3"}))

    for row_key, lua_quality in pairs(Player.getQualityPrototypesWithoutHidden()) do
        local distribution = QualityPanel.computeDistribution(lua_quality, quality_effect, machine_mode.boost)
        GuiElement.add(table_list, GuiButton("row", lua_quality.name):sprite("quality", lua_quality.name):style(style):tooltip(lua_quality.localised_name))
        for step = 0, 3 do
            GuiElement.add(table_list, GuiLabel("value", row_key, step):caption(QualityPanel.formatPercent(distribution[step])))
        end
    end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function QualityPanel:onEvent(event)
    if event.action == "module-select" then
        local analyze_module_name = event.item1
        User.setParameter("analyze_module_name", analyze_module_name)
        self:onUpdate(event)
    end

    if event.action == "module-quality-select" then
        local analyze_module_quality = event.item1
        User.setParameter("analyze_module_quality", analyze_module_quality)
        self:onUpdate(event)
    end

    if event.action == "change-module-amount" then
        local text = event.element.text
        local analyze_module_amount = formula(text)
        User.setParameter("analyze_module_amount", analyze_module_amount)
        self:onUpdate(event)
    end

    if event.action == "change-machine-mode" then
        local mode = QualityPanel.machine_modes[event.element.selected_index]
        if mode ~= nil then
            User.setParameter("analyze_machine_mode", mode.name)
        end
        self:onUpdate(event)
    end

    if event.action == "change-bonus-probability" then
        local text = event.element.text
        local analyze_bonus_probability = formula(text)
        User.setParameter("analyze_bonus_probability", analyze_bonus_probability)
        self:onUpdate(event)
    end
end
