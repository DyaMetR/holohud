--[[------------------------------------------------------------------
  FONTS
  Default fonts
]]--------------------------------------------------------------------

if CLIENT then

  -- Roboto Light needs to have -1 added to vertical offset
  --[[local REGULAR = nil;
  local CONDENSED = "Roboto Condensed Light";

  HOLOHUD:CreateFont("holohud_med", 50, REGULAR);
  HOLOHUD:CreateFont("holohud_small", 28, CONDENSED, 500);
  HOLOHUD:CreateFont("holohud_tiny", 18, CONDENSED, 1000);]]

  local REGULAR = "Roboto Light";
  local CONDENSED = "Roboto Condensed Light";

  HOLOHUD:AddFont("holohud_main", "#holohud.fonts.main", REGULAR, 50);
  HOLOHUD:AddFont("holohud_main_cds", "#holohud.fonts.main_cds", CONDENSED, 50);
  HOLOHUD:AddFont("holohud_med_sm", "#holohud.fonts.med_sm", REGULAR, 38);
  HOLOHUD:AddFont("holohud_small", "#holohud.fonts.small", CONDENSED, 28);
  HOLOHUD:AddFont("holohud_tiny", "#holohud.fonts.tiny", CONDENSED, 18, 1000);

  HOLOHUD:AddFont("holohud_pickup", "#holohud.fonts.pickup", CONDENSED, 18, 1000);
  HOLOHUD:AddFont("holohud_weapon_name", "#holohud.fonts.weapon_name", CONDENSED, 20, 0);
  HOLOHUD:AddFont("holohud_entity", "#holohud.fonts.entity", REGULAR, 23, 1000);
  HOLOHUD:AddFont("holohud_target", "#holohud.fonts.target", CONDENSED, 28);

  HOLOHUD:AddFont("holohud_compass", "#holohud.fonts.compass", CONDENSED, 28);
  HOLOHUD:AddFont("holohud_compass_small", "#holohud.fonts.compass_small", CONDENSED, 18, 1000);

  HOLOHUD:AddFont("holohud_killfeed", "#holohud.fonts.killfeed", REGULAR, 20, 1000);

  HOLOHUD:AddFont("holohud_clock_main", "#holohud.fonts.clock_main", REGULAR, 26);
  HOLOHUD:AddFont("holohud_clock_big", "#holohud.fonts.clock_big", REGULAR, 50);
  HOLOHUD:AddFont("holohud_clock_med", "#holohud.fonts.clock_med", REGULAR, 32);
  HOLOHUD:AddFont("holohud_clock_small", "#holohud.fonts.clock_small", REGULAR, 20);
  HOLOHUD.CONFIG.FONTS:SetDefaultFont();

end
