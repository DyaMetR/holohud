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

  HOLOHUD:AddFont("holohud_main", "Main numeric display", REGULAR, 50);
  HOLOHUD:AddFont("holohud_main_cds", "Secondary numeric display", CONDENSED, 50);
  HOLOHUD:AddFont("holohud_med_sm", "Medium numeric display", REGULAR, 38);
  HOLOHUD:AddFont("holohud_small", "Small numeric display", CONDENSED, 28);
  HOLOHUD:AddFont("holohud_tiny", "Tiny numeric display", CONDENSED, 18, 1000);

  HOLOHUD:AddFont("holohud_pickup", "Pickup title", CONDENSED, 18, 1000);
  HOLOHUD:AddFont("holohud_weapon_name", "Weapon name", CONDENSED, 20, 0);
  HOLOHUD:AddFont("holohud_entity", "Entity details", REGULAR, 23, 1000);
  HOLOHUD:AddFont("holohud_target", "Player Target ID", CONDENSED, 28);

  HOLOHUD:AddFont("holohud_compass", "Compass (main bearings)", CONDENSED, 28);
  HOLOHUD:AddFont("holohud_compass_small", "Compass (graduation)", CONDENSED, 18, 1000);

  HOLOHUD:AddFont("holohud_killfeed", "Killfeed labels", REGULAR, 20, 1000);

  HOLOHUD:AddFont("holohud_clock_main", "Main clock display", REGULAR, 26);
  HOLOHUD:AddFont("holohud_clock_big", "Hour display", REGULAR, 50);
  HOLOHUD:AddFont("holohud_clock_med", "Minute display", REGULAR, 32);
  HOLOHUD:AddFont("holohud_clock_small", "Small date display", REGULAR, 20);
  HOLOHUD.CONFIG.FONTS:SetDefaultFont();

end
