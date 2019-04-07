--[[------------------------------------------------------------------
  CONFIGURATION MENU
  Extended menu for the element customization
]]--------------------------------------------------------------------

if CLIENT then
  -- Namespace
  HOLOHUD.MENU = {};

  include("menu/fonts.lua");
  include("menu/params.lua");
  include("menu/presets.lua");

  --[[
    Builds the Q menu portion
    @param {Panel} panel
    @void
  ]]
  local function buildMenuComposition( panel )
  	panel:ClearControls();

    panel:AddControl( "Label" , { Text = "Element configuration"} );

    panel:AddControl( "Button", {
  		Label = "Open customization menu",
  		Command = "holohud_menu"
  		}
  	);

    panel:AddControl( "Label" , { Text = ""} );
    panel:AddControl( "Label" , { Text = "Overall configuration"} );

    panel:AddControl( "CheckBox", {
  		Label = "Enabled",
      Command = "holohud_enabled"
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "Swaying",
      Type = "Float",
      Min = "0",
      Max = "4",
      Command = "holohud_sway"}
    );

    panel:AddControl( "Slider", {
      Label = "Blur",
      Type = "Float",
      Min = "0",
      Max = "1",
      Command = "holohud_blur"}
    );

    panel:AddControl( "Slider", {
      Label = "Blur intensity",
      Type = "Float",
      Min = "0",
      Max = "2",
      Command = "holohud_blur_quality"}
    );

    panel:AddControl( "Slider", {
      Label = "Background opacity",
      Type = "Float",
      Min = "0",
      Max = "6",
      Command = "holohud_background_opacity"}
    );

    panel:AddControl( "Color", {
      Label = "Background colour",
      Red = "holohud_background_r",
      Green = "holohud_background_g",
      Blue = "holohud_background_b"
      }
    );

    panel:AddControl( "CheckBox", {
  		Label = "Enable chromatic aberration",
      Command = "holohud_ca_enabled"
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "C.A. separation",
      Type = "Float",
      Min = "0",
      Max = "10",
      Command = "holohud_ca_distance"}
    );

    panel:AddControl( "Button", {
  		Label = "Reset to default",
  		Command = "holohud_reset"
  		}
  	);

    -- Credits
    panel:AddControl( "Label" , { Text = ""} );
    panel:AddControl( "Label",  { Text = "H0L-D4: Holographic Heads Up Display"});
    panel:AddControl( "Label",  { Text = "Version " .. HOLOHUD.Version.Major .. "." .. HOLOHUD.Version.Minor .. "." .. HOLOHUD.Version.Patch});
    panel:AddControl( "Label",  { Text = "Made by DyaMetR"});
    panel:AddControl( "Label",  { Text = "Special thanks to Matsilagi for additional support and testing"});
    panel:AddControl( "Label",  { Text = "Weapon selector skeleton provided by gs_code"});
  end

  --[[
    Adds the menu to the Q menu
    @void
  ]]
  local function menuCreation()
  	spawnmenu.AddToolMenuOption( "Options", "DyaMetR", "holohud", "H0L-D4", nil, nil, buildMenuComposition );
  end
  hook.Add( "PopulateToolMenu", "holohud_menu", menuCreation );

  --[[
    Opens the extended menu
    @void
  ]]
  local function OpenMenu()

    -- Create frame
    local frame = vgui.Create("DFrame");
    frame:SetSize(640, 460);
    frame:SetPos((ScrW() * 0.5) - (frame:GetWide() * 0.5), (ScrH() * 0.5) - (frame:GetTall() * 0.5));
    frame:SetTitle("H0L-D4");
    frame:MakePopup();
    frame:SetDraggable(true);
    frame.OnClose = function()
      HOLOHUD.EditMode = false;
    end
    frame.OnRemove = function()
      HOLOHUD.EditMode = false;
    end
    local think = frame.Think;
    frame.Think = function()
      HOLOHUD.EditMode = true;
      think(frame);
    end

    -- Property sheet
    local sheet = vgui.Create( "DPropertySheet", frame );
    sheet:SetPos(5, 30);
    sheet:SetSize(frame:GetWide() - 10, frame:GetTall() - 33);

    local elements = vgui.Create("DPanel", sheet);
    elements:SetPos(0, 0);
    elements:SetSize(sheet:GetWide(), sheet:GetTall());
    elements.Paint = function() end;
    HOLOHUD.MENU:Elements(elements);

    local presets = vgui.Create("DPanel", sheet);
    presets:SetPos(0, 0);
    presets:SetSize(sheet:GetWide(), sheet:GetTall());
    presets.Paint = function() end;
    HOLOHUD.MENU:Presets(presets);

    local fonts = vgui.Create("DPanel", sheet);
    fonts:SetPos(0, 0);
    fonts:SetSize(sheet:GetWide(), sheet:GetTall());
    fonts.Paint = function() end;
    HOLOHUD.MENU:Fonts(fonts);

    sheet:AddSheet("Fonts", fonts, "icon16/font.png");
    sheet:AddSheet("HUD elements", elements, "icon16/application_view_tile.png");
    sheet:AddSheet("Presets", presets, "icon16/script.png");

  end
  concommand.Add("holohud_menu", function(player, command, arguments) OpenMenu(); end);

end
