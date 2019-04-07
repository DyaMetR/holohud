--[[------------------------------------------------------------------
  FONT MENU
  Font configuration and presets menu
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local RESET_TEXTURE, SAVE_TEXTURE, DELETE_TEXTURE, LOAD_TEXTURE = "icon16/arrow_refresh.png", "icon16/disk.png", "icon16/delete.png", "icon16/layout_add.png";
  local HEADER_H = 60;

  --[[
    Generates a text entry to edit a font family
    @param {string} font
    @void
  ]]
  local function GenerateFontTextEntry(font, width)
    local x, y = HOLOHUD.CONFIG.FONTS:GetFontOffset(font);

    local panel = vgui.Create("DPanel");
    panel:SetSize(width, 48);
    panel.Paint = function() end;

    local label = vgui.Create("DLabel", panel);
    label:SetPos(4, 2);
    label:SetFont("DermaDefaultBold");
    label:SetText(HOLOHUD.Fonts[font].title);
    label:SizeToContents();

    local text = vgui.Create("DTextEntry", panel);
    text:SetPos(2, 20);
    text:SetSize(width - 97, 20);
    text:SetText(HOLOHUD.CONFIG.FONTS:GetFontFamily(font) or "");

    local lblx = vgui.Create("DLabel", panel);
    lblx:SetPos(text.x + text:GetWide() + 1, text.y + 3);
    lblx:SetFont("HudHintTextLarge");
    lblx:SetText("X");
    lblx:SizeToContents();

    local nmx = vgui.Create("DNumberWang", panel);
    nmx:SetPos(lblx.x + lblx:GetWide() + 3, text.y);
    nmx:SetSize(30, 20);
    nmx:SetMin(-ScrW());
    nmx:SetMax(ScrW());
    nmx:SetValue(x);

    local lbly = vgui.Create("DLabel", panel);
    lbly:SetPos(nmx.x + nmx:GetWide() + 1, text.y + 3);
    lbly:SetFont("HudHintTextLarge");
    lbly:SetText("Y");
    lbly:SizeToContents();

    local nmy = vgui.Create("DNumberWang", panel);
    nmy:SetPos(lbly.x + lbly:GetWide() + 3, nmx.y);
    nmy:SetSize(30, 20);
    nmy:SetMin(-ScrH());
    nmy:SetMax(ScrH());
    nmy:SetValue(y);

    text.OnEnter = function()
      HOLOHUD.CONFIG.FONTS:ApplyFontConfiguration(font, text:GetValue(1), nmx:GetValue(1), nmy:GetValue(1));
    end;
    nmx.OnValueChanged = function(value) HOLOHUD.CONFIG.FONTS:ApplyNewFontOffset(font, nmx:GetValue(1), nmy:GetValue(1)) end;
    nmy.OnValueChanged = nmx.OnValueChanged;

    local reset = vgui.Create("DImageButton", panel);
    reset:SetPos(width - 24, 3);
    reset:SetSize(14, 14);
    reset:SetImage(RESET_TEXTURE);
    reset:SetTooltip("Reset to default");
    reset.DoClick = function()
      HOLOHUD.CONFIG.FONTS:ResetFontToDefault(font);
      text:SetText(HOLOHUD.CONFIG.FONTS:GetFontFamily(font) or "");
      nmx:SetValue(0);
      nmy:SetValue(0);
    end;

    return panel;
  end

  --[[
    Fills an icon layout with font options
    @param {Panel} icon layout
    @void
  ]]
  local function UpdateFontList(list)
    list:Clear();
    for i = 1, table.Count(HOLOHUD.Fonts) do
      list:Add(GenerateFontTextEntry(HOLOHUD:GetFontByPosition(i), list:GetWide()));
    end
  end

  --[[
    Fills a list view with the font presets
    @param {Panel} list view
    @void
  ]]
  local function UpdatePresetList(list)
    list:Clear();
    for name, _ in pairs(HOLOHUD.CONFIG.FONTS:GetFontPresets()) do
      list:AddLine(name);
    end
  end

  --[[
    Returns a panel with an image button described with a label
    @param {Panel} parent
    @param {string} label
    @param {string} icon
    @param {function} func
    @return {Panel} panel
  ]]
  local function GenerateButtonOption(parent, label, tooltip, icon, func)
    local panel = vgui.Create("DPanel", parent);
    panel.Paint = function() end;

    local btnIco = vgui.Create("DImageButton", panel);
    btnIco:SetSize(14, 14);
    btnIco:SetTooltip(tooltip);
    btnIco:SetImage(icon);
    btnIco.DoClick = func;

    local lblDesc = vgui.Create("DLabel", panel);
    lblDesc:SetPos(20, 0);
    lblDesc:SetText(label);
    lblDesc:SetTextColor(Color(255, 255, 255));
    lblDesc:SizeToContents();

    panel:SetSize(btnIco:GetWide() + lblDesc:GetWide() + 6, 20);

    return panel;
  end

  --[[
    Creates the fonts menu
    @param {Panel} frame
    @void
  ]]
  function HOLOHUD.MENU:Fonts(frame)
    -- Header
    local lblGen = vgui.Create("DLabel", frame);
    lblGen:SetPos(3, 5);
    lblGen:SetFont("HudHintTextLarge");
    lblGen:SetText("Apply a single font family to all fonts");
    lblGen:SizeToContents();

    local txeGen = vgui.Create("DTextEntry", frame);
    txeGen:SetPos(3, 25);
    txeGen:SetSize(400, 20);

    -- Fonts list
    local lblFnt = vgui.Create("DLabel", frame);
    lblFnt:SetPos(3, HEADER_H);
    lblFnt:SetFont("HudHintTextLarge");
    lblFnt:SetText("Available fonts to customize");
    lblFnt:SizeToContents();

    local scFonts = vgui.Create("DScrollPanel", frame);
    scFonts:SetPos(0, HEADER_H + 20);
    scFonts:SetSize((frame:GetWide() * 0.5) + 6, frame:GetTall() - scFonts.y - 36);

    local lsFonts = vgui.Create("DIconLayout", scFonts);
    lsFonts:SetPos(0, 0);
    lsFonts:SetSize(scFonts:GetWide() - 9, scFonts:GetTall());
    UpdateFontList(lsFonts);

    -- After setting a new unique font, refresh font options
    txeGen.OnEnter = function()
      HOLOHUD.CONFIG.FONTS:SetUniqueFont(txeGen:GetValue(1));
      UpdateFontList(lsFonts);
    end

    -- Reset all to default
    local btnReset = vgui.Create("DButton", frame);
    btnReset:SetPos(410, 25);
    btnReset:SetSize(200, 20);
    btnReset:SetText("Reset all to default");
    btnReset.DoClick = function()
      HOLOHUD.CONFIG.FONTS:ResetFontsToDefault();
      UpdateFontList(lsFonts);
    end

    -- Add preset
    local lblPrs = vgui.Create("DLabel", frame);
    lblPrs:SetPos((frame:GetWide() * 0.5) + 8, HEADER_H);
    lblPrs:SetFont("HudHintTextLarge");
    lblPrs:SetText("Create preset from current font settings");
    lblPrs:SizeToContents();

    local txePrs = vgui.Create("DTextEntry", frame);
    txePrs:SetPos(lblPrs.x, HEADER_H + 20);
    txePrs:SetSize(260, 20);

    local btnAdd = vgui.Create("DImageButton", frame);
    btnAdd:SetPos(txePrs.x + txePrs:GetWide() + 8, txePrs.y + 2);
    btnAdd:SetSize(16, 16);
    btnAdd:SetImage(SAVE_TEXTURE);
    btnAdd:SetTooltip("Save current settings as a preset");

    -- Font preset list
    local prsts = vgui.Create("DListView", frame);
    prsts:SetPos(lblPrs.x, HEADER_H + 45);
    prsts:SetSize(284, 170);
    prsts:AddColumn("Presets");
    UpdatePresetList(prsts);

    btnAdd.DoClick = function()
      HOLOHUD.CONFIG.FONTS:CreateFontSnapshot(txePrs:GetValue(1));
      txePrs:SetText("");
      UpdatePresetList(prsts);
    end

    local listOpt = vgui.Create("DIconLayout", frame);
    listOpt:SetPos(prsts.x + 5, prsts.y + prsts:GetTall() + 10);
    listOpt:SetSize(prsts:GetWide(), 100);
    listOpt:SetStretchWidth( true );
    listOpt:SetSpaceY(5);
    listOpt.Paint = function() end;

    prsts.OnRowSelected = function(pnl, index, row)
      listOpt:Clear();
      listOpt:Add(GenerateButtonOption(frame, "Load preset", "Confirm action", LOAD_TEXTURE, function()
        HOLOHUD.CONFIG.FONTS:LoadFontPreset(row:GetValue(1));
        UpdateFontList(lsFonts);
      end));
      listOpt:Add(GenerateButtonOption(frame, "Delete preset", "Confirm action", DELETE_TEXTURE, function()
        HOLOHUD.CONFIG.FONTS:DeleteFontPreset(row:GetValue(1));
        UpdatePresetList(prsts);
        listOpt:Clear();
      end));
    end

  end

end
