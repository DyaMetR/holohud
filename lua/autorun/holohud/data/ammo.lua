--[[------------------------------------------------------------------
  DEFAULT AMMUNITION ICONS
  Default icons for HL2 ammo
]]--------------------------------------------------------------------

if CLIENT then

  local HL2_FONT = "holohud_ammo_icon_hl2";
  local HL2DM_FONT = "holohud_ammo_icon_hl2mp";

  local PISTOL = game.GetAmmoID("Pistol");
  local MAGNUM = game.GetAmmoID("357");
  local SMG1 = game.GetAmmoID("SMG1");
  local SMG1_GRENADE = game.GetAmmoID("SMG1_Grenade");
  local AR2 = game.GetAmmoID("AR2");
  local AR2_ALT_FIRE = game.GetAmmoID("AR2AltFire");
  local BUCKSHOT = game.GetAmmoID("Buckshot");
  local CROSSBOW = game.GetAmmoID("XBowBolt");
  local GRENADE = game.GetAmmoID("Grenade");
  local RPG_ROUND = game.GetAmmoID("RPG_Round");
  local SLAM = game.GetAmmoID("slam");

  -- Fonts
  HOLOHUD:CreateFont(HL2_FONT, 37, "HalfLife2", 0);
  HOLOHUD:CreateFont(HL2DM_FONT, 37, "HL2MP", 0);

  -- Default weapon selector icons
  HOLOHUD.ICONS:AddAmmoIcon(PISTOL, HL2_FONT, "p");
  HOLOHUD.ICONS:AddAmmoIcon(MAGNUM, HL2_FONT, "q");
  HOLOHUD.ICONS:AddAmmoIcon(SMG1, HL2_FONT, "r");
  HOLOHUD.ICONS:AddAmmoIcon(SMG1_GRENADE, HL2_FONT, "t");
  HOLOHUD.ICONS:AddAmmoIcon(AR2, HL2_FONT, "u");
  HOLOHUD.ICONS:AddAmmoIcon(AR2_ALT_FIRE, HL2_FONT, "z", 0, 4);
  HOLOHUD.ICONS:AddAmmoIcon(BUCKSHOT, HL2_FONT, "s");
  HOLOHUD.ICONS:AddAmmoIcon(CROSSBOW, HL2_FONT, "w");
  HOLOHUD.ICONS:AddAmmoIcon(GRENADE, HL2_FONT, "v");
  HOLOHUD.ICONS:AddAmmoIcon(RPG_ROUND, HL2_FONT, "x");
  HOLOHUD.ICONS:AddAmmoIcon(SLAM, HL2DM_FONT, "*", 0, 14);

  -- Default ammunition indicator icons
  HOLOHUD.ICONS:AddBulletImage(AR2, "holohud/ammo/rifle", "holohud/ammo/rifleb", 32, 32, 9);
  HOLOHUD.ICONS:AddBulletImage(BUCKSHOT, "holohud/ammo/shotgun", "holohud/ammo/shotgunb", 32, 32, 13);
  HOLOHUD.ICONS:AddBulletImage(SMG1, "holohud/ammo/smg1", "holohud/ammo/smg1b", 32, 32, 9);
  HOLOHUD.ICONS:AddBulletImage(SMG1_GRENADE, "holohud/ammo/smg1gren", "holohud/ammo/smg1grenb", 32, 32, 12);
  HOLOHUD.ICONS:AddBulletImage(PISTOL, "holohud/ammo/pistol", "holohud/ammo/pistolb", 32, 32, 9);
  HOLOHUD.ICONS:AddBulletImage(MAGNUM, "holohud/ammo/357", "holohud/ammo/357b", 32, 32, 9);
  HOLOHUD.ICONS:AddBulletImage(AR2_ALT_FIRE, "holohud/ammo/ball", "holohud/ammo/ballb", 32, 32, 19);
  HOLOHUD.ICONS:AddBulletImage(CROSSBOW, "holohud/ammo/bolt", "holohud/ammo/boltb", 32, 32, 13);
  HOLOHUD.ICONS:AddBulletImage(RPG_ROUND, "holohud/ammo/rocket", "holohud/ammo/rocketb", 32, 32, 13);
  HOLOHUD.ICONS:AddBulletImage(SLAM, "holohud/ammo/slam", "holohud/ammo/slamb", 32, 32, 18);
  HOLOHUD.ICONS:AddBulletImage(GRENADE, "holohud/ammo/grenade", "holohud/ammo/grenadeb", 32, 32, 18);

end
