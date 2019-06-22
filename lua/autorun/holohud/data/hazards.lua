--[[------------------------------------------------------------------
  HAZARDS
  Default environmental hazards
]]--------------------------------------------------------------------

if CLIENT then

  -- Hazards
  HOLOHUD.ICONS:AddHazardImage("acid", surface.GetTextureID("holohud/hazards/acid"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("burn", surface.GetTextureID("holohud/hazards/burn"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("drown", surface.GetTextureID("holohud/hazards/drown"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("fall", surface.GetTextureID("holohud/hazards/fall"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("paralyze", surface.GetTextureID("holohud/hazards/paralyze"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("poison", surface.GetTextureID("holohud/hazards/poison"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("radiation", surface.GetTextureID("holohud/hazards/radiation"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("shock", surface.GetTextureID("holohud/hazards/shock"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("explosion", surface.GetTextureID("holohud/hazards/explosion"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("beam", surface.GetTextureID("holohud/hazards/beam"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("gas", surface.GetTextureID("holohud/hazards/gas"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("energy", surface.GetTextureID("holohud/hazards/energy"), 64, 64);
  HOLOHUD.ICONS:AddHazardImage("freeze", surface.GetTextureID("holohud/hazards/paralyze"), 64, 64);

  -- Damage types
  HOLOHUD:AddHazard(DMG_ACID, "acid");
  HOLOHUD:AddHazard(DMG_BLAST, "explosion");
  HOLOHUD:AddHazard(DMG_BURN, "burn");
  HOLOHUD:AddHazard(DMG_DISSOLVE, "energy");
  HOLOHUD:AddHazard(DMG_DROWN, "drown");
  HOLOHUD:AddHazard(DMG_ENERGYBEAM, "beam");
  HOLOHUD:AddHazard(DMG_FALL, "fall");
  HOLOHUD:AddHazard(DMG_NERVEGAS, "gas");
  HOLOHUD:AddHazard(DMG_POISON, "poison");
  HOLOHUD:AddHazard(DMG_RADIATION, "radiation");
  HOLOHUD:AddHazard(DMG_SHOCK, "shock");
  HOLOHUD:AddHazard(DMG_SLOWBURN, "burn");
  HOLOHUD:AddHazard(DMG_PARALYZE, "paralyze");
  HOLOHUD:AddHazard(DMG_VEHICLE, "freeze"); --Defined as DMG_VEHICLE, is also considered freeze
  HOLOHUD:AddHazard(DMG_REMOVENORAGDOLL, "freeze"); --Defined as DMG_REMOVENORAGDOLL, is also considered slowfreeze

end
