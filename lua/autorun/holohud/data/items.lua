--[[------------------------------------------------------------------
  DEFAULT ITEM ICONS
  Default icons for HL2 items
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local HL2_FONT = "holohud_item_icon_hl2";

  -- Create fonts
  HOLOHUD:CreateFont(HL2_FONT, 66, "HalfLife2", 0);

  -- Add icons
  HOLOHUD.ICONS:AddItemIcon("item_healthkit", HL2_FONT, "+", nil, -10);
  HOLOHUD.ICONS:AddItemIcon("item_healthvial", HL2_FONT, "+", nil, -10);
  HOLOHUD.ICONS:AddItemIcon("item_battery", HL2_FONT, "*", nil, -10);

end
