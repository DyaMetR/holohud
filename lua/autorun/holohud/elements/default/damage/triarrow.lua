--[[------------------------------------------------------------------
  DAMAGE INDICATOR
  Tri-arrow variant
]]--------------------------------------------------------------------

-- Namespace
local DAMAGE = HOLOHUD.ELEMENTS.DAMAGE;

-- Parameters
local WIDTH, HEIGHT = 128, 128; -- Directional indicators size
local MAJOR = surface.GetTextureID("holohud/damage/major");
local MAJOR_BRIGHT = surface.GetTextureID("holohud/damage/majorb");
local MODERATE = surface.GetTextureID("holohud/damage/moderate");
local MODERATE_BRIGHT = surface.GetTextureID("holohud/damage/moderateb");
local MINOR = surface.GetTextureID("holohud/damage/minor");
local MINOR_BRIGHT = surface.GetTextureID("holohud/damage/minorb");

-- Variables
local tick = 0; -- Animation ticker

--[[
  Animates damage indicators
  @void
]]
local function Animate(damage)
  if (tick < CurTime()) then

    -- Animate damage indicators
    for i, info in pairs(damage) do
      if (info.time > CurTime()) then
        if (info.anim < 1.33 and not info.faded) then
          damage[i].anim = math.Clamp(info.anim + 0.13, 0, 1.33);
          damage[i].fade = damage[i].anim;
        else
          damage[i].faded = true;

          -- Get the indicator into place
          if (info.anim > 1) then
            damage[i].anim = math.Clamp(info.anim - 0.08, 1, 2);
          end

          -- Bright animation
          if (not info.brighted) then
            if (info.bright < 1) then
              damage[i].bright = math.Clamp(info.bright + 0.05, 0, 1);
            else
              damage[i].brighted = true;
            end
          else
            damage[i].bright = math.Clamp(info.bright - 0.01, 0, 1);
          end
        end
      else
        if (info.fade > 0) then
          damage[i].fade = math.Clamp(info.fade - 0.01, 0, 1);
        else
          table.remove(damage, i);
        end
      end
    end
    tick = CurTime() + 0.01;
  end
end

--[[
  Draws a damage arrow
  @param {number} distance from screen multiplier
  @param {number} rotation
  @param {number} animation
  @param {number} bright
  @param {Color} colour
  @void
]]
local function DrawIndicator(config, rot, anim, fade, bright, amount, colour)
  local yaw, margin = -rot, ScrH() * 0.26 * config;

  -- Position
  local u, v = HOLOHUD:GetSway();
  local x = (ScrW() * 0.5) + math.cos(math.rad(yaw - 90)) * (margin - (WIDTH * 0.5) + anim * 25) + u;
  local y = (ScrH() * 0.5) + math.sin(math.rad(yaw - 90)) * (margin - (HEIGHT * 0.5) + anim * 25) + v;

  -- Alpha
  local alpha = 255 * fade;
  local brightAlpha = 255 * fade * math.Clamp(0.15 + bright, 0, 1);

  -- Minor
  HOLOHUD:DrawTextureRotated(MINOR, x, y, WIDTH, HEIGHT, Color(255, 0, 0, alpha), rot, true);

  surface.SetDrawColor(Color(255, 0, 0, brightAlpha));
  surface.SetTexture(MINOR_BRIGHT);
  surface.DrawTexturedRectRotated(x, y, WIDTH, HEIGHT, rot);

  if (amount <= 5) then return; end
  -- Moderate
  HOLOHUD:DrawTextureRotated(MODERATE, x, y, WIDTH, HEIGHT, Color(255, 0, 0, alpha), rot, true);

  surface.SetDrawColor(Color(255, 0, 0, brightAlpha));
  surface.SetTexture(MODERATE_BRIGHT);
  surface.DrawTexturedRectRotated(x, y, WIDTH, HEIGHT, rot);

  if (amount <= 10) then return; end
  -- Major
  HOLOHUD:DrawTextureRotated(MAJOR, x, y, WIDTH, HEIGHT, Color(255, 0, 0, alpha), rot, true);

  surface.SetDrawColor(Color(255, 0, 0, brightAlpha));
  surface.SetTexture(MAJOR_BRIGHT);
  surface.DrawTexturedRectRotated(x, y, WIDTH, HEIGHT, rot);

end

--[[
  Draws the tri-arrow variant of the damage indicator
  @param {table} damage table
  @param {Color} colour
  @void
]]
function HOLOHUD.ELEMENTS.DAMAGE:TriArrow(distance, damage, colour)
  Animate(damage);

  -- Draw directional indicators
  for _, info in pairs(damage) do
    DrawIndicator(distance, info.angle, info.anim, info.fade, info.bright, info.damage, colour);
  end
end
