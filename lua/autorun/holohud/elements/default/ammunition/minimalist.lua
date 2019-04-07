--[[------------------------------------------------------------------
  AMMUNITION INDICATOR
  Minimalist layout
]]--------------------------------------------------------------------

if CLIENT then
  -- Namespace
  local AMMUNITION = HOLOHUD.ELEMENTS.AMMUNITION;

  -- Parameters
  local AMMO_PANEL_OFFSET = 20;
  local BULLET_PANEL_H = 154;
  local CLIP_TEXTURE, CLIP_TEXTURE_BRIGHT = surface.GetTextureID("holohud/clip"), surface.GetTextureID("holohud/clipb");
  local CLIP_W, CLIP_H = 32, 32;

  -- Panels
  local PANEL_NAME = AMMUNITION.PANELS.DEFAULT;
  local PANEL_NAME_SECONDARY = AMMUNITION.PANELS.SECONDARY;
  local PANEL_NAME_MIN = AMMUNITION.PANELS.MINIMALIST;

  -- Highlights
  local CLIP = AMMUNITION.HIGHLIGHT.CLIP;
  local RESERVE = AMMUNITION.HIGHLIGHT.RESERVE;
  local ALT = AMMUNITION.HIGHLIGHT.SECONDARY;

  --[[
    Draws a vertical clip
    @param {number} x
    @param {number} y
    @param {number} width
    @param {number} height
    @param {number} margin
    @param {number} ammo
    @param {number} clip
    @param {number} maxClip
    @param {number} bright
    @param {boolean} draw the max clip indicator
    @param {Color|nil} colour
    @param {number|nil} animation
    @param {number|nil} reload animation
    @void
  ]]
  local cLerp = 0;
  local function DrawClip(x, y, w, h, ammo, clip, maxClip, bright, drawMaxClip, colour, anim, rAnim)
    anim = anim or aOffset;
    rAnim = rAnim or rOffset;
    colour = colour or AMMUNITION:GetColour();

    -- Get bullets size
    local icon = HOLOHUD.ICONS:GetBulletIcon(ammo);
    local margin, tWidth = icon.margin or 0, icon.w or 0;
    local bullets = math.floor((h - margin - 6) / margin);
    HOLOHUD.ELEMENTS.AMMUNITION:DrawBulletStream(x + (w * 0.5) - (tWidth * 0.5), y + (h * 0.5) - (margin * bullets * 0.5), ammo, clip, maxClip, bullets, colour, bright, anim, rAnim, 1-rAnim, true);

    if (not drawMaxClip) then return; end
    -- Draw full clip indicator
    local mul = (1 + (1 - cLerp));
    local u, v = (w - 4), (h - 4);
    surface.SetDrawColor(Color(colour.r, colour.g, colour.b, colour.a * cLerp * (0.33 + 0.33 * bright)));
    surface.DrawOutlinedRect(x + 2 - (u * (1 - cLerp)) * 0.5, y + 2 - (v * (1 - cLerp)) * 0.5, u * mul, v * mul);

    if (ammo <= 0) then return; end
      -- Animate
    if (clip >= maxClip) then
      cLerp = Lerp(FrameTime() * 9, cLerp, 1);
    else
      cLerp = Lerp(FrameTime() * 12, cLerp, 0);
    end
  end

  --[[
    Draws two digit small ammo counter for an ammo type
    @param {number} x
    @param {number} y
    @param {number} ammo
    @param {number|nil} bright amount
    @param {boolean|nil} is off
    @param {number|nil} percentage of icon displayed
    @param {Color|nil} colour
    @param {boolean|nil} discard clip icon and draw an ammo type generic icon instead
    @param {number|nil} ammo type
    @void
  ]]
  local function DrawClipCounter(x, y, w, h, amount, bright, off, percentage, colour, drawAmmoType, ammo)
    percentage = percentage or 1;
    colour = colour or AMMUNITION:GetColour();

    -- Draw amount
    HOLOHUD:DrawNumber(x + 25, y + 18, amount, colour, "00", bright, "holohud_med_sm", off);

    -- Draw icon
    if (not drawAmmoType) then
      HOLOHUD:DrawProgressTexture(x - 1, y + 3, CLIP_TEXTURE, CLIP_TEXTURE_BRIGHT, CLIP_W, CLIP_H, CLIP_H, percentage, bright, colour, TEXT_ALIGN_BOTTOM, off, true);
    else
      if (off) then colour = Color(255, 255, 255, 24); end
      local w, h = HOLOHUD.ICONS:GetBulletIcon(ammo).w, HOLOHUD.ICONS:GetBulletIcon(ammo).h;
      HOLOHUD.ICONS:DrawBulletIcon(x - (w * 0.5) + 15, y + 18 - (h * 0.5), ammo, colour, bright);
    end
  end

  --[[
    Draws the minimalist panel
    @param {number} primary ammunition type
    @param {number} secondary ammunition type
    @param {number} clip ammunition amount
    @param {number} primary ammunition reserve
    @param {number} secondary ammunition reserve
    @param {function} configuration
    @return {number} width
    @return {number} height
  ]]
  local pLerp = 0;
  function HOLOHUD.ELEMENTS.AMMUNITION:MinimalistPanel(primary, secondary, clip, maxClip, reserve, alt, config, off)

    -- Set up variables for display and layout
    local bright = HOLOHUD:GetHighlight(CLIP);
    local aOffset, rOffset = AMMUNITION:GetBulletStreamAnimation();
    local altPanelOffsetMul = 1;
    local primaryAmmo = primary;
    local secondaryAmmo = secondary;
    local bullets = clip; -- Clip
    local clips = math.ceil(reserve/maxClip); -- Reserve
    local altBullets = alt; -- Secondary ammo
    local single = false; -- Should be clip only

    -- Change based on whether weapon uses clips
    if (primary < 0 and secondary >= 0) then
      bright = HOLOHUD:GetHighlight(ALT);
      primaryAmmo = secondary;
      secondaryAmmo = -1;
      bullets = alt;
      single = true;
      maxClip = game.GetAmmoMax(secondary);
      aOffset, rOffset = AMMUNITION:GetBulletStreamAnimation(true);
    else
      if (clip <= -1) then
        bright = HOLOHUD:GetHighlight(RESERVE);
        bullets = reserve;
        single = true;
        maxClip = game.GetAmmoMax(primary);
        if (secondary >= 0) then altPanelOffsetMul = 0.5; end
      end
    end

    -- Get primary ammo clip counter dimensions
    local margin = HOLOHUD.ICONS:GetBulletIcon(primaryAmmo).margin or 0;
    local w, h = (margin * 2) + 4, BULLET_PANEL_H; -- Bullet panel size
    local u, v = HOLOHUD:GetNumberSize(2, "holohud_med_sm") + 33, 37; -- Clip counter panel size

    -- Animate clip icon
    if (not HOLOHUD:IsPanelActive(PANEL_NAME)) then
      w = -5;
      pLerp = Lerp(FrameTime() * 4, pLerp, clip/maxClip);
    else
      pLerp = 1;
    end

    -- Display panels
    HOLOHUD:SetPanelActive(PANEL_NAME_MIN, not AMMUNITION:InVehicle() and primary >= 0 and clip > -1);

    -- Primary ammo
    HOLOHUD:DrawFragment(ScrW() - (w + AMMO_PANEL_OFFSET), ScrH() - (h + AMMO_PANEL_OFFSET), w, h, DrawClip, PANEL_NAME, primaryAmmo, bullets, maxClip, bright, not single, nil, aOffset, rOffset);
    HOLOHUD:DrawFragment(ScrW() - (u + w + AMMO_PANEL_OFFSET + 5), ScrH() - (v + AMMO_PANEL_OFFSET), u, v, DrawClipCounter, PANEL_NAME_MIN, clips, HOLOHUD:GetHighlight(RESERVE), off or primary < 0 or clip <= -1, pLerp);

    -- Secondary ammo
    HOLOHUD:SetPanelActive(PANEL_NAME_SECONDARY, not AMMUNITION:InVehicle() and secondaryAmmo >= 0 and (alt > 0 or config("always")));
    HOLOHUD:DrawFragment(ScrW() - (u + w + AMMO_PANEL_OFFSET + 5), ScrH() - ((v * 2 * altPanelOffsetMul) + 5 + AMMO_PANEL_OFFSET), u, v, DrawClipCounter, PANEL_NAME_SECONDARY, altBullets, HOLOHUD:GetHighlight(ALT), off or secondary < 0, nil, AMMUNITION:GetColour(true), true, secondaryAmmo);

    if (HOLOHUD:IsPanelActive(PANEL_NAME)) then
      v = h;
    end

    return u + w, v;
  end
end
