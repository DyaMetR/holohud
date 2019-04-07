--[[------------------------------------------------------------------
  ENVIRONMENTAL HAZARDS
  Register damage types
]]--------------------------------------------------------------------

if CLIENT then

  -- Hazards list
  HOLOHUD.Hazards = {};

  --[[
    Registers a damage type as a hazard
    @param {DMG_} damage type
    @param {string} hazard
    @void
  ]]
  function HOLOHUD:AddHazard(damageType, hazard)
    HOLOHUD.Hazards[damageType] = hazard;
  end

  --[[
    Gets the hazard from a damage type
    @param {DMG_} damage type
    @return {string} hazard
  ]]
  function HOLOHUD:GetHazard(damageType)
    return HOLOHUD.Hazards[damageType];
  end

  --[[
    Returns whether a damage type has a hazard registered
    @param {DMG_} damage type
    @return {boolean} exists
  ]]
  function HOLOHUD:HasHazard(damageType)
    return HOLOHUD:GetHazard(damageType) ~= nil;
  end

end
