--[[------------------------------------------------------------------
  DEFAULT WEAPON ICONS
  Default icons for HL2 weapons
]]--------------------------------------------------------------------

if CLIENT then

  local HL2_FONT = "holohud_weapon_icon_hl2";
  local RB_FONT = "holohud_weapon_icon_rb"

  -- Fonts
  HOLOHUD:CreateFont(HL2_FONT, 100, "HalfLife2", 0);
  HOLOHUD:CreateFont(RB_FONT, 100, "RealBeta's Weapon Icons", 0);  
  

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
  HOLOHUD.ICONS:AddWeaponIcon("weapon_annabelle", RB_FONT, "H");
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
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2r_frag", HL2_FONT, "k");  
  
  --MMOD TFA Weapons
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_crowbar", HL2_FONT, "c");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_pistol", HL2_FONT, "d");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_smg", HL2_FONT, "a");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_ar2", HL2_FONT, "l");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_shotgun", HL2_FONT, "b");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_shotgun_auto", HL2_FONT, "b");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_357", HL2_FONT, "e"); 
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_stunstick", HL2_FONT, "n");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_grenade", HL2_FONT, "k");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_rpg", HL2_FONT, "i"); 
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_crossbow", RB_FONT, "f");   
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_ar3", RB_FONT, "i");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_mmod_bugbait", HL2_FONT, "j");
  
  --MISC Weapons
  HOLOHUD.ICONS:AddWeaponIcon("weapon_portalgun", RB_FONT, "m");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2b_sniperrifle", RB_FONT, "o");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2b_ar2", HL2_FONT, "f");
  HOLOHUD.ICONS:AddWeaponIcon("tfa_hl2b_smg1", RB_FONT, "p");
  HOLOHUD.ICONS:AddWeaponIcon("weapon_medkit", RB_FONT, "e");

end
