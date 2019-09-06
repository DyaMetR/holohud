--[[------------------------------------------------------------------
  HEALTH AND ARMOUR INDICATORS
  Heart monitor layout
]]--------------------------------------------------------------------

if CLIENT then
  -- Namespace
  local HEALTH = HOLOHUD.ELEMENTS.HEALTH;

  -- Panels
  local PANEL_NAME, KEVLAR = HEALTH.PANELS.DEFAULT, HEALTH.PANELS.KEVLAR;

  -- Highlights
  local DEFAULT, ARMOUR = HEALTH.HIGHLIGHT.HEALTH, HEALTH.HIGHLIGHT.ARMOUR;

  -- Parameters
  local HEALTH_PANEL_OFFSET = 20;
  local HEART_PANEL_W, HEART_PANEL_H, HEART_ARMOUR_OFFSET = 124, 50, 8;
  local KEVLAR_PANEL_MARGIN = 5;
  local TIME = 5;

  -- Variables
  local apLerp = 0; -- Armour animated value

  --[[
    Draws an armour bar
    @param {number} x
    @param {number} y
    @param {number} armour
    @param {number} bright
    @param {boolean} hide numbers
    @void
  ]]
  local function DrawArmourBar(x, y, armour, bright, hide)
    HOLOHUD:DrawVerticalBar(x, y, HEALTH:GetArmourColour(), apLerp * 0.01, bright);
    if (hide) then return; end
    HOLOHUD:DrawNumber(x - 7, y + 14, armour, HEALTH:GetArmourColour(), nil, bright, "holohud_small", nil, TEXT_ALIGN_RIGHT);
  end

  --[[
    Draws the kevlar icon
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} armour
    @param {number} bright
    @void
  ]]
  local function DrawKevlar(x, y, w, h, armour, bright)
    HOLOHUD:DrawKevlar(x + 6, y + 3, HEALTH:GetArmourColour(), apLerp * 0.01, bright);
    HOLOHUD:DrawNumber(x + 47, y + 42, armour, HEALTH:GetArmourColour(), nil, HOLOHUD:GetHighlight(ARMOUR), "holohud_tiny", armour <= 0, TEXT_ALIGN_RIGHT);
  end

  --[[
    Draws the health indicator
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} health
    @param {number} armour
    @param {boolean} is kevlar icon enabled
    @param {boolean} should hide numbers
    @void
  ]]
  local function DrawHeartbeat(x, y, w, h, health, armour, kevlar, hide)
    local offset = 0;

    -- Display armour
    if (armour > 0 and not kevlar) then
      DrawArmourBar(x + 104, y + 1, armour, HOLOHUD:GetHighlight(ARMOUR), hide);
      offset = HEART_ARMOUR_OFFSET;
    end

    -- Display health
    HOLOHUD:DrawHeartMonitor(x - 3, y - 3, HEALTH:GetHealthColour(), HOLOHUD:GetHighlight(DEFAULT));

    if (hide) then return; end
    HOLOHUD:DrawNumber(x + 114 + offset, y + 24, health, HEALTH:GetHealthColour(), nil, HOLOHUD:GetHighlight(DEFAULT));
  end

  --[[
    Draws the heart monitor panel
    @param {number} health
    @param {number} armour
    @param {boolean} should display kevlar
    @param {boolean} should hide numbers
    @void
  ]]
  function HOLOHUD.ELEMENTS.HEALTH:HeartratePanel(health, armour, kevlar, hide)
    -- Animate armour indicator
    apLerp = Lerp(FrameTime() * 4, apLerp, armour);

    -- Get health panel size
    local width = HOLOHUD:GetNumberSize(math.max(math.floor(math.log10(health) + 1), 3));
    if (hide) then
      if (armour > 0) then
        width = -12;
      else
        width = -18;
      end
    end

    -- Decide whether to display kevlar icon
    local offset = 0; -- Armour offset
    if (kevlar) then -- Kevlar icon enabled
      local offset = HEART_PANEL_W + width + KEVLAR_PANEL_MARGIN;

      -- Move kevlar icon if health panel is disabled
      if (not HOLOHUD:IsPanelActive(DEFAULT)) then offset = 0; end

      -- Draw kevlar icon
      HOLOHUD:DrawFragment(HEALTH_PANEL_OFFSET + offset, ScrH() - (HEART_PANEL_H + HEALTH_PANEL_OFFSET), HEART_PANEL_H, HEART_PANEL_H, DrawKevlar, KEVLAR, armour, HOLOHUD:GetHighlight(ARMOUR));
    else
      -- Make the heart rate monitor bigger to fit the armour bar
      if (armour > 0) then
        offset = HEART_ARMOUR_OFFSET;
      end
    end

    -- Draw heart rate monitor
    HOLOHUD:DrawFragment(HEALTH_PANEL_OFFSET, ScrH() - (HEART_PANEL_H + HEALTH_PANEL_OFFSET), HEART_PANEL_W + width + offset, HEART_PANEL_H, DrawHeartbeat, PANEL_NAME, health, armour, kevlar, hide);

    return width + offset, HEART_PANEL_H;
  end
end
