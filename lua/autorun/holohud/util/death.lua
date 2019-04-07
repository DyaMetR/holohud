--[[------------------------------------------------------------------
  DEATH
  Simulates HUD shut down after dying
]]--------------------------------------------------------------------

if CLIENT then

  -- Namespace
  HOLOHUD.DEATH = {};

  -- Parameters
  local HIDE_TIME = 3;

  -- Variables
  local hideTime = 0;

  --[[
    Runs the death animation
    @void
  ]]
  local function Animate()
    if (not HOLOHUD:IsDeathAnimationEnabled()) then return; end
    if (LocalPlayer():Alive()) then
      hideTime = CurTime() + HIDE_TIME;
    end
  end

  -- Hook the animation to the HUD
  hook.Add("HUDPaint", "holohud_death", function() Animate(); end);

  --[[
    Returns whether the HUD should forcefully hide
    @return {boolean} should hide
  ]]
  function HOLOHUD.DEATH:ShouldHUDHide()
    return (hideTime < CurTime() and not LocalPlayer():Alive()) and HOLOHUD:IsDeathAnimationEnabled();
  end

end
