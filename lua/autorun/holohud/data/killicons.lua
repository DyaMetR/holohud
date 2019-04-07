--[[------------------------------------------------------------------
  DEFAULT KILL ICONS
  Default icons for generic and environmental deaths
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local DM_FONT = "holohud_killicons_hl2mp";

  -- Create fonts
  HOLOHUD:CreateFont(DM_FONT, 40, "HL2MP", 0);

  -- Icons
  HOLOHUD.ICONS:AddKillIconChar("prop_physics", DM_FONT, "9", 0, 6);
  HOLOHUD.ICONS:AddKillIconImage("worldspawn", surface.GetTextureID("holohud/killfeed/generic"), 32, 32, 20);
  HOLOHUD.ICONS:AddKillIconImage("env_explosion", surface.GetTextureID("holohud/killfeed/generic"), 32, 32, 20);

end
