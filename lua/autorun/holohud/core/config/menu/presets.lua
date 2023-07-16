--[[------------------------------------------------------------------
  PRESETS
  User generated configuration snapshots menu
]]--------------------------------------------------------------------

if CLIENT then

  local list; -- Preset list panel reference

  --[[
    Updates the presets list
    @param {Panel} list
    @void
  ]]
  local function UpdateList()
    list:Clear();
    for preset, _ in pairs(HOLOHUD.CONFIG.PRESETS:GetPresets()) do
      list:AddLine(preset);
    end
  end

  --[[
    Generates a panel serving as an option for a preset
    @param {Panel} parent
    @param {number} x
    @param {number} y
    @param {string} label
    @param {string} image
    @param {Color} colour
    @param {function} func
  ]]
  local function GenerateOption(parent, x, y, label, image, colour, func)
    local panel = vgui.Create("DPanel", parent);
    panel:SetPos(x, y);
    panel:SetSize(parent:GetWide() - 15, 26);
    panel.Paint = function() draw.RoundedBox(6, 0, 0, panel:GetWide(), panel:GetTall(), colour); end

    local button = vgui.Create("DImageButton", panel);
    button:SetPos(5, 5);
    button:SetSize(16, 16);
    button:SetImage(image);
    button:SetTooltip("Confirm action");
    button.DoClick = function()
      func();
    end

    local lblDesc = vgui.Create("DLabel", panel);
    lblDesc:SetPos(26, 6);
    lblDesc:SetFont("DermaDefaultBold");
    lblDesc:SetTextColor(Color(255, 255, 255));
    lblDesc:SetText(label);
    lblDesc:SizeToContents();
  end

  --[[
    Generates a details panel for a preset
    @param {Panel} parent
    @param {string} preset
    @void
  ]]
  local SAVE_TEXTURE, DELETE_TEXTURE, LOAD_TEXTURE = "icon16/disk.png", "icon16/bin_empty.png", "icon16/layout_add.png";
  local function GenerateDetailsPanel(parent, preset)
    parent:Clear();

    local panel = vgui.Create("DPanel");
    panel:SetSize(parent:GetWide(), parent:GetTall());
    panel.Paint = function() end

    local lblTitle = vgui.Create("DLabel", panel);
    lblTitle:SetPos(5, 5);
    lblTitle:SetFont("Trebuchet24");
    lblTitle:SetText(preset);
    lblTitle:SizeToContents();

    local lblSubtitle = vgui.Create("DLabel", panel);
    lblSubtitle:SetPos(5, 31);
    lblSubtitle:SetFont("HudHintTextLarge");
    lblSubtitle:SetText("#holohud.menu.presets.selected.header");
    lblSubtitle:SizeToContents();

    GenerateOption(panel, 8, 56, "#holohud.menu.presets.selected.load", LOAD_TEXTURE, Color(0, 255, 0, 100), function() HOLOHUD.CONFIG.PRESETS:SelectPreset(preset); end);
    GenerateOption(panel, 8, 88, "#holohud.menu.presets.selected.delete", DELETE_TEXTURE, Color(255, 0, 0, 100), function() HOLOHUD.CONFIG.PRESETS:DeletePreset(preset); UpdateList(); parent:Clear(); end);

    parent:Add(panel);
  end

  --[[
    Loads up the presets manager portion
    @param {Panel} frame
    @void
  ]]
  local HEADER_H = 67;
  function HOLOHUD.MENU:Presets(frame)

    -- Presets list
    list = vgui.Create("DListView", frame);
    list:SetPos(0, 0);
    list:SetSize(frame:GetWide() * 0.3, frame:GetTall() - 10);
    list:AddColumn("#holohud.menu.presets.list");

    UpdateList();

    -- Header
    local header = vgui.Create("DPanel", frame);
    header:SetPos(list.x + list:GetWide() + 5, 5);
    header:SetSize(frame:GetWide() - header.x - 10, HEADER_H);
    header.Paint = function() end

    local lblTitle = vgui.Create("DLabel", header);
    lblTitle:SetPos(5, 3);
    lblTitle:SetFont("HudHintTextLarge");
    lblTitle:SetText("#holohud.menu.presets.create.header");
    lblTitle:SizeToContents();

    local lblSubtitle = vgui.Create("DLabel", header);
    lblSubtitle:SetPos(5, 20);
    lblSubtitle:SetFont("DermaDefaultBold");
    lblSubtitle:SetText("#holohud.menu.presets.create.details");
    lblSubtitle:SizeToContents();

    local txnName = vgui.Create("DTextEntry", header);
    txnName:SetPos(5, 40);
    txnName:SetSize(header:GetWide() * 0.88, 20);

    local btnSave = vgui.Create("DImageButton", header);
    btnSave:SetSize(16, 16);
    btnSave:SetPos(txnName.x + txnName:GetWide() + 8, 42);
    btnSave:SetTooltip("Save configuration");
    btnSave:SetImage(SAVE_TEXTURE);
    btnSave.DoClick = function()
      HOLOHUD.CONFIG.PRESETS:CreateSnapshot(txnName:GetValue(1));
      UpdateList(list);
    end;

    -- Details
    local panel = vgui.Create("DPanel", frame);
    panel:SetPos(list.x + list:GetWide() + 5, HEADER_H + 5);
    panel:SetSize(frame:GetWide() - panel.x - 18, frame:GetTall() - panel.y - 37);
    panel.Paint = function() end

    -- Generate a details panel upon clicking an element
    list.OnRowSelected = function(pnl, index, row)
      GenerateDetailsPanel(panel, row:GetValue(1));
    end
  end

end
