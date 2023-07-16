--[[------------------------------------------------------------------
  CONFIGURATION MENU
  Extended menu for the element customization
]]--------------------------------------------------------------------

if CLIENT then
  -- Namespace
  HOLOHUD.MENU = {};

  --[[include("menu/fonts.lua");
    include("menu/params.lua");
    include("menu/presets.lua");]]
end

HOLOHUD:IncludeFile("menu/fonts.lua");
HOLOHUD:IncludeFile("menu/params.lua");
HOLOHUD:IncludeFile("menu/presets.lua");

if CLIENT then

  --[[
    Builds the Q menu portion
    @param {Panel} panel
    @void
  ]]
  local function buildMenuComposition( panel )
  	panel:ClearControls();

    panel:AddControl( "Label" , { Text = "#holohud.qmenu.elements.header"} );

    panel:AddControl( "Button", {
  		Label = "#holohud.qmenu.elements.open",
  		Command = "holohud_menu"
  		}
  	);

    panel:AddControl( "Label" , { Text = ""} );
    panel:AddControl( "Label" , { Text = "#holohud.qmenu.general.header"} );

    panel:AddControl( "CheckBox", {
  		Label = "#holohud.qmenu.general.enabled",
      Command = "holohud_enabled"
  		}
  	);

    panel:AddControl( "CheckBox", {
  		Label = "#holohud.qmenu.general.autosave",
      Command = "holohud_autosave_enabled"
  		}
  	);

    panel:AddControl( "CheckBox", {
  		Label = "#holohud.qmenu.general.hide_on_death",
      Command = "holohud_death"
  		}
  	);

    panel:AddControl( "CheckBox", {
  		Label = "#holohud.qmenu.general.draw_without_suit",
      Command = "holohud_nosuit_enabled"
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.swaying",
      Type = "Float",
      Min = "0",
      Max = "4",
      Command = "holohud_sway"}
    );

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.blur",
      Type = "Float",
      Min = "0",
      Max = "1",
      Command = "holohud_blur"}
    );

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.blur_intensity",
      Type = "Float",
      Min = "0",
      Max = "2",
      Command = "holohud_blur_quality"}
    );

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.off_elements_alpha",
      Type = "Float",
      Min = "0",
      Max = "1",
      Command = "holohud_off_opacity"}
    );

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.flash_brightness",
      Type = "Float",
      Min = "0",
      Max = "1",
      Command = "holohud_flash_bright"}
    );

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.flash_alpha",
      Type = "Float",
      Min = "0",
      Max = "1",
      Command = "holohud_flash_alpha"}
    );

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.panel_deploy_speed",
      Type = "Float",
      Min = "0",
      Max = "1",
      Command = "holohud_flash_speed_on"}
    );

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.panel_retract_speed",
      Type = "Float",
      Min = "0",
      Max = "1",
      Command = "holohud_flash_speed_off"}
    );

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.background_alpha",
      Type = "Float",
      Min = "0",
      Max = "6",
      Command = "holohud_background_opacity"}
    );

    panel:AddControl( "Color", {
      Label = "#holohud.qmenu.general.background_color",
      Red = "holohud_background_r",
      Green = "holohud_background_g",
      Blue = "holohud_background_b"
      }
    );

    panel:AddControl( "CheckBox", {
  		Label = "#holohud.qmenu.general.chromatic_aberration",
      Command = "holohud_ca_enabled"
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "#holohud.qmenu.general.chromatic_aberration_separation",
      Type = "Float",
      Min = "0",
      Max = "10",
      Command = "holohud_ca_distance"}
    );

    panel:AddControl( "Button", {
  		Label = "#holohud.qmenu.general.reset",
  		Command = "holohud_reset"
  		}
  	);

    panel:AddControl( "CheckBox", {
  		Label = "#holohud.qmenu.general.show_all",
      Command = "holohud_contextmenu_enabled"
  		}
  	);

    panel:AddControl( "Numpad", {
      Label = "#holohud.qmenu.general.show_all_input",
      Command = "holohud_contextmenu"
      }
    );

    -- Credits
    panel:Help(string.format('\n %s', string.format(language.GetPhrase('#holohud.version'), HOLOHUD.Version.Major, HOLOHUD.Version.Minor, HOLOHUD.Version.Patch)))
    panel:Help(string.format('\n %s', language.GetPhrase('#holohud.credits')))

    panel:Help("DyaMetR");
    panel:ControlHelp("#holohud.credits.author");

    panel:Help("Matsilagi");
    panel:ControlHelp("#holohud.credits.support");

    panel:Help("IBRS");
    panel:ControlHelp("#holohud.credits.localization.cn");
  end

  --[[
    Adds the menu to the Q menu
    @void
  ]]
  local function menuCreation()
  	spawnmenu.AddToolMenuOption( "Utilities", "H0L-D4", "holohud", "Settings", nil, nil, buildMenuComposition );
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

    sheet:AddSheet("#holohud.menu.fonts.tab", fonts, "icon16/font.png");
    sheet:AddSheet("#holohud.menu.elements.tab", elements, "icon16/application_view_tile.png");
    sheet:AddSheet("#holohud.menu.presets.tab", presets, "icon16/script.png");

  end
  concommand.Add("holohud_menu", function(player, command, arguments) OpenMenu(); end);

end
