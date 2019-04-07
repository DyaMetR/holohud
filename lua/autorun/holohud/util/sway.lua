--[[------------------------------------------------------------------
  SWAYING
  Camera based HUD movement
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local SWAY_COOLDOWN = 3;
  local MAX_SWAY = 30;
  local LERP_SPEED = 4;

  -- Variables
  local sway = {x = {angle = 0, value = 0, lerp = 0}, y = {angle = 0, value = 0, lerp = 0}};
  local tick = 0;

  --[[
    Returns the swaying amounts
    @return {number} x
    @return {number} y
  ]]
  function HOLOHUD:GetSway()
    return sway.x.lerp * HOLOHUD:GetSwayMul(), -sway.y.lerp * HOLOHUD:GetSwayMul();
  end

  --[[
    Fills up the lerp value with the linear interpolation of the sway value
    @param {table} sway
    @void
  ]]
  local function LerpSway(sway)
    sway.lerp = Lerp(FrameTime() * LERP_SPEED, sway.lerp, sway.value);
  end

  --[[
    Calculates swaying with the given swaying angle
    @param {table} sway
    @void
  ]]
  local function CalculateSway(sway, rawAngle)
    -- Calculate sway
    if (sway.angle ~= rawAngle) then
      sway.value = math.Clamp(sway.value + math.AngleDifference(rawAngle, sway.angle) * 2, -MAX_SWAY, MAX_SWAY);
      sway.angle = rawAngle;
    end

    -- Lerp the sway
    LerpSway(sway);
  end

  --[[
    Returns an angle to its original position
    @param {table} sway
    @param {number} amount
    @void
  ]]
  local function CalculateReturn(sway)
    local amount = SWAY_COOLDOWN;
    if (sway.value > 0) then
      sway.value = math.Clamp(sway.value - amount, 0, sway.value);
    elseif (sway.value < 0) then
      sway.value = math.Clamp(sway.value + amount, sway.value, 0);
    end
  end

  --[[
    Returns the HUD to its original position gradually
    @void
  ]]
  local function CooldownSway()
    if (tick < CurTime()) then
      CalculateReturn(sway.x);
      CalculateReturn(sway.y);
      tick = CurTime() + 0.01;
    end
  end

  -- Calculate swaying
  hook.Add("Think", "holohud_sway", function()
    CalculateSway(sway.x, LocalPlayer():EyeAngles().y); -- Horizontal swaying
    CalculateSway(sway.y, LocalPlayer():EyeAngles().p * 1.25); -- Vertical swaying
    CooldownSway(); -- Return to original position
  end);

end
