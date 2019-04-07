--[[------------------------------------------------------------------
  AMMUNITION INDICATOR
  Default layout
]]--------------------------------------------------------------------

if CLIENT then
  -- Namespace
  local AMMUNITION = HOLOHUD.ELEMENTS.AMMUNITION;

  -- Parameters
  local PANEL_NAME, PANEL_NAME_SECONDARY = AMMUNITION.PANELS.DEFAULT, AMMUNITION.PANELS.SECONDARY;
  local AMMO_PANEL_OFFSET = 20; -- Screen offset
  local DEFAULT_H = 67; -- Panel heights
  local DEFAULT_MARGIN, REDUCED_MARGIN = 24, 19; -- Panel width margins

  -- Highlights
  local CLIP = AMMUNITION.HIGHLIGHT.CLIP;
  local RESERVE = AMMUNITION.HIGHLIGHT.RESERVE;
  local ALT = AMMUNITION.HIGHLIGHT.SECONDARY;

  --[[
    Displays the ammunition indicator in case the weapon held doesn't use clips
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} ammunition type
    @param {number} ammunition amount
    @param {string|nil} zeroes
    @param {number|nil} bright
    @param {string|nil} font
    @param {Color|nil} colour
  ]]
  local function DrawClipless(x, y, w, ammo, amount, zeros, bright, font, colour, anim, off)
    colour = colour or AMMUNITION:GetColour();
    bright = bright or 0;

    -- Get bullet amounts
    local margin = HOLOHUD.ICONS:GetBulletIcon(ammo).margin or 0;
    local bullets = math.ceil((w - margin - 16) / margin); -- Amount of bullets to display

    -- Display number and bullets
    HOLOHUD:DrawNumber(x + 8, y + 23, amount, colour, zeros, bright, font, off);
    AMMUNITION:DrawBulletStream(x + (w * 0.5) - (margin * bullets * 0.5), y + 37, ammo, amount, game.GetAmmoMax(ammo), bullets, colour, bright, anim);
  end

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
  local lerp = 0; -- Reserve ammunition animated
  local function DrawPrimary(x, y, w, h, primary, secondary, clip, maxClip, reserve, alt, isRetracted, off)
    retractBright = retractBright or 0;
    local colour = AMMUNITION:GetColour();
    local aOffset, rOffset = AMMUNITION:GetBulletStreamAnimation(isRetracted and primary < 0); -- Animations
    lerp = Lerp(FrameTime() * 4, lerp, reserve);

    -- Does the weapon use clips?
    if (isRetracted) then
      local bright = HOLOHUD:GetHighlight(RESERVE); -- If uses primary as main ammunition

      -- In case it uses secondary as main ammunition
      if (primary < 0 and secondary >= 0) then
        bright = HOLOHUD:GetHighlight(ALT);
        colour = AMMUNITION:GetColour(true);
        reserve = alt;
        primary = secondary;
      end

      DrawClipless(x, y, w, primary, reserve, "0000", bright, nil, colour, aOffset, off);
    else
      local margin = HOLOHUD.ICONS:GetBulletIcon(primary).margin or 0;
      local bullets = math.ceil((w - margin - 16) / margin); -- Amount of bullets to display

      HOLOHUD:DrawNumber(x + 8, y + 23, clip, colour, nil, HOLOHUD:GetHighlight(CLIP), nil, off);
      HOLOHUD:DrawNumber(x + HOLOHUD:GetNumberSize(3) + 13, y + 23, math.Round(lerp), colour, "0000", HOLOHUD:GetHighlight(RESERVE), "holohud_small", off);
      AMMUNITION:DrawBulletStream(x + (w * 0.5) - (margin * bullets * 0.5), y + 37, primary, clip, maxClip, bullets, colour, HOLOHUD:GetHighlight(CLIP), aOffset, rOffset, 1-rOffset);
    end
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
    local aOffset, rOffset = AMMUNITION:GetBulletStreamAnimation(true);
    DrawClipless(x, y, w, secondary, alt, nil, HOLOHUD:GetHighlight(ALT), "holohud_main_cds", AMMUNITION:GetColour(true), aOffset, off);
  end

  --[[
    Draws the default panel
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
  function HOLOHUD.ELEMENTS.AMMUNITION:DefaultPanel(primary, secondary, clip, maxClip, reserve, alt, config, off)
    -- Primary ammo
    local width = HOLOHUD:GetNumberSize(3) + HOLOHUD:GetNumberSize(4, "holohud_small") + DEFAULT_MARGIN;
    if (isRetracted) then width = HOLOHUD:GetNumberSize(4) + REDUCED_MARGIN; end
    HOLOHUD:DrawFragment(ScrW() - (width + AMMO_PANEL_OFFSET), ScrH() - (DEFAULT_H + AMMO_PANEL_OFFSET), width, DEFAULT_H, DrawPrimary, PANEL_NAME, primary, secondary, clip, maxClip, reserve, alt, isRetracted, off or primary <= 0 and secondary <= 0);

    -- Secondary ammo
    local altWidth = HOLOHUD:GetNumberSize(3, "holohud_main_cds") + REDUCED_MARGIN;
    HOLOHUD:SetPanelActive(PANEL_NAME_SECONDARY, not AMMUNITION:InVehicle() and (AMMUNITION:CanDisplay(clip, maxClip) or config("always")) and (primary >= 0 and secondary >= 0));
    HOLOHUD:DrawFragment(ScrW() - (5 + altWidth + width + AMMO_PANEL_OFFSET), ScrH() - (DEFAULT_H + AMMO_PANEL_OFFSET), altWidth, DEFAULT_H, DrawSecondary, PANEL_NAME_SECONDARY, secondary, alt, secondary < 0);

    -- Check if the panel is retracted
    if (HOLOHUD:IsPanelActive(PANEL_NAME)) then
      isRetracted = (clip <= -1 and primary >= 0) or (primary < 0 and secondary >= 0);
    end

    return width + altWidth, DEFAULT_H
  end
end
