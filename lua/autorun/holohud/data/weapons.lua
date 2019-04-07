--[[------------------------------------------------------------------
  DEFAULT WEAPON ICONS
  Default icons for HL2 weapons
]]--------------------------------------------------------------------

if CLIENT then

  local HL2_FONT = "holohud_weapon_icon_hl2";

  -- Fonts
  HOLOHUD:CreateFont(HL2_FONT, 100, "HalfLife2", 0);

  -- Half-life 2 weapons
  HOLOHUD.ICONS:AddWeaponIcon("weapon_physgun", HL2_FONT, "h");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_physcannon", HL2_FONT, "m");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_crowbar", HL2_FONT, "c");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_stunstick", HL2_FONT, "n");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_pistol", HL2_FONT, "d");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_357", HL2_FONT, "e");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_smg1", HL2_FONT, "a");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_ar2", HL2_FONT, "l");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_shotgun", HL2_FONT, "b");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_annabelle", HL2_FONT, "b");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_crossbow", HL2_FONT, "g");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_frag", HL2_FONT, "k");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_rpg", HL2_FONT, "i");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_slam", HL2_FONT, "o");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_bugbait", HL2_FONT, "j");

  -- HL2 REDUX TFA weapons
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2r_crowbar", HL2_FONT, "c");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2r_pistol", HL2_FONT, "d");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2r_smg", HL2_FONT, "a");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2r_ar2", HL2_FONT, "l");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2r_shotgun", HL2_FONT, "b");

end
