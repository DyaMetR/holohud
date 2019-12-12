--[[------------------------------------------------------------------
  CONFIGURATION MENU
  Elements configuration editor
]]--------------------------------------------------------------------

if CLIENT then

  -- Currently cached options panels
  local options = {};

  --[[
    Creates an element configuration header
    @param {string} id
    @return {Panel} panel
  ]]
  local HEADER_H = 71;
  local SAVE_TEXTURE, RESET_TEXTURE = "icon16/disk.png", "icon16/arrow_refresh.png";
  local function ConfigHeader(width, id)
    local panel = vgui.Create("DPanel");
    panel:SetSize(width, HEADER_H);
    panel.Paint = function() end;

    local lblTitle = vgui.Create("DLabel", panel);
    lblTitle:SetPos(5, 3);
    lblTitle:SetFont("Trebuchet24");
    lblTitle:SetText(HOLOHUD.ELEMENTS:GetElement(id).title);
    lblTitle:SizeToContents();

    local lblSubtitle = vgui.Create("DLabel", panel);
    lblSubtitle:SetPos(5, 30);
    lblSubtitle:SetFont("DermaDefaultBold");
    lblSubtitle:SetText(HOLOHUD.ELEMENTS:GetElement(id).subtitle);
    lblSubtitle:SizeToContents();

    local chxEnabled = vgui.Create("DCheckBox", panel);
    chxEnabled:SetPos(10, 54);
    chxEnabled:SetSize(14, 14);
    chxEnabled:SetChecked(HOLOHUD.ELEMENTS:IsElementEnabled(id));
    chxEnabled.OnChange = function(value) HOLOHUD.ELEMENTS:ToggleElement(id, value:GetChecked(), true); end;

    local lblCheck = vgui.Create("DLabel", panel);
    lblCheck:SetPos(30, 54);
    lblCheck:SetText("Enabled");
    lblCheck:SizeToContents();

    local btnSave = vgui.Create("DImageButton", panel);
    btnSave:SetSize(16, 16);
    btnSave:SetPos(panel:GetWide() - 31, 51);
    btnSave:SetTooltip("Save configuration");
    btnSave:SetImage(SAVE_TEXTURE);
    btnSave.DoClick = function()
      HOLOHUD.ELEMENTS:SaveUserConfiguration(id);
      surface.PlaySound("buttons/button24.wav");
    end;

    local btnReset = vgui.Create("DImageButton", panel);
    btnReset:SetSize(16, 16);
    btnReset:SetPos(panel:GetWide() - 52, 51);
    btnReset:SetTooltip("Reset to default");
    btnReset:SetImage(RESET_TEXTURE);
    btnReset.DoClick = function()
      -- Reset panels options
      for _, option in pairs(options) do
        if (option.ResetToDefault ~= nil) then
          option:ResetToDefault();
        end
      end

      -- Reset configuration
      HOLOHUD.ELEMENTS:DeleteElementUserData(id);

      -- Play sound
      surface.PlaySound("buttons/button9.wav");
    end;

    return panel;
  end

  --[[
    Generates an option panel template
    @param {number} width
    @param {number} height
    @param {string} title
    @return {Panel} panel
  ]]
  local function OptionTemplate(width, height, title, desc)
    local panel = vgui.Create("DPanel");
    panel:SetSize(width, height);
    panel.Paint = function() end;

    local lblTitle = vgui.Create("DLabel", panel);
    lblTitle:SetPos(5, 5);
    lblTitle:SetFont("HudHintTextLarge");
    lblTitle:SetText(title);
    lblTitle:SizeToContents();

    -- Add tool tip
    if (desc ~= nil and string.len(desc) > 0) then
      panel:SetTooltip(desc);
    end

    return panel;
  end

  --[[
    Returns a panel with a number based config panel
    @param {number} width
    @param {string} id
    @param {string} config
    @return {Panel} panel
  ]]
  local function NumberConfig(width, id, config)
    local defaultConfig = HOLOHUD.ELEMENTS:GetElementDefaultConfig(id)[config];
    local w = width * 0.5;
    local panel = OptionTemplate(w, 53, defaultConfig.name, defaultConfig.desc);
    local num = vgui.Create("DNumberWang", panel);
    num:SetPos(7, 25);
    num:SetSize(w - 14, 20);
    num:SetValue(HOLOHUD.ELEMENTS:GetElementUserConfigParam(id, config));
    num.OnValueChanged = function(value)
      HOLOHUD.ELEMENTS:ChangeElementConfiguration(id, config, value:GetValue(1));
    end

    panel.ResetToDefault = function() num:SetValue(defaultConfig.value); end;

    return panel;
  end

  --[[
    Returns a panel with a number slider based config panel
    @param {number} width
    @param {string} id
    @param {string} config
    @return {Panel} panel
  ]]
  local function SliderConfig(width, id, config)
    local w = width * 0.5;
    local defaultConfig = HOLOHUD.ELEMENTS:GetElementDefaultConfig(id)[config];
    local panel = OptionTemplate(w, 53, defaultConfig.name, defaultConfig.desc);
    local num = vgui.Create("DNumSlider", panel);
    num:SetPos(-70, 25);
    num:SetSize(w + 65, 20);
    num:SetMax(defaultConfig.maxValue);
    num:SetMin(defaultConfig.minValue or 0);
    num:SetValue(HOLOHUD.ELEMENTS:GetElementUserConfigParam(id, config));
    num.OnValueChanged = function(self)
      HOLOHUD.ELEMENTS:ChangeElementConfiguration(id, config, self:GetValue(1));
    end

    panel.ResetToDefault = function() num:SetValue(defaultConfig.value); end;

    return panel;
  end

  --[[
    Returns a panel with a text entry
    @param {number} width
    @param {string} id
    @param {string} config
    @return {Panel} panel
  ]]
  local function StringConfig(width, id, config)
    local defaultConfig = HOLOHUD.ELEMENTS:GetElementDefaultConfig(id)[config];
    local w = width * 0.5;
    local panel = OptionTemplate(w, 53, defaultConfig.name, defaultConfig.desc);
    local text = vgui.Create("DTextEntry", panel);
    text:SetPos(7, 25);
    text:SetSize(w - 14, 20);
    text:SetValue(HOLOHUD.ELEMENTS:GetElementUserConfigParam(id, config));
    text.OnEnter = function(self)
      HOLOHUD.ELEMENTS:ChangeElementConfiguration(id, config, self:GetValue());
    end

    panel.ResetToDefault = function() text:SetValue(defaultConfig.value); end;

    return panel;
  end

  --[[
    Returns a panel with a combo box
    @param {number} width
    @param {string} id
    @param {string} config
    @return {Panel} panel
  ]]
  local function SelectConfig(width, id, config)
    local w = width * 0.5;
    local defaultConfig = HOLOHUD.ELEMENTS:GetElementDefaultConfig(id)[config];
    local panel = OptionTemplate(w, 53, defaultConfig.name, defaultConfig.desc);
    local cbox = vgui.Create("DComboBox", panel);
    cbox:SetPos(7, 25);
    cbox:SetSize(w - 14, 20);

    for k, label in pairs(defaultConfig.options) do
      cbox:AddChoice(label, k);
    end

    cbox:SetValue(defaultConfig.options[HOLOHUD.ELEMENTS:GetElementUserConfigParam(id, config)]);
    cbox.OnSelect = function(self, index, value)
      HOLOHUD.ELEMENTS:ChangeElementConfiguration(id, config, index);
    end

    panel.ResetToDefault = function() cbox:SetValue(defaultConfig.options[defaultConfig.value]); end;

    return panel;
  end

  --[[
    Returns a panel with a colour picker
    @param {number} width
    @param {string} id
    @param {string} config
    @return {Panel} panel
  ]]
  local function ColourConfig(width, id, config)
    local defaultConfig = HOLOHUD.ELEMENTS:GetElementDefaultConfig(id)[config];
    local w = width * 0.5;
    local panel = OptionTemplate(w, 180, defaultConfig.name, defaultConfig.desc);
    local picker = vgui.Create("DColorMixer", panel);
    picker:SetPos(5, 30);
    picker:SetSize(panel:GetWide() - 10, panel:GetTall() - 40);
    picker:SetAlphaBar(false);
    picker:SetColor(HOLOHUD.ELEMENTS:GetElementUserConfigParam(id, config));
    picker.ValueChanged = function(colour)
      HOLOHUD.ELEMENTS:ChangeElementConfiguration(id, config, colour:GetColor());
    end

    panel.ResetToDefault = function() picker:SetColor(defaultConfig.value); end;

    return panel;
  end

  --[[
    Returns a panel with a check box
    @param {number} width
    @param {string} id
    @param {string} config
    @return {Panel} panel
  ]]
  local function ToggleConfig(width, id, config)
    local defaultConfig = HOLOHUD.ELEMENTS:GetElementDefaultConfig(id)[config];
    local w = width * 0.5;
    local panel = OptionTemplate(w, 43, defaultConfig.name, defaultConfig.desc);
    local checkbox = vgui.Create("DCheckBox", panel);
    checkbox:SetPos(10, 28);
    checkbox:SetSize(14, 14);
    checkbox:SetValue(HOLOHUD.ELEMENTS:GetElementUserConfigParam(id, config));
    checkbox.OnChange = function(self)
      HOLOHUD.ELEMENTS:ChangeElementConfiguration(id, config, self:GetChecked());
    end

    local label = vgui.Create("DLabel", panel);
    label:SetPos(30, 28);
    label:SetText("Enabled");
    label:SizeToContents();

    panel.ResetToDefault = function() checkbox:SetValue(defaultConfig.value); end;

    return panel;
  end

  --[[
    Generates a configuration panel for an element
    @param {Panel} parent
    @param {string} id
    @void
  ]]
  local function GenerateConfigurationPanel(header, parent, id)
    -- Render static header
    header:Clear();
    header:Add(ConfigHeader(header:GetWide(), id));

    -- Render scrollable options panel
    parent:Clear();
    local panel = nil;

    local defaultConfig = HOLOHUD.ELEMENTS:GetElementDefaultConfig(id);
    if (defaultConfig ~= nil) then
      for param, config in SortedPairs(defaultConfig) do
        if (type(config.value) == "number" and config.options == nil) then
          if (config.maxValue ~= nil) then
            panel = SliderConfig(parent:GetWide(), id, param);
          else
            panel = NumberConfig(parent:GetWide(), id, param);
          end
        elseif (type(config.value) == "string") then panel = StringConfig(parent:GetWide(), id, param);
        elseif (IsColor(config.value)) then panel = ColourConfig(parent:GetWide(), id, param);
        elseif (config.options ~= nil) then panel = SelectConfig(parent:GetWide(), id, param);
        elseif (type(config.value) == "boolean") then panel = ToggleConfig(parent:GetWide(), id, param);
        end

        if (panel ~= nil) then
          table.insert(options, panel);
          parent:Add(panel);
        end
      end
    end
  end

  --[[
    Creates the elements menu
    @param {Panel} frame
    @void
  ]]
  local GENERAL_OFFSET = 25; -- Space for general options
  function HOLOHUD.MENU:Elements(frame)

    -- Element list
    local list = vgui.Create("DListView", frame);
    list:SetPos(0, GENERAL_OFFSET);
    list:SetSize(frame:GetWide() * 0.3, frame:GetTall() - 36 - GENERAL_OFFSET);
    list:AddColumn("Select to display settings");

    -- List all elements
    for id, element in SortedPairs(HOLOHUD.ELEMENTS:GetElements()) do
      list:AddLine(element.title, id);
    end

    -- General options
    local label = vgui.Create("DLabel", frame);
    label:SetPos(2, 3);
    label:SetText("Current layout options");
    label:SetFont("DermaDefaultBold");
    label:SizeToContents();

    local btnSave = vgui.Create("DImageButton", frame);
    btnSave:SetSize(16, 16);
    btnSave:SetPos(list.x + list:GetWide() - 38, 2);
    btnSave:SetTooltip("Save current layout");
    btnSave:SetImage(SAVE_TEXTURE);
    btnSave.DoClick = function()
      print(HOLOHUD.CONFIG.Signature .. " Saving current layout...");
      -- Persist current configuration
      for id, _ in pairs(HOLOHUD.ELEMENTS.ElementData) do
        HOLOHUD.ELEMENTS:SaveUserConfiguration(id, true);
      end
      print(HOLOHUD.CONFIG.Signature .. " Done.");
      surface.PlaySound("buttons/button24.wav");
    end;

    local btnReset = vgui.Create("DImageButton", frame);
    btnReset:SetSize(16, 16);
    btnReset:SetPos(list.x + list:GetWide() - 18, 2);
    btnReset:SetTooltip("Reset all elements' settings to default");
    btnReset:SetImage(RESET_TEXTURE);
    btnReset.DoClick = function()
      print(HOLOHUD.CONFIG.Signature .. " Removing current layout configuration...");
      -- Persist current configuration
      for id, _ in pairs(HOLOHUD.ELEMENTS.ElementData) do
        HOLOHUD.ELEMENTS:DeleteElementUserData(id, true);
      end
      print(HOLOHUD.CONFIG.Signature .. " Done.");
      surface.PlaySound("buttons/button9.wav");
    end;

    -- Configuration panel
    local header = vgui.Create("DPanel", frame);
    header:SetPos(5 + list:GetWide(), 0);
    header:SetSize(frame:GetWide() - header.x - 8, HEADER_H);
    header.Paint = function() end;

    local scroll = vgui.Create("DScrollPanel", frame);
    scroll:SetPos(header.x, 5 + header:GetTall());
    scroll:SetSize(frame:GetWide() - scroll.x - 16, frame:GetTall() - header:GetTall() - 41);

    local panel = vgui.Create("DIconLayout", scroll);
    panel:SetSize(scroll:GetWide() - 15, scroll:GetTall());

    -- Generate configuration panel after clicking an element
    options = {};
    list.OnRowSelected = function(pnl, index, row)
      GenerateConfigurationPanel(header, panel, row:GetValue(2));
    end
  end

end
