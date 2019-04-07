--[[------------------------------------------------------------------
  AMMUNITION INDICATOR
  Compact layout
]]--------------------------------------------------------------------

-- Namespace
local AMMUNITION = HOLOHUD.ELEMENTS.AMMUNITION;

-- Parameters
local AMMO_PANEL_OFFSET = 20; -- Screen offset
local DEFAULT_H, COMPACT_H = 67, 50; -- Height
local BULLET_MARGIN, NUMBER_MARGIN = 4, 18; -- Primary ammo size margins
local PANEL_MARGIN = 5; -- Distance between primary and secondary panels

-- Panels
local PANEL_NAME = AMMUNITION.PANELS.DEFAULT;
local PANEL_NAME_SECONDARY = AMMUNITION.PANELS.SECONDARY;

-- Highlights
local CLIP = AMMUNITION.HIGHLIGHT.CLIP;
local RESERVE = AMMUNITION.HIGHLIGHT.RESERVE;
local ALT = AMMUNITION.HIGHLIGHT.SECONDARY;

--[[
  Draws the primary ammunition indicator
  @param {number} x
  @param {number} y
  @param {number} w
  @param {number} h
  @param {number} primary ammunition type
  @param {number} secondary ammunition type
  @param {number} clip ammunition amount
  @param {number} maximum clip capacity
  @param {number} primary ammunition reserve
  @param {number} secondary ammunition reserve
  @param {boolean|nil} is the panel retracted
  @param {boolean|nil} should the numbers be off
  @void
]]
local lerp = 0;
local function DrawPrimary(x, y, w, h, primary, secondary, clip, maxClip, reserve, alt, isRetracted, off)
  -- Check if has valid primary ammunition, in which case secondary will be displayed
  if (isRetracted) then
    if (primary >= 0) then
      clip = reserve;
    else
      primary = secondary;
      clip = alt;
    end
    maxClip = game.GetAmmoMax(primary);
  end

  -- Get sizes
  local icon = HOLOHUD.ICONS:GetBulletIcon(primary);
  local margin, tWidth = icon.margin or 0, icon.w or 0;
  local colour = AMMUNITION:GetColour();
  local aOffset, rOffset = AMMUNITION:GetBulletStreamAnimation();

  -- Animate reserve
  lerp = Lerp(FrameTime() * 4, lerp, reserve);

  -- Draw
  HOLOHUD:DrawNumber(x + margin + 11, y + 22, clip, colour, nil, HOLOHUD:GetHighlight(CLIP), nil, off);
  if (not isRetracted) then
    HOLOHUD:DrawNumber(x + margin + (w * 0.5) - 7, y + 51, math.Round(lerp), colour, "0000", HOLOHUD:GetHighlight(CLIP), "holohud_small", off, TEXT_ALIGN_CENTER);
  end
  AMMUNITION:DrawBulletStream(x - (tWidth * 0.5) + (margin * 0.5) + 7, y + 7, primary, clip, maxClip, (h - 8) / margin, colour, HOLOHUD:GetHighlight(CLIP), aOffset, rOffset, 1-rOffset, true);
end

--[[
  Draws the secondary ammunition indicator
  @param {number} x
  @param {number} y
  @param {number} w
  @param {number} h
  @param {number} secondary ammunition type
  @param {number} secondary ammunition reserve
  @param {boolean|nil} should numbers be off
  @void
]]
local function DrawSecondary(x, y, w, h, secondary, alt, off)
  local icon = HOLOHUD.ICONS:GetBulletIcon(secondary);
  local margin, tWidth = icon.margin or 0, icon.w or 0;
  local aOffset, rOffset = AMMUNITION:GetBulletStreamAnimation(true);
  local bullets = math.floor((h - 8) / margin);

  AMMUNITION:DrawBulletStream(x - (tWidth * 0.5) + (w * 0.5), y + (h * 0.5) - (bullets * margin * 0.5), secondary, alt, game.GetAmmoMax(secondary), bullets, AMMUNITION:GetColour(), HOLOHUD:GetHighlight(CLIP), aOffset, rOffset, 1-rOffset, true);
end

--[[
  Draws the compact panel
  @param {number} primary ammunition type
  @param {number} secondary ammunition type
  @param {number} clip ammunition amount
  @param {number} primary ammunition reserve
  @param {number} secondary ammunition reserve
  @param {function} configuration
  @return {number} width
  @return {number} height
]]
local isRetracted = false;
function HOLOHUD.ELEMENTS.AMMUNITION:CompactPanel(primary, secondary, clip, maxClip, reserve, alt, config, off)
  -- Font size
  local fontW, fontH = HOLOHUD:GetNumberSize(3);

  -- Primary ammo size
  local margin = HOLOHUD.ICONS:GetBulletIcon(primary).margin or 0; -- Bullet size
  local width, height = (margin + BULLET_MARGIN) + fontW + NUMBER_MARGIN, DEFAULT_H; -- Panel dimensions

  -- Secondary ammo size
  local altMargin = HOLOHUD.ICONS:GetBulletIcon(secondary).margin or 0; -- Bullet size
  local altWidth = (altMargin + 8) + BULLET_MARGIN; -- Panel dimensions

  -- Make it smaller if retracted
  if (isRetracted) then
    height = fontH - 4;

    if (primary < 0 and secondary >= 0) then
      local margin = HOLOHUD.ICONS:GetBulletIcon(secondary).margin or 0;
      width = (margin + BULLET_MARGIN) + fontW + NUMBER_MARGIN;
    end
  end

  -- Display
  HOLOHUD:SetPanelActive(PANEL_NAME_SECONDARY, not AMMUNITION:InVehicle() and (AMMUNITION:CanDisplay(clip, maxClip) or config("always")) and secondary >= 0 and primary >= 0);
  HOLOHUD:DrawFragment(ScrW() - (width + AMMO_PANEL_OFFSET), ScrH() - (height + AMMO_PANEL_OFFSET), width, height, DrawPrimary, PANEL_NAME, primary, secondary, clip, maxClip, reserve, alt, isRetracted, off or clip <= -1 and primary < 0 and secondary < 0);
  HOLOHUD:DrawFragment(ScrW() - (width + altWidth + PANEL_MARGIN + AMMO_PANEL_OFFSET), ScrH() - (height + AMMO_PANEL_OFFSET), altWidth, height, DrawSecondary, PANEL_NAME_SECONDARY, secondary, alt, off or primary < 0);

  -- Check if the panel is retracted
  if (HOLOHUD:IsPanelActive(PANEL_NAME)) then
    isRetracted = (clip <= -1 and primary >= 0) or (primary < 0 and secondary >= 0);
  end

  return width, height;
end
